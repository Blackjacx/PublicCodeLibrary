/*!
 \file		DTFileCache.m
 \brief		Classdefinition for the file based caching if DTRESTCommand 
	results.
 \details  Implements the DTCache interface for general cache handling. 
 \remarks Refactored to DTLibrary November 2010
 \attention Copyright 2009 Deutsche Telekom AG. All rights reserved.
 \author	Said El Mallouki
 \author    Pierre Bongen
 \author    Stefan Herold
 \date		2009-02-18
*/
#import "DTFileCache.h"
#import "DTFileCache_private.h"

#import "DTStrings.h"
#import "DTCacheEntry.h"
#import "DTDebugging.h"

/**
 @todo make dynamic (stherold - 2012-07-24)
 */

/*!
	\brief Name of the cache directory.

	The cache directory contains the cached data stored in files. It resides
	within the application's Documents directory.
*/	
DT_DEFINE_STRING( MEFileCacheRoot, "DTFileCache" );

//!@}


/*!
	\name Cache Constants

	@{
*/

NSTimeInterval const MEWeekInSeconds = 604800.0;

/*!
	\brief The maximum size of the cache in bytes (50 MiBytes).
*/
DTCacheSize const MEFileCacheMaximumCacheSizeInBytes = 52428800;

//!@}



static NSDateFormatter *MEFileCacheDateFormatter = nil;
static DTFileCache * MEFileCacheSharedInstance = nil;


DT_DEFINE_KEY_WITH_VALUE( DTCacheEntryKeyLocalFilename, "localFilename" );
DT_DEFINE_KEY_WITH_VALUE( DTCacheEntryKeyKey, "key" );
DT_DEFINE_KEY_WITH_VALUE( DTCacheEntryKeyExpirationDate, "expirationDate" );
DT_DEFINE_KEY_WITH_VALUE( DTCacheEntryKeyLastRead, "lastRead" );
DT_DEFINE_KEY_WITH_VALUE( DTCacheEntryKeyCreateDate, "createDate" );
DT_DEFINE_KEY_WITH_VALUE( DTCacheEntryKeyModifiedDate, "modifiedDate" );
DT_DEFINE_KEY_WITH_VALUE( DTCacheEntryKeySize, "size" );


DT_DEFINE_STRING( DTFileCacheNameOfArchiveOfCacheEntries, "cacheEntries.archive" );


NSTimeInterval const MEFileCacheFlushTimerInterval = 5.0;



// MARK: 
// MARK: -
// MARK: 

@implementation DTCacheEntry

@synthesize localFilename;
@synthesize key;
@synthesize expirationDate;
@synthesize lastRead;
@synthesize	createDate;
@synthesize modifiedDate;

// MARK: 
// MARK: NSObject: Creating, Copying, and Deallocating Objects

- (void)dealloc
{
	self.localFilename = nil;
	self.key = nil;
	self.expirationDate = nil;
	self.lastRead = nil;
	self.createDate = nil;
    self.modifiedDate = nil;
    
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ { localFilename = %@, lastRead = %@, key = %@",
		[super description],
		self.localFilename,
		self.lastRead,
		self.key];
}

// MARK: 
// MARK: NSCoding: Initializing with a Coder

- (id)initWithCoder:(NSCoder *)decoder
{
	if ( (self = [super init]) )
	{
		self.localFilename = [decoder decodeObjectForKey:DTCacheEntryKeyLocalFilename];
		self.key = [decoder decodeObjectForKey:DTCacheEntryKeyKey];
		self.expirationDate = [decoder decodeObjectForKey:DTCacheEntryKeyExpirationDate];
		self.lastRead = [decoder decodeObjectForKey:DTCacheEntryKeyLastRead];
		self.createDate = [decoder decodeObjectForKey:DTCacheEntryKeyCreateDate];
        self.modifiedDate = [decoder decodeObjectForKey:DTCacheEntryKeyModifiedDate];
		
		NSNumber * const sizeAsNumber = [decoder decodeObjectForKey:DTCacheEntryKeySize];
		
		self.size = sizeAsNumber
			? [sizeAsNumber unsignedLongLongValue]
			: DTCacheSizeMax;
	}
	
	return self;
}

- (id)initWithKey:(NSString *)aKey expirationDate:(NSDate *)anExpirationDate size:(DTCacheSize)aSize
{
	@try 
	{
		if ( ![aKey isKindOfClass:[NSString class]] || ![aKey length] )
			[NSException 
				raise:NSInvalidArgumentException
				format:@"aKey must not be empty."];
		
		if ( anExpirationDate && ![anExpirationDate isKindOfClass:[NSDate class]] )
			[NSException
				raise:NSInvalidArgumentException
				format:@"Expected expirationDate to be of kind NSDate."];

		if ( (self = [super init]) )
		{
			self.createDate = [NSDate date];
            self.modifiedDate = self.createDate;
			self.lastRead = self.createDate;
			self.expirationDate = anExpirationDate;
			self.key = aKey;
			self.size = aSize;
			
			//
			// Create unique localFilename using an UUID. 
			//
			
			CFUUIDRef UUID = CFUUIDCreate( NULL );
			CFStringRef UUIDAsString = CFUUIDCreateString( NULL, UUID );
			self.localFilename = [(NSString *)UUIDAsString retain];
			CFRelease( UUID );
			CFRelease( UUIDAsString );
		}
	}
	@catch ( NSException *e ) 
	{
		[self release], self = nil;
#if defined( DEBUG ) && DEBUG == 1
		@throw;
#endif
	}
	
	return self;
}

// MARK: 
// MARK: NSCoding: Encoding with a Coder

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if ( self.localFilename )
		[encoder encodeObject:self.localFilename forKey:DTCacheEntryKeyLocalFilename];

	if ( self.key )
		[encoder encodeObject:self.key forKey:DTCacheEntryKeyKey];
	
	if ( self.expirationDate )
		[encoder encodeObject:self.expirationDate forKey:DTCacheEntryKeyExpirationDate];
	
	if ( self.lastRead )
		[encoder encodeObject:self.lastRead forKey:DTCacheEntryKeyLastRead];
	
	if ( self.createDate )
		[encoder encodeObject:self.createDate forKey:DTCacheEntryKeyCreateDate];
    
    if ( self.modifiedDate )
		[encoder encodeObject:self.createDate forKey:DTCacheEntryKeyModifiedDate];
	
	[encoder 
		encodeObject:[NSNumber numberWithUnsignedLongLong:self.size]
		forKey:DTCacheEntryKeySize];
}

// MARK: 
// MARK: Getting the Entry's Size

- (DTCacheSize)size
{	
	return self->size;
}

- (void)setSize:(DTCacheSize)newSize
{
	self->size = newSize;
}

@end




// MARK: 
// MARK: 

@implementation DTFileCache

// MARK: 
// MARK: 

@synthesize cachePath = _cachePath;

// MARK: 
// MARK: NSObject: Creating, Copying, and Deallocating Objects

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self flush];

	[self->cacheEntries release], self->cacheEntries = nil;

	[self->_cachePath release];
	self->_cachePath = nil;
	
	[self->_error release];
	self->_error = nil;
		
	[super dealloc];
}

// MARK: 
// MARK: DTCache: Accessing the Cache

- (id)objectForKey:(NSString *)key
{
	NSData * result = nil;

	@synchronized ( self )
	{
		if ( ![key isKindOfClass:[NSString class]] || ![key length] )
		{
#if defined( DEBUG ) && DEBUG == 1
			[NSException
				raise:NSInvalidArgumentException
				format:@"key must not be empty."];
#endif
			return result;
		}

		DTCacheEntry * const cacheEntry = [self->cacheEntries objectForKey:key];

		if ( cacheEntry )
		{
			if ( !cacheEntry.expirationDate )
			// Only update date of last access if the cache entry has no
			// explicit expiration date.
			{
				cacheEntry.lastRead = [NSDate date];

				DT_LOG(@"DT_FILE_CACHE", @"Cache hit for key %@", cacheEntry.key );

				result = [[[self readFileWithFilename:cacheEntry.localFilename] retain] autorelease];

				[self setNeedsFlush];
			}
			else if ( 0 > [cacheEntry.expirationDate timeIntervalSinceNow] )
			// The cache entry has expired. Remove it.
			{
				DT_LOG(@"DT_FILE_CACHE",
					@"The cache entry with key %@ has expired. expirationDate: %@, now: %@", 
					cacheEntry.key,
					cacheEntry.expirationDate, 
					[NSDate date] );
					
				[self setObject:nil forKey:key expirationDate:nil];
			}
			else
			{
				DT_LOG(@"DT_FILE_CACHE", @"Cache hit for key %@", cacheEntry.key );
				result = [[[self readFileWithFilename:cacheEntry.localFilename] retain] autorelease];
			}
		}
	}
	
	return result;
}

- (void)setObject:(id)anObject forKey:(NSString *)key expirationDate:(NSDate *)expirationDate
{	
	@synchronized ( self )
	{
		if ( anObject && ![anObject isKindOfClass:[NSData class]] )
		{
#if defined( DEBUG ) && DEBUG == 1
			[NSException
				raise:NSInvalidArgumentException
				format:@"This cache handles only objects of the NSData class."];
#endif
			return;
		}

		NSData * objectAsData = (NSData *)anObject;

		if ( 0 == [key length] )
		{
	#if defined( DEBUG ) && DEBUG == 1
			[NSException
				raise:NSInvalidArgumentException
				format:@"key must not be empty."];
	#endif
			return;
		}

		DTCacheEntry * cacheEntry = [self->cacheEntries objectForKey:key];

		if ( !cacheEntry )
		// There is no data for the given key contained by the cache.
		{
			if ( anObject )
			{
				cacheEntry = [[[DTCacheEntry alloc]
					initWithKey:key
					expirationDate:expirationDate
					size:[objectAsData length]] autorelease];
					
				[self->cacheEntries setObject:cacheEntry forKey:key];
				
				[self writeData:objectAsData withFilename:cacheEntry.localFilename refresh:NO];					
				[self setNeedsFlush];
				
				if( expirationDate ) {
					DT_LOG(@"DT_FILE_CACHE", @"Added new cache entry for key %@ with expirationDate %@.", key, expirationDate );
				}
				else {
					DT_LOG(@"DT_FILE_CACHE", @"Added new cache entry for key %@.", key);
				}
				
				[self cacheSizePlusValue:[objectAsData length]];
			}
		}
		else
		// There is already data stored in the cache for the given key. Update it.
		{
			DTCacheSize const oldSizeOfCacheEntry = cacheEntry.size;
			DTCacheSize newSizeOfCacheEntry = 0;

			if ( objectAsData )
			// --- Data probably changed.
			{
				[self writeData:objectAsData withFilename:cacheEntry.localFilename refresh:YES];
				
				cacheEntry.expirationDate = expirationDate;
				newSizeOfCacheEntry = [objectAsData length];
				cacheEntry.size = newSizeOfCacheEntry;
                cacheEntry.modifiedDate = [NSDate date];

				if( expirationDate ) {
					DT_LOG(@"DT_FILE_CACHE", @"Updated cache entry for key %@ with expirationDate %@.", key, expirationDate );
				}
				else {
					DT_LOG(@"DT_FILE_CACHE", @"Updated cache entry for key %@.", key);
				}
			}
			else
			// --- Remove data from cache
			{
				if( cacheEntry.expirationDate ) {
					DT_LOG(@"DT_FILE_CACHE", @"Removing cache entry for key %@ with expirationDate %@.", key, cacheEntry.expirationDate );
				}
				else {
					DT_LOG(@"DT_FILE_CACHE", @"Removing cache entry for key %@.", key);
				}
				
				[self deleteFile:cacheEntry.localFilename];
				[self->cacheEntries removeObjectForKey:cacheEntry.key];
			}
			
			// --- Flush data
			[self setNeedsFlush];
			
			// --- Update cache size.
			// --- Pay special attention to unsigned integer behaviour.
			// --- Don't calculate the value in one step - overflow may happen if newSize < oldSize!
			// --- self->size += newSizeOfCacheEntry - oldSizeOfCacheEntry;
			[self cacheSizePlusValue:newSizeOfCacheEntry];
			[self cacheSizeMinusValue:oldSizeOfCacheEntry];
			
			DT_LOG( @"DT_FILE_CACHE", @"Cache size is now %llu.", self.size );
		}
	
		if ( self.maximumSize < self.size )
			[self reduceCacheSizeTo:self.maximumSize];	

	} // synchronized
}

// MARK: 
// MARK: DTCache: Obtaining Meta Data

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

	@synchronized ( self )
	{	
		if ( [key isKindOfClass:[NSString class]] && [key length] )
			result = [[[[self->cacheEntries objectForKey:key] expirationDate] retain] autorelease];
	}
	
	return result;
}

- (DTCacheSize)size
{
	DTCacheSize result = 0;
	
	@synchronized ( self )
	{
		if ( DTCacheSizeMax == self->size )
		{
			self->size = 0;

			NSArray * const allCacheEntries = [self->cacheEntries allValues];
			
			for ( DTCacheEntry *cacheEntry in allCacheEntries )
			{
				[self cacheSizePlusValue:cacheEntry.size];
			}
		}
		result = self->size;
	}
	return result;
}

- (BOOL)cacheSizePlusValue:(DTCacheSize)aValue
{
	BOOL result;
	
	@synchronized( self )
	{
		if( ( DTCacheSizeMax - self.size ) < aValue )
		{
			self->size = DTCacheSizeMax;
			result = NO;
		}
		else 
		{
			self->size += aValue;
			result = YES;
		}
	}
	return result;
}

- (BOOL)cacheSizeMinusValue:(DTCacheSize)aValue
{
	BOOL result;
	
	@synchronized( self )
	{
		if( self.size < aValue )
		{
			self->size = 0;
			result = NO;
		}
		else 
		{
			self->size -= aValue;
			return YES;
		}
	}	
	return result;
}

- (NSDate*) modifiedDateForKey:(NSString*) key
{
    DTCacheEntry * cacheEntry = [self->cacheEntries objectForKey:key];
    if(cacheEntry && cacheEntry.modifiedDate)
    {
        return cacheEntry.modifiedDate;
    }
    return nil;
}


// MARK: 
// MARK: DTCache: Managing Cache Content

- (void)clear
{
	@synchronized ( self )
	{
		NSAutoreleasePool * const autoreleasePool = [NSAutoreleasePool new];

		@try
		{
			NSFileManager * const fileManager = [NSFileManager defaultManager];
			
			if ( [fileManager fileExistsAtPath:self.cachePath] ) 
			{
                DT_LOG(@"DT_FILE_CACHE", @"CLEAR Cache ...");
                
				// delete cachedirectory and all files
				[fileManager 
					removeItemAtPath:self.cachePath 
					error:NULL];
					
				// Recreate CacheDirectory: 		
				[fileManager 
					createDirectoryAtPath:self.cachePath
					withIntermediateDirectories:NO
					attributes:nil 
					error:NULL];
				
				/**
				 @todo Do something with the error. (stherold - 2012-07-24)
				 */

				self->_error = nil;
			}
			self->size = DTCacheSizeMax;

			[self->cacheEntries removeAllObjects];
		}
		@catch ( NSException *e ) 
		{
			// Intentionally drop exception.
#if defined( DEBUG ) && DEBUG == 1
			@throw;
#endif
		}
		@finally 
		{
			[autoreleasePool release];
		}
	}
}

- (DTCacheSize)maximumSize
{
	return self->maximumSize;
}


- (void)setMaximumSize:(DTCacheSize)newMaximumSize
{
		if ( self->maximumSize == newMaximumSize )
			return;

		self->maximumSize = newMaximumSize;

		//[self reduceCacheSizeTo:self->maximumSize];
}


// MARK: 
// MARK: Initialisation

- (id)initWithCacheReset:(BOOL)resetCache 
{
	NSFileManager * const fileManager = [NSFileManager defaultManager];

	if ( (self = [super init]) )
	{
		self->maximumSize = MEFileCacheMaximumCacheSizeInBytes;
		self->size = DTCacheSizeMax;

		[[NSNotificationCenter defaultCenter] 
			addObserver:self
			selector:@selector( applicationWillTerminate: )
		/**
		 @todo  This is a hack: The cache should be independent of the UIKit but
		 also should react upon termination. This should be replaced with
		 some POSIX compliant stuff.
		
		 (stherold - 2012-07-24)
		 */

		 	name:@"UIApplicationWillTerminateNotification"
			object:nil];

		if ( ![self loadCacheEntries] )
			self->cacheEntries = [NSMutableDictionary new];
		
		if ( [fileManager fileExistsAtPath:self.cachePath] ) 
		{ 
			// delete cache, because we want to recreate a fresh one.
			if ( resetCache )
			{
				[self 
					performSelectorInBackground:@selector( clear ) 
					withObject:nil];
			}
			else
			{
                /* 
                 @todo 
                 
                 Method "cleanupStalledFiles" is a big performance killer. 
                 It runs on main thread (although is called with "performSelectorInBackground")
                 
                 Why are there stalled files? 
                 I debugged the cleanup loop but there was never a found a stalled file.
                 But the search for those files is very cpu intensive and blocks the starting process of the app.
                 
                 
                 TODO: FIgure Out why we have to deal with stalled files. Can we avoid them? If not, put the cleaup method on background thread.
                 
                  (mwittkowski - 2012-11-08)
                 
                [self
					performSelectorInBackground:@selector( cleanupStalledFiles )
					withObject:nil];
                 */
               
			}
		} 
		else
		{
			BOOL const success = [fileManager 
				createDirectoryAtPath:self.cachePath
				withIntermediateDirectories:NO
				attributes:nil 
				error:&self->_error]; 

			if ( success )
			{
				[self 
					performSelectorInBackground:@selector( clear ) 
					withObject:nil];
			}
			else 
			{
				[self release], self = nil;
			}
		}
	}
	return self;
}

+ (DTFileCache *)sharedCache 
{
	@synchronized ( self )
	{
		if ( MEFileCacheSharedInstance == nil)
		{
			MEFileCacheSharedInstance = [[DTFileCache alloc] initWithCacheReset:NO];
		}
	}
	
	return MEFileCacheSharedInstance;
}

// MARK: 
// MARK: Obtaining Meta Data

- (NSString *)localFilenameForKey:(NSString *)key
{
	NSString * result = nil;

	@synchronized ( self )
	{
		if ( [key isKindOfClass:[NSString class]] && [key length] )
		{
			DTCacheEntry * const cacheEntry = [self->cacheEntries objectForKey:key];
			result = [[cacheEntry.localFilename retain] autorelease];
			
			if ( cacheEntry && ( ( result && ![self fileExists:result] ) || !result ) )
			{
				[self deleteFile:cacheEntry.localFilename];
				[self->cacheEntries removeObjectForKey:key];
			}
		}
	} // synchronized
	
	return result;
}



// MARK: 
// MARK: Managing Cache Content

- (void) removeCacheEntryForKey: (NSString*) key
{
    NSString * localFileName = [self localFilenameForKey: key];
    NSString * const cachePath = self.cachePath;
    
    DT_LOG(@"DT_FILE_CACHE", @"localFileName=%@ cachePath=%@" , localFileName, cachePath);
    
    if ( [self entryExistsForLocalFilename:localFileName] )
    {
        @try 
		{
            DT_LOG(@"DT_FILE_CACHE",@",,, entryExistsForLocalFilename");
            NSString * const absolutePath = 
            [cachePath stringByAppendingPathComponent:localFileName];
            
            NSFileManager * const fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:absolutePath error:&self->_error];
        }
        @catch ( NSException *e ) 
        {
            // Intentionally drop exception.
#if defined( DEBUG ) && DEBUG == 1
            @throw;
#endif
        }
    }
}


- (NSInteger)cleanupStalledFiles
{
	NSInteger result = 0;

	@synchronized( self )
	{
		NSAutoreleasePool * const pool = [[NSAutoreleasePool alloc] init];
		
		@try 
		{
			NSFileManager * const fileManager = [NSFileManager defaultManager];
			NSString * const cachePath = self.cachePath;
			NSString * filename = nil;		
			
			NSDirectoryEnumerator * const directoryEnumerator = 
				[fileManager enumeratorAtPath:cachePath];
			
			while ( (filename = [directoryEnumerator nextObject]) ) 
			{
				// for each file check for existence in the database: 
				if ( ![self entryExistsForLocalFilename:filename] )
				{
					NSString * const absolutePath = 
						[cachePath stringByAppendingPathComponent:filename];
						
					[fileManager removeItemAtPath:absolutePath error:&self->_error];
					result ++;
					
					/**
					 @todo Do something with the error. (stherold - 2012-07-24)
					 */

					
					self->_error = nil;
				}
			}		
		}
		@catch ( NSException *e ) 
		{
			// Intentionally drop exception.
#if defined( DEBUG ) && DEBUG == 1
			@throw;
#endif
		}
		@finally 
		{
			[pool release];
		}
	}
	
	return result;
}

// MARK: 
// MARK: Pathes (private)

- (NSString *)cachePath 
{
	@synchronized ( self )
	{
		if ( !self->_cachePath ) 
		{
			NSArray * const paths = NSSearchPathForDirectoriesInDomains(
				NSCachesDirectory, 
				NSUserDomainMask, 
				YES );
			
			if ( [paths count] )
				self->_cachePath = [[[paths objectAtIndex:0] 
					stringByAppendingPathComponent:MEFileCacheRoot] copy];
		}
	}
	
	return self->_cachePath;
}

// MARK: 
// MARK: Converting Dates (private)

+ (NSDateFormatter *)dateFormatter
{
	@synchronized ( self )
	{
		if ( !MEFileCacheDateFormatter ) 
		{
			MEFileCacheDateFormatter = [[NSDateFormatter alloc] init];

			/**
			 @todo Why not use a standard format, such as YYYY-MM-dd HH:mm:ss ±ZZZZ ? (stherold - 2012-07-24)
			 */

			[MEFileCacheDateFormatter setDateFormat:@"YYYY-MM-dd_HH_mm_ss_SSS"];
		}
	}
	
	return MEFileCacheDateFormatter;
}

// MARK: 
// MARK: Managing Data Files (private)

- (BOOL)deleteFile:(NSString *)filename 
{
	BOOL result = NO;
	
	@synchronized ( self )
	{
		NSString * const absolutePath = [self.cachePath stringByAppendingPathComponent:filename];
		NSFileManager * const fileManager = [NSFileManager defaultManager];
		
		if ( [fileManager fileExistsAtPath:absolutePath] ) 
		{
			result = [fileManager removeItemAtPath:absolutePath error:NULL];
		} 
	}
	
	return result;
}

- (BOOL)fileExists:(NSString *)filename
{
	BOOL result = NO;
	
	@synchronized ( self )
	{
		NSString * const absolutePath = [self.cachePath stringByAppendingPathComponent:filename];
		result = [[NSFileManager defaultManager] fileExistsAtPath:absolutePath];
	}
	
	return result;	
}

- (NSData *)readFileWithFilename: (NSString *) filename 
{
	NSData * result = nil;

	@synchronized ( self )
	{
		NSString * dataPath = [self.cachePath stringByAppendingPathComponent:filename];
		result = [[NSFileManager defaultManager] contentsAtPath:dataPath];
	}
	
	return result;
}

- (NSString *)writeData:(NSData *)data withFilename:(NSString *)filename refresh:(BOOL)doRefresh 
{
	NSString *result = nil;
	
	@synchronized ( self )
	{
		NSString *dataPath = [self.cachePath stringByAppendingPathComponent:filename];

		if ( ![[NSFileManager defaultManager] fileExistsAtPath:dataPath] || doRefresh ) 
		{
			if ( [[NSFileManager defaultManager] createFileAtPath:dataPath contents:data attributes:nil] )
				result = dataPath;
		}
	}
	
	return result;
}

// MARK: 
// MARK: Accessing Cache Entries (private)

- (NSString *)absolutePathToArchiveOfCacheEntries
{
	NSString * result = nil;
	
	@synchronized ( self )
	{
		NSArray * const paths = NSSearchPathForDirectoriesInDomains(
			NSCachesDirectory, 
			NSUserDomainMask, 
			YES );
		
		if ( [paths count] )
		{
			result = [[paths objectAtIndex:0] 
				stringByAppendingPathComponent:DTFileCacheNameOfArchiveOfCacheEntries];
		}
	}
	
	return result;
}

- (DTCacheEntry *)cacheEntryForKey:(NSString *)key
{
	DTCacheEntry * result = nil;
	
	@synchronized ( self )
	{ 
		result = [[[self->cacheEntries objectForKey:key] retain] autorelease];
	}
	
	return result;
}

- (BOOL)entryExistsForLocalFilename:(NSString *)localFilename
{
	BOOL result = NO;

	@synchronized ( self )
	{
		if ( ![localFilename isKindOfClass:[NSString class]] )
			return result;

		NSPredicate * const predicate = [NSPredicate 
			predicateWithFormat:@"%K == %@", 
				DTCacheEntryKeyLocalFilename,
				localFilename];

		NSArray * const allCacheEntries = [self->cacheEntries allValues];
		NSArray * const filteredCacheEntries = [allCacheEntries 
			filteredArrayUsingPredicate:predicate];
			
		result = [filteredCacheEntries count] ? YES : NO;
	}
	
	return result;
}

- (DTCacheSize)reduceCacheSizeTo:(DTCacheSize)newSize
{
	DTCacheSize currentSize = self.size;
	DTCacheSize reducedSize = 0;
	
	if( currentSize < newSize )
	{
		// Nothing to do
		return reducedSize;
	}
	
	DT_LOG(@"DT_FILE_CACHE", @"CacheSizeSTART: %llu   REDUCE_TO: %llu", currentSize, newSize);

	NSSortDescriptor * const sortDescriptor = [[NSSortDescriptor alloc] 
		initWithKey:DTCacheEntryKeyLastRead ascending:YES];

	NSArray * const cacheEntriesSortedByLastRead = [[self->cacheEntries allValues]
		sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

	[sortDescriptor release];

	DTCacheEntry * cacheEntry = nil;
	NSEnumerator * const cacheEntryEnumerator = 
		[cacheEntriesSortedByLastRead objectEnumerator];
	
	while ( ( currentSize > newSize ) && 
			( cacheEntry = [cacheEntryEnumerator nextObject] ) )
	{
		if ( [self deleteFile:cacheEntry.localFilename] )
		{
			DTCacheSize cacheEntrySize = cacheEntry.size;
			
			[self->cacheEntries removeObjectForKey:cacheEntry.key];

			DT_LOG(@"DT_FILE_CACHE", @"Calculation: %llu - %llu", currentSize, cacheEntrySize);

			/**
			 @todo  cacheEntrySize is sometimes by '1' bigger than currentSize.
			 Then overflow happens in currentSize. Find out why!
			
			 (stherold - 2012-07-24)
			 */

			if( currentSize < cacheEntrySize )
				currentSize = 0;
			else
				currentSize -= cacheEntrySize;
												
			DT_LOG(@"DT_FILE_CACHE", @"\t\t\t= %llu", currentSize);
			
			reducedSize += cacheEntry.size;
		}
	}
	
#if defined( DEBUG ) && DEBUG == 1
	static BOOL alertActive = YES;
	if( currentSize > 10000000000000 && alertActive )
	{	
		alertActive = NO;
		NSString *message = [NSString stringWithFormat:@"Max: %llu\nCurrent: %llu\nself->size: %llu \n%@", DTCacheSizeMax, currentSize, self->size, [NSThread callStackSymbols]];
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cache Sizes" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
#endif

	DT_LOG(@"DT_FILE_CACHE", @"CacheSizeEND: %llu REDUCED: %llu", currentSize, reducedSize);
	
	if ( reducedSize > 0 )
	{
		[self cacheSizeMinusValue:reducedSize];
		[self setNeedsFlush];
	}
	
	return reducedSize;
}

// MARK: 
// MARK: 

- (void)flushTimerMethod:(NSTimer *)timer
{
	[self flush];
}

- (void)setNeedsFlush
{
	@synchronized ( self )
	{
		if ( self->flushTimer )
			return;
	
		self->flushTimer = [[NSTimer 
			alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:MEFileCacheFlushTimerInterval] 
			interval:0 
			target:self 
			selector:@selector ( flushTimerMethod: ) 
			userInfo:nil repeats:NO];
			
		[[NSRunLoop mainRunLoop] 
			addTimer:self->flushTimer 
			forMode:NSDefaultRunLoopMode]; 
	}
}

- (BOOL)loadCacheEntries
{
	BOOL result = NO;

	@synchronized ( self ) 
	{
		[self->cacheEntries release];
		self->cacheEntries = [[NSKeyedUnarchiver 
			unarchiveObjectWithFile:[self absolutePathToArchiveOfCacheEntries]] retain];
	
		result = self->cacheEntries ? YES : NO;
	}
	
	return result;
}

- (BOOL)saveCacheEntries
{
	BOOL result = NO;

	@synchronized ( self )
	{
		if ( self->cacheEntries )
		{
			result = [NSKeyedArchiver 
				archiveRootObject:self->cacheEntries 
				toFile:[self absolutePathToArchiveOfCacheEntries]];
		}
	}
	
	return result;
}

- (void)updateLastAccessForLocalFilename:(NSString *)localFilename
{
	@synchronized ( self )
	{
		NSPredicate * const localFilenamePredicate = [NSPredicate 
			predicateWithFormat:@"%K == %@",
			localFilename];

		NSArray * const cacheEntriesForLocalFilename = [[self->cacheEntries allValues]
			filteredArrayUsingPredicate:localFilenamePredicate];
		
		for ( DTCacheEntry * cacheEntry in cacheEntriesForLocalFilename )
		{
			cacheEntry.lastRead = [NSDate date];
		}
	}
}

- (void)updateLastAccessForKey:(NSString *)key 
{
	@synchronized ( self )
	{
		DTCacheEntry * const cacheEntry = [self->cacheEntries objectForKey:key];
		cacheEntry.lastRead = [NSDate date];
	}
}

// MARK: 
// MARK: DTCache: Supporting Persistence

- (void)flush
{
    DT_LOG(@"DT_FILE_CACHE", @"FLUSH ...");
    
	@synchronized ( self )
	{
		if ( self->flushTimer )
			[self->flushTimer release], self->flushTimer = nil;

		[self saveCacheEntries];
	}
}

// MARK: 
// MARK: Handling Notifications

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self flush];
}

@end
