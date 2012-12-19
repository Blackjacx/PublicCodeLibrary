//
//  MEMemoryCacheEntry.h
//  IphoneEPG
//
//  Created by Pierre Bongen on 05.02.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DTCache.h"
#import "DTStrings.h"

DT_DECLARE_KEY( DTMemoryCacheEntryKeyDateOfLastAccess );



@interface DTMemoryCacheEntry : NSObject 
{
@private
	id<NSCoding,NSObject> object;
	NSDate * dateOfLastAccess;
	NSDate * expirationDate;
	NSString * key;
	DTCacheSize size;
}

#pragma mark

@property ( nonatomic, retain ) id<NSCoding,NSObject> object;

/*!
	\brief Returns the date and time of the last time the cache entry's data has 
		been accessed.
*/
@property ( nonatomic, retain ) NSDate * dateOfLastAccess;

@property ( nonatomic, retain ) NSDate * expirationDate;
@property ( nonatomic, retain, readonly ) NSString * key;
@property ( nonatomic, readonly ) DTCacheSize size;

#pragma mark
#pragma mark NSObject: Creating, Copying, and Deallocating Objects

- (void)dealloc;

#pragma mark
#pragma mark
#pragma mark Initialisation

- (id)initWithObject:(id<NSCoding>)anObject key:(NSString *)aKey 
	expirationDate:(NSDate *)anExpirationDate size:(DTCacheSize)size;

#pragma mark
#pragma mark
#pragma mark Properties

/*!
	\brief Returns the cache entry's data and updates \c lastAccess to the 
		current date and time.
	\return The cache entry's data.
	\see dateOfLastAccess.
*/
- (id<NSCoding,NSObject>)object;

/*!
	\brief Sets the cache entry's data and updated \c lastAccess to the current
		date and time.
	\param newObject The new NSData object to be set. Must not be \c nil.
	\note The \c NSData object provided must be immutable.
	\see dateOfLastAccess.
*/
- (void)setObject:(id<NSCoding,NSObject>)newObject;

- (void)setObject:(id<NSCoding,NSObject>)newObject ofSize:(DTCacheSize)aSize;

@end
