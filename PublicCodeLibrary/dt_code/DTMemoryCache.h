//
//  MEMemoryCache.h
//  IphoneEPG
//
//  Created by Pierre Bongen on 05.02.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTCache.h"



/*!
	\brief Memory cache solely residing in memory.
	\see DTCache, MEFileCache, MEMemoryCacheEntry.
*/
@interface DTMemoryCache : NSObject < DTCache >
{
@private
	/*!
		\brief Stores the cache entries.
		
		The keys used in this dictionary correspond to those keys used when
		calling setData:forKey:expirationDate:(). The values are 
		MEMemoryCacheEntry objects.
	*/
	NSMutableDictionary *cacheEntries;
	
	/*!
		\brief The overall size of the memory the data objects consume as number
			of bytes.
	*/
	DTCacheSize size;
	
	/*!
		\brief The maximum size the cache's content may grow to.
	*/
	DTCacheSize maximumSize;
	
	/*!
		\brief Timer used to defer the actual call of reduceCacheSizeTo:().
	*/
	NSTimer *reduceCacheSizeTimer;
	DTCacheSize sizeToReduceCacheTo;
}

#pragma mark

@property ( assign ) DTCacheSize maximumSize;
@property ( assign, readonly ) DTCacheSize size;

#pragma mark
#pragma mark NSObject: Creating, Copying, and Deallocating Objects

- (void)dealloc;

#pragma mark
#pragma mark
#pragma mark NSObject: Managing Reference Counts

/*!
	\brief Implementation of the release method which is aware of the default
		cache instance.
	\see defaultCache().

	This method guarantees that the default cache instance is not released.
*/
- (void)release;

#pragma mark
#pragma mark DTCache: Accessing the Cache

/*!
	\name DTCache: Accessing the Cache

	@{
*/

- (id)objectForKey:(NSString *)key;

/*!
	\note \c object and \c key are exepcted to be their immutable variants if
		applicable. It is regarded a programmer's error if a 
		mutable variant is passed as paramater to this method. Since creating 
		copies has a severe impact on the cache's performance, no copies are 
		made of the objects \c object and \c key point to.
*/
- (void)setObject:(id)object forKey:(NSString *)key 
	expirationDate:(NSDate *)expirationDate;

//!@}

#pragma mark
#pragma mark
#pragma mark DTCache: Obtaining Meta Data

/*!
	\name DTCache: Obtaining Meta Data
	
	@{
*/

- (NSUInteger)count;
- (NSDate *)expirationDateForKey:(NSString *)key;
- (DTCacheSize)size;

//!@}

#pragma mark
#pragma mark
#pragma mark DTCache: Managing Cache Content

/*!
	\name Managing Cache Content
	
	@{
*/

- (void)clear;
- (DTCacheSize)maximumSize;
- (void)setMaximumSize:(DTCacheSize)maximumSize;

//!@}

#pragma mark
#pragma mark
#pragma mark Initialisation

/*!
	\name Initialisation
	
	@{
*/

- (id)initWithMaximumSize:(DTCacheSize)aMaximumSize;

//!@}

#pragma mark
#pragma mark
#pragma mark Accessing the Default Cache

/*!
	\name Accessing the Default Cache

	@{
*/

+ (DTMemoryCache *)defaultCache;

//!@}

@end
