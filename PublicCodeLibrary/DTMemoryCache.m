//
//  MEMemoryCache.m
//  IphoneEPG
//
//  Created by Pierre Bongen on 05.02.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "DTMemoryCache.h"

#import "DTMemoryCacheEntry.h"
#import "DTDebugging.h"


NSTimeInterval const DTMemoryCacheReduceSizeTimeInterval = 0.5;
DTCacheSize const DTMemoryCacheDefaultMaximumSize = 3096LL * 1024LL;
DTMemoryCache * DTMemoryCacheDefaultCache = nil;



#pragma mark
#pragma mark
#pragma mark

@interface DTMemoryCache ( DTPrivate ) 

#pragma mark
#pragma mark Managing Cache Content 

- (void)deferredReduceCacheToSize:(DTCacheSize)aSize;
- (void)reduceCacheInSize:(NSTimer *)timer;
- (void)reduceCacheToSize:(DTCacheSize)aSize;
- (void)scheduleTimer;

@end



#pragma mark
#pragma mark
#pragma mark

@implementation DTMemoryCache

#pragma mark
#pragma mark NSObject: Creating, Copying, and Deallocating Objects

- (void)dealloc
{
	[self->reduceCacheSizeTimer invalidate];
	[self->reduceCacheSizeTimer release];
	self->reduceCacheSizeTimer = nil;
	
	[self->cacheEntries release], self->cacheEntries = nil;

	[super dealloc];
}

#pragma mark
#pragma mark
#pragma mark NSObject: Managing Reference Counts

- (void)release
{
	if ( DTMemoryCacheDefaultCache == self && 1 == [self retainCount] )
	{
#ifndef NS_BLOCK_ASSERTIONS
		[NSException
			raise:NSInternalInconsistencyException
			format:@"You may not release the default cache's instance."];
#endif
		return;
	}
	
	[super release];
}

#pragma mark
#pragma mark DTCache: Accessing the Cache

- (id)objectForKey:(NSString *)key
{
	NSData * result = nil;

	@synchronized ( self )
	{
		//
		// Check parameters.
		//
		
		if ( ![key isKindOfClass:[NSString class]] && ![key length] )
		{
#ifndef NS_BLOCK_ASSERTIONS
			[NSException
				raise:NSInvalidArgumentException
				format:@"key is expected to be a non-empty string." ];
#endif
			return nil;
		}

		//
		// Determine and return cache entry.
		//
		
		DTMemoryCacheEntry * const cacheEntry = [self->cacheEntries objectForKey:key];
		
		if ( !cacheEntry )
			return nil;
		
		NSDate * const expirationDate = cacheEntry.expirationDate;
		
		if ( 
			expirationDate 
			&& NSOrderedAscending == [expirationDate compare:[NSDate date]]
		)
		{
			self->size -= cacheEntry.size;
			[self->cacheEntries removeObjectForKey:key];
			return nil;
		}
		
		result = (NSData*)[[cacheEntry.object retain] autorelease];
	}
	
	return result;
}

- (void)setObject:(id)anObject forKey:(NSString *)key 
	expirationDate:(NSDate *)expirationDate
{
	@synchronized ( self )
	{
		//
		// Check parameters.
		//

		if ( ![key isKindOfClass:[NSString class]] && ![key length] )
		{
#ifndef NS_BLOCK_ASSERTIONS
			[NSException
				raise:NSInvalidArgumentException
				format:@"key is expected to be a non-empty string." ];
#endif
			return;
		}

		if ( anObject && ![anObject conformsToProtocol:@protocol( NSCoding )] )
		{
#ifndef NS_BLOCK_ASSERTIONS
			[NSException
				raise:NSInvalidArgumentException
				format:@"This cache only handles objects conforming to the "
					"NSCoding protocol."];
#endif
			return;
		}

		DTMemoryCacheEntry * const cacheEntry = [self->cacheEntries objectForKey:key];

		if ( !anObject && !cacheEntry )
			return;

		// If the data is too big we do not cache it.
		NSData * const objectAsData = 
			[NSKeyedArchiver archivedDataWithRootObject:anObject];
		
		if ( [objectAsData length] > self.maximumSize )
		{
			if ( cacheEntry )
			{
				self->size -= cacheEntry.size;
				[self->cacheEntries removeObjectForKey:key];
			}
		
			return;
		}
		
		//
		// Set data.
		//
		
		DTCacheSize const oldSizeOfData = cacheEntry.size;
		DTCacheSize const newSizeOfData = [objectAsData length];
		
		if ( anObject )
		// Updating or setting data.
		{
			if ( !cacheEntry )
			{
				DTMemoryCacheEntry * const newCacheEntry = [[DTMemoryCacheEntry alloc]
					initWithObject:anObject
					key:key
					expirationDate:expirationDate
					size:newSizeOfData];
					
				[self->cacheEntries 
					setObject:newCacheEntry
					forKey:key];
				
				[newCacheEntry release];
			}
			else 
			{
				[cacheEntry setObject:anObject ofSize:newSizeOfData];
				cacheEntry.expirationDate = expirationDate;
			}
		}
		else
		// Removing data.
		{
			[self->cacheEntries removeObjectForKey:key];
		}
		
		if ( oldSizeOfData > newSizeOfData )
			self->size -= oldSizeOfData - newSizeOfData;
		else
			self->size += newSizeOfData - oldSizeOfData;
		
		if ( self->size > self->maximumSize )
			[self deferredReduceCacheToSize:self->maximumSize];

		if ( anObject )
		{
			if (cacheEntry)
				DT_LOG(@"DT_MEMORY_CACHE", @"Updated cache entry, new size is %lld.", self->size)
			else
				DT_LOG(@"DT_MEMORY_CACHE", @"Added cache entry, new size is %lld.", self->size)
		}
		else
			DT_LOG(@"DT_MEMORY_CACHE", @"Removed cache entry, new size is %lld.", self->size)
	}
}


//!@}

#pragma mark
#pragma mark
#pragma mark DTCache: Obtaining Meta Data

- (NSUInteger)count
{
	NSUInteger result = 0;
	
	@synchronized ( self )
	{
		result = [self->cacheEntries count];
	}
	
	return result;
}

- (NSDate *)expirationDateForKey:(NSString *)key
{
	NSDate * result = nil;
	
	@synchronized( self )
	{
		result = [(DTMemoryCacheEntry *)[self->cacheEntries objectForKey:key] 
			expirationDate];
	}
	
	return result;
}

- (DTCacheSize)size
{
	return self->size;
}

//!@}

#pragma mark
#pragma mark
#pragma mark DTCache: Managing Cache Content

- (void)deferredReduceCacheToSize:(DTCacheSize)aSize
{
	@synchronized ( self )
	{
		if ( aSize > self->sizeToReduceCacheTo )
			self->sizeToReduceCacheTo = aSize;

		if ( self->reduceCacheSizeTimer )
			return;

		[self scheduleTimer];		
	}
}

- (void)reduceCacheInSize:(NSTimer *)timer
{
	if ( [NSThread currentThread] == [NSThread mainThread] )
	{
		// Do not block the main thread.
		[self 
			performSelectorInBackground:_cmd 
			withObject:nil];
	}
	else
	{
		NSAutoreleasePool * const autoreleasePool = [[NSAutoreleasePool alloc] init];
		
		@try
		{
			/*MEMemoryCacheLog( 
				@"Entered reduceCacheInSize:, reducing to %lld.", 
				self->sizeToReduceCacheTo );*/
			[self reduceCacheToSize:self->sizeToReduceCacheTo];
		}
		@finally 
		{
			[autoreleasePool release];
		}
	}
}

- (void)reduceCacheToSize:(DTCacheSize)aSize
{
	@synchronized ( self )
	{
		/*MEMemoryCacheLog( @"Entered reduceCacheToSize:, reducing to %lld.", aSize );*/
		
		NSSortDescriptor * const sortDescriptor = [[NSSortDescriptor alloc] 
			initWithKey:DTMemoryCacheEntryKeyDateOfLastAccess
			ascending:YES];
		
		NSArray * allCacheEntries = [self->cacheEntries allValues];
		NSArray * const cacheEntriesSortedByDateOfLastAccess = [allCacheEntries
				sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[sortDescriptor release];

		DTMemoryCacheEntry * cacheEntry = nil;
		NSEnumerator * const cacheEntryEnumerator = 
			[cacheEntriesSortedByDateOfLastAccess objectEnumerator];
			
		while (
			( self->size > aSize ) 
			&& ( cacheEntry = [cacheEntryEnumerator nextObject] )
		)
		{
			self->size -= cacheEntry.size;
			/*DTMemoryCacheLog( 
				@"Reducing cache size about %lld bytes, size is now %lld (> %lld).", 
				cacheEntry.size, 
				self->size,
				aSize );*/
			
			NSString * const key = cacheEntry.key;
			
			if ( [self->cacheEntries objectForKey:key] )
				[self->cacheEntries removeObjectForKey:cacheEntry.key];
		}

		[self->reduceCacheSizeTimer invalidate];
		[self->reduceCacheSizeTimer release];
		self->reduceCacheSizeTimer = nil;
		self->sizeToReduceCacheTo = 0LL;
	}
}

- (void)scheduleTimer
{
	@synchronized ( self )
	{
		if ( [NSThread currentThread] != [NSThread mainThread] )
		{
			[self 
				performSelectorOnMainThread:@selector( scheduleTimer ) 
				withObject:nil
				waitUntilDone:NO];
		}
		else 
		{
			if ( !self->reduceCacheSizeTimer )
			{
				NSDate * const fireDate = [NSDate dateWithTimeIntervalSinceNow:
					DTMemoryCacheReduceSizeTimeInterval];

				self->reduceCacheSizeTimer = [[NSTimer alloc] 
					initWithFireDate:fireDate
					interval:0.0 
					target:self
					selector:@selector( reduceCacheInSize: )
					userInfo:nil
					repeats:NO];
				
				[[NSRunLoop currentRunLoop] 
					addTimer:self->reduceCacheSizeTimer
					forMode:NSDefaultRunLoopMode];
			}
		}
	}
}

#pragma mark -

- (void)clear
{
	@synchronized ( self )
	{
		[self->cacheEntries removeAllObjects];
		self->size = 0LL;
	}
}

- (DTCacheSize)maximumSize
{
	return self->maximumSize;
}

- (void)setMaximumSize:(DTCacheSize)newMaximumSize
{
	@synchronized ( self )
	{
		self->maximumSize = newMaximumSize;
	
		if ( self->size > self->maximumSize )
			[self reduceCacheToSize:self->maximumSize];
	}
}

#pragma mark
#pragma mark
#pragma mark Initialisation

- (id)initWithMaximumSize:(DTCacheSize)aMaximumSize
{
	if ( (self = [super init]) )
	{
		self->cacheEntries = [NSMutableDictionary new];
		self->maximumSize = aMaximumSize;
	}
	
	return self;
}

#pragma mark
#pragma mark
#pragma mark Accessing the Default Cache

+ (DTMemoryCache *)defaultCache
{
	if ( !DTMemoryCacheDefaultCache )
		DTMemoryCacheDefaultCache = [[DTMemoryCache alloc] 
			initWithMaximumSize:DTMemoryCacheDefaultMaximumSize];

	return DTMemoryCacheDefaultCache;
}

@end
