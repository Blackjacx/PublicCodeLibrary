//
//  DTCache.h
//  IphoneEPG
//
//  Created by Pierre Bongen on 04.02.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef unsigned long long DTCacheSize;


#define DTCacheSizeMax ( ( DTCacheSize )ULLONG_MAX )



#pragma mark
#pragma mark
#pragma mark

/*!
	\brief This class defines the methods to be implemented by caches.

	\section GeneralModeOfOperation General Mode of Operation
	
	The caches accept arbitrary objects with an unique key identifying the 
	object. Such keys are \c NSString objects which may have any value except an
	empty string.
	
	The object stored in the cache is selectively removed from it if the cache 
	exceeds its maximum size. Additionally to this mechanism the object is 
	removed from the cache if the cache client explicitly provided an expiration
	date when the object was cached. If the encountered expiration date of a 
	cache entry is in the past the cache entry is removed from the cache.

	\section ObjectsSizes Objects' Sizes
	
	Since the Foundation does not provide a straight forward mechanism how to
	determine an object's size the class implementing this protocol must find a
	way to estimate an object's size. You may find the following two approaches
	meeting your needs:
	
	- <b>Caching \c NSData instances</b> You may implement the cache so that it
		only accepts \c NSData objects from the object to be cached. The 
		\c length method of \c NSData can then be used to determine a very 
		accurate size of the cached data.
	
	- <b>Caching objects conforming to NSCoding</b> The cache implementation may
		internally create temporary \c NSData instances of the objects which it
		is about to cache.

	\section Multithreading Multithreading
	
	The implementation of the DTCache protocol should be thread-safe for all of
	the protocol's methods. For special situations (thread optimisations or a 
	single-thread environment for instance), the methods may be implemented 
	in a non-thread-safe fashion. In this case, the documentation must 
	explicitly state that the cache is not thread-safe.
*/
@protocol DTCache < NSObject >

#pragma mark
#pragma mark Accessing the Cache

@required 

/*!
	\name Accessing the Cache
	
	Usually, a cache client only needs to use methods of this method group. An
	arbitrary object may be cached by providing a unique key for it:

\htmlonly<pre><code>DTCache * const cache = DTGetCache();
NSString * const key = object.UUID;

// Set expiration date to point in time in one hour from now.
NSDate * const expirationDate = [NSDate dateWithTimeIntervalSinceNow:3600.0];

[cache setObject:object forKey:key expirationDate:expirationDate];
</code></pre>\endhtmlonly

	This object may then be re-obtained using code similar to the following:
	
\htmlonly<pre><code>DTCache * const cache = DTGetCache();
NSString * const key = DTGetKey();

id object = [cache objectForKey:key];
</code></pre>\endhtmlonly

	@{
*/

/*!
	\brief Returns the cached object for a given key.
	\param key The key that was used when the object was added to the cache. 
	\return The cached object. If there is no object present in	the cache for 
		the given key \c nil is returned.
*/
- (id)objectForKey:(NSString *)key;

/*!
	\brief Adds an object to the cache. 
	\param object The object to be cached. If \c nil the cache entry identified 
		by \c key is removed. If there is already an object stored in the cache
		for the	given key that object is replaced by \c object.
	\param key A unique key identifying the object to be cached.
	\param expirationDate An optional expiration date after which the object is
		removed from the cache. Any previously set expiration date value 
		(including \c nil) for the object identified by \c key  is overwritten 
		by this value.
*/
- (void)setObject:(id)object forKey:(NSString *)key 
	expirationDate:(NSDate *)expirationDate;

//!@}

#pragma mark
#pragma mark
#pragma mark Obtaining Meta Data

@required

/*!
	\name Obtaining Meta Data
	
	@{
*/

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
	\brief Returns the overall size of all cache entries in bytes.
*/ 
- (DTCacheSize)size;

//!@}

#pragma mark
#pragma mark
#pragma mark Managing Cache Content

@required

/*!
	\name Managing Cache Content
	
	@{
*/

/*!
	\brief Clears the cache. 
	
	Removes all entries from the cache.
*/
- (void)clear;

/*!
	\brief Returns the maximum total size of all cache entries.
*/
- (DTCacheSize)maximumSize;

/*!
	\brief Sets the maximum total size of all cache entries.
	\param maximumSize The new maximum size given in number of bytes.
	
	The cache must remove cache entries as long as the total size of all cache 
	entries exceeds the maximum size whenever the cache detects the exceedance.
*/
- (void)setMaximumSize:(DTCacheSize)maximumSize;

//!@}

@optional


/*!
 \brief Remove Cache Entry for given key.
 \param key The key for cache entry.
 
 */
- (void) removeCacheEntryForKey:(NSString*) key;

- (NSDate*) modifiedDateForKey:(NSString*) key;

@end