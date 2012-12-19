//
//  CacheEntry.h
//  MedienCenter
//
//  Created by said.el-mallouki on 18.02.09.
//  Copyright 2009 Deutsche Telekom AG. All rights reserved.
//

// This is the default if nothing has been defined.
#ifndef DTCACHE_USES_PREDICATES
#define DTCACHE_USES_PREDICATES 1
#endif

#if !defined( DTCACHE_USES_PREDICATES ) || DTCACHE_USES_PREDICATES == 0

#import <sqlite3.h>
#import "DTFileCache.h"


/*!
	\brief Encapsulates a single cache entry.
	\note This class is a private class of MEFileCache.
	
	Supports means to identify expired cache entries, marking entries being 
	dirty or persisted and stores meta data about the cached data's whereabouts.
*/
@interface DTCacheEntry : NSObject 
{
	//!A weak reference to the file cache this entry is associated with.
	DTFileCache *fileCache;
	
	NSNumber *primaryKey;
	NSString * localFilename;
	NSString * key;
	NSDate * createDate;
	NSDate * dateOfLastAccess;
	
	/*!
		\brief Date when the cache entry is regarded as being expired.
		
		The cache must remove cache entries with expiration dates of the past.
	*/
	NSDate * expirationDate;

	/**
	 @todo Determine if obsolete. It gets always set to YES before the entry
	 is explicitly written to the database. (stherold - 2012-07-24)
	 */
	
	/*!
		\brief Flag to mark, when the object has to be written to the database.
	*/
	BOOL dirty;
	
	//!Indicates if a newly initialized entry was read from the database.
	BOOL persistent;
}

@property ( nonatomic, assign, readonly ) BOOL persistent;
@property ( nonatomic, assign ) BOOL dirty;

//!Cache entry's primary key in the cache entry table of the underlying database.
@property ( nonatomic, retain ) NSNumber *primaryKey;

@property ( nonatomic, copy ) NSString *localFilename;

//!Cache entry's key used to identify the key by cache clients.
@property ( nonatomic, copy, readonly ) NSString *key;

@property ( nonatomic, retain ) NSDate *createDate;
@property ( nonatomic, retain ) NSDate *dateOfLastAccess;

/*!
	\brief An optional expiration date. 
	
	If given set to a date this date overrules the maxAge setting of the 
	associated MEFileCache object on cache purges.
*/
@property ( nonatomic, retain ) NSDate *expirationDate;

#pragma mark -
#pragma mark Initialisation

/*!
	\name Initialisation
	
	@{
*/

/*!
	\brief Creates a cache entry.
	\param aKey A unique key identifying the cache entry.
	\param aFileCache A file cache the entry is associated with. Must not be 
		\c nil.
	\return The newly created and autoreleased cache entry.
*/
+ (DTCacheEntry *)cacheEntryWithKey:(NSString *)aKey fileCache:(DTFileCache *)aFileCache;

/*!
	\brief Creates a cache entry.
	\param aKey A unique key identifying the cache entry.
	\param aFileCache A file cache the entry is associated with. Must not be 
		\c nil.
	\return The newly created cache entry.
	
	If there is already a cache entry for the provided key in the database the
	receiver is set up using the values stored in the cache database for that
	key.
	
	If there is no cache entry for the provided key the values are initialised 
	as follows:
	
	- \b key is set to aKey
	- \b localFilename is set to a newly created UUID
	- \b createData is set to the current date and time
	- \b dateOfLastAccess is set to the current date and time
*/
- (id)initWithKey:(NSString *)aKey fileCache:(DTFileCache *)aFileCache;

//!@}

#pragma mark -
#pragma mark Modifying the Database

/*!
	\name Modifying the Database
	
	@{
*/

- (void)deleteFromDatabase;
- (void)insertIntoDatabase;
- (void)updateInDatabase;

/*!
	\brief Writes the cache entry to the database.
	\see persistent
	
	If the cache entry has not been persisted before its data is inserted to
	the table of cache entries. If it has been persisted its table row is
	updated.
*/
- (void)writeToDatabase;

//!@}

#pragma mark -
#pragma mark Accessing Local Data Files

/*!
	\brief Returns the filename used to store the cached data locally.

	The returned filename does not contain any further path components.
*/
- (NSString*)localFilename;

#pragma mark -
#pragma mark Controlling Validity

- (void)setCreateDate:(NSDate *)newDate;
- (void)setDateOfLastAccess:(NSDate *)newDate;
- (void)setExpirationDate:(NSDate *)newDate;

@end

#endif