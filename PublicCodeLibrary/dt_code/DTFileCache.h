/*!
 \file		DTFileCache.h
 \brief		Classdefinition for the file based caching if DTRESTCommand 
	results.
 \details  Implements the DTCache interface for general cache handling. 
 \attention Copyright 2009 Deutsche Telekom AG. All rights reserved.
 \author	Said El Mallouki
 \date		2009-02-18
*/
#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "DTCache.h"

// This is the default if nothing has been defined.
#ifndef DTCACHE_USES_PREDICATES
#define DTCACHE_USES_PREDICATES 1
#endif


/**
 @todo Make Cocoa like singleton of it or drop singleton status. (stherold - 2012-07-24)
 */

/*!
	\brief Provides caching services implemented as singleton.
	
	The cache accepts arbitrary data with an unique key identifying the data.
	The keys are NSString objects which may have any value except an empty
	string.
	
	Usually, the data is removed from the cache if a customisable maximum age
	value is exceeded. This mechanism is bypassed though if the cache client
	explicitly provides an expiration date.
	
	The cached data is stored in a directory as files managed by the MEFileCache
	object. The catalogue used for cache entry tracking is stored in a SQLite
	database.
	
	The MEFileCache object is able to identify older versions of the tables used
	to manage the cache data. If it detects an old version, the cache is 
	emptied and the old table is dropped. Afterwards, the new table is created.
	
	This cache implementation <b>is only thread-safe</b> if compiled with the
	macro \c DTCACHE_USES_PREDICATES defined as \c 1.
*/
@interface DTFileCache : NSObject < DTCache >
{	
	NSString *_cachePath;
	NSError *_error;
    sqlite3 *_database;	
	DTCacheSize maximumSize;
	DTCacheSize size;

	NSMutableDictionary *cacheEntries;
	NSTimer * flushTimer;
}

// MARK: 
// MARK: 

@property ( assign ) DTCacheSize maximumSize;
@property ( readonly, copy ) NSString *cachePath;
@property ( readonly, assign ) DTCacheSize size;

// MARK: 
// MARK: NSObject: Creating, Copying, and Deallocating Objects

- (void)dealloc;

// MARK: 
// MARK: DTCache: Accessing the Cache

/*!
	\brief Returns the cached \c NSData object for a given key
	\return The cached data as NSData object. If there is no data present in the
		cache for the given key \c nil is returned.
*/
- (id)objectForKey:(NSString *)aPath;

/*!
	\brief Adds data to the cache. 
	\param object The object to be cached. If \c nil the cache entry identified 
		by \c key is removed. object must be of class \c NSData.
	\param key A unique key identifying the data to be cached.
	\param expirationDate An optional expiration date. If provided it overrules
		the maxAgae setting on cache purges. Any previously set expiration date
		value (including \c nil) is overwritten.
	\exception NSInvalidArgumentException Thrown if key is \c nil or data is \c
		nil and \c key is invalid.
		
	If there is already data cached for the given key that data is replaced by
	the data provided.	
*/
- (void)setObject:(id)object forKey:(NSString *)key 
	expirationDate:(NSDate *)expirationDate;

// MARK: 
// MARK: DTCache: Obtaining Meta Data

/*!
	\brief Returns the number of cache entries.
*/
- (NSUInteger)count;

/*!
	\brief Returns the expiration for a cache entry.
	\param key The key identifying the cache entry.
	\return The expiration date or \c nil if either there is no cache entry with
		the given key or the cache entry has no expiration date.
*/
- (NSDate *)expirationDateForKey:(NSString *)key;

/*!
	\brief Returns the size of all cache entries in bytes.
*/ 
- (DTCacheSize)size;

// MARK: 
// MARK: DTCache: Managing Cache Content

/*!
	\brief Clears the cache. Removes all entries from the filesystem and database.
*/
- (void)clear;

- (DTCacheSize)maximumSize;

/*!
	\brief Sets the new maximum size.
	
	If the cache's current size exceeds the new maximum size then cache entries
	are removed from the cache as long as the maximum size is exceeded.
*/
- (void)setMaximumSize:(DTCacheSize)maximumSize;

// MARK: 
// MARK: Initialisation

/*!
	\brief Designated initialiser.
	\param resetCache If resetCache is YES then the cache will be emtpied or 
		recreated.
		
	Creates the database used by the cache to manage its entries if it is not
	found. If an older schema of the database is detected the cache will be
	emptied and the database is recreated using the current schema.
*/
- (id)initWithCacheReset:(BOOL)resetCache;

/*!
	\brief Returns the shared cache instance.
*/
+ (DTFileCache *)sharedCache;

// MARK: 
// MARK: Cleaning Up

/*
 * Checks for files that are not connected to a database entry and deletes them. 
 * Can be executed in a background thread to avoid blocking of the application. Can take a while to complete depending on cache size. 
 * To terminate execution of thread set the value of the property cancelCleanupStalledFiles to YES!
 */
- (NSInteger)cleanupStalledFiles;


// MARK: 
// MARK: Remove Cache Entry for Key
- (void) removeCacheEntryForKey: (NSString*) key;



@end
