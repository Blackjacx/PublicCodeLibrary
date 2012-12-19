//
//  MEMemoryCacheEntry.m
//  IphoneEPG
//
//  Created by Pierre Bongen on 05.02.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "DTMemoryCacheEntry.h"


DT_DEFINE_KEY_WITH_VALUE( DTMemoryCacheEntryKeyDateOfLastAccess, "dateOfLastAccess" );


@implementation DTMemoryCacheEntry

@synthesize dateOfLastAccess;
@synthesize expirationDate;
@synthesize key;
@synthesize size;

#pragma mark
#pragma mark NSObject: Creating, Copying, and Deallocating Objects

- (void)dealloc
{
	[self->object release], self->object = nil;
	[self->dateOfLastAccess release], self->dateOfLastAccess = nil;
	[self->expirationDate release], self->expirationDate = nil;
	[self->key release], self->key = nil;

	[super dealloc];
}

#pragma mark
#pragma mark
#pragma mark Initialisation

- (id)initWithObject:(id<NSCoding,NSObject>)anObject key:(NSString *)aKey 
	expirationDate:(NSDate *)anExpirationDate size:(DTCacheSize)aSize
{
	NSAssert( 
		[anObject conformsToProtocol:@protocol( NSCoding )], 
		@"anObject must not be nil and is expected to implement the NSCoding "
			"protocol." );

	NSAssert( 
		[aKey isKindOfClass:[NSString class]] && [aKey length], 
		@"aKey must not be a non-empty string." );

	if ( (self = [super init]) )
	{
		self->object = [anObject retain];
		self.expirationDate = anExpirationDate;
		self->key = [aKey retain];
		self->size = aSize;
	}
	
	return self;
}

#pragma mark
#pragma mark
#pragma mark Properties

- (id<NSObject,NSCoding>)object
{
	self.dateOfLastAccess = [NSDate date];
	return self->object;
}

- (void)setObject:(id<NSObject,NSCoding>)newObject
{
	[self
		setObject:newObject 
		ofSize:[[NSKeyedArchiver archivedDataWithRootObject:newObject] length]];
}

- (void)setObject:(id<NSCoding,NSObject>)newObject ofSize:(DTCacheSize)aSize
{
	NSAssert( 
		[newObject conformsToProtocol:@protocol( NSCoding )], 
		@"newObject must not be nil and is expected to conform to the "
			"NSCoding protocol." );
	
	self.dateOfLastAccess = [NSDate date];
	
	if ( newObject == self->object )
		return;
	
	[self->object release];
	self->object = [newObject retain];
	
	self->size = aSize;
}

@end
