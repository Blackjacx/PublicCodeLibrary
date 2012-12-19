/*!
 \file		
 \brief		Private methods for the DTFileCache 
 \details   Provides database and file management functions for the DTFileCache
	that are not part of the external interface.
 \attention Copyright 2009 Deutsche Telekom AG. All rights reserved.
 \author	Pierre Bongen
 \author    Said El Mallouki
 \author    Stefan Herold
 \date		2009-02-18
*/
#import "DTFileCache.h"

/*!
	\note Private class.
*/
@interface DTCacheEntry : NSObject < NSCoding >
{
@private
	NSString *localFilename;
	NSString *key;
	NSDate *createDate;
    NSDate * modifiedDate;
	NSDate *lastRead;
	NSDate *expirationDate;
	DTCacheSize size;
}

/*!
	\name Properties

	The properties are non-atomic. They are guarded by locks created in 
	MEFileCache since this is the only place where the DTCacheEntry objects are
	modified.
	
	@{
*/

@property ( nonatomic, copy ) NSString * localFilename;
@property ( nonatomic, copy ) NSString * key;
@property ( nonatomic, retain ) NSDate *createDate;
@property ( nonatomic, retain ) NSDate *lastRead;
@property ( nonatomic, retain ) NSDate *expirationDate;
@property ( nonatomic, retain ) NSDate * modifiedDate;
@property ( nonatomic, assign ) DTCacheSize size;

//!@}

// MARK: 
// MARK: NSObject: Creating, Copying, and Deallocating Objects

- (void)dealloc;

// MARK: 
// MARK: NSCoding: Initializing with a Coder

- (id)initWithCoder:(NSCoder *)decoder;
//- (id)initWithKey:(NSString *)key expirationDate:(NSDate *)expirationDate;
- (id)initWithKey:(NSString *)aKey expirationDate:(NSDate *)anExpirationDate size:(DTCacheSize)aSize;

// MARK: 
// MARK: NSCoding: Encoding with a Coder

- (void)encodeWithCoder:(NSCoder *)encoder;

// MARK: 
// MARK: Getting and Setting the Entry's Size

- (void)setSize:(DTCacheSize)newSize;
- (DTCacheSize)size;

@end








// MARK: 
// MARK: 

@interface DTFileCache ( MEPrivate )

// MARK: 
// MARK: Pathes

- (NSString *)cachePath;
- (NSString *)databasePath;

// MARK: 
// MARK: Converting Dates

/*! 
	\brief Date format used by MECacheEntry and MEFileCache.
	\return A date formatter ready to use.
*/
+ (NSDateFormatter *)dateFormatter;

// MARK: 
// MARK: Managing Data Files

- (BOOL)deleteFile:(NSString *)filename;
- (BOOL)fileExists:(NSString*)filename;

- (NSData *)readFileWithFilename: (NSString *) filename;

/*!
	\brief Writes the provided data into the data directory of the cache.
	\param data The data to be written.
	\param filename The name of the file the data is written to. The filename 
		is appended to the result of cachePath in order to obtain the file path
		of the data file.
	\param doRefresh An existing data file is only overwritten if doRefresh is
		\c YES.
	\return The file path used to write the data file.
*/
- (NSString *)writeData:(NSData *)data withFilename:(NSString *)filename refresh:(BOOL)doRefresh;

// MARK: 
// MARK: Managing Cache Entries

/*!
	\brief Checks if the given localFileName exists in the database.
*/
- (BOOL)entryExistsForLocalFilename:(NSString *)localFileName;

/*!
	\brief Returns the local filename for a key.
	\return The local filename or \c nil if it does not exist.
 */
- (NSString* )localFilenameForKey: (NSString *) key;

/*!
	\brief Removes entries until the cache's size is smaller than the desired 
		size provided. 
	\return Returns the amount of bytes freed.
	
	Removes old entries first. 
*/
- (DTCacheSize)reduceCacheSizeTo:(DTCacheSize) bytes;

- (void)updateLastAccessForLocalFilename:(NSString *)localFilename;
- (void)updateLastAccessForKey:(NSString *)key;






- (NSString *)absolutePathToArchiveOfCacheEntries;
- (DTCacheEntry *)cacheEntryForKey:(NSString *)key;
- (void)flush;
- (void)flushTimerMethod:(NSTimer *)timer;
- (BOOL)loadCacheEntries;
- (BOOL)saveCacheEntries;
- (void)setNeedsFlush;

/*!
	\brief Adds a value to the current cache size. Checks data type boundaries and prevents overflow.
	\param aValue Value to add to \c self->size
	\return \c YES if \aValue could be added successfully. \c NO in case of overflow
*/
- (BOOL)cacheSizePlusValue:(DTCacheSize)aValue;

/*!
	\brief Subtracts a value from the current cache size. Checks data type boundaries and prevents underflow.
	\param aValue Value to subtract from \c self->size
	\return \c YES if \aValue could be subtracted successfully. \c NO in case of underflow
*/
- (BOOL)cacheSizeMinusValue:(DTCacheSize)aValue;


// MARK: 
// MARK: Handling Notifications

- (void)applicationWillTerminate:(NSNotification *)notification;

@end