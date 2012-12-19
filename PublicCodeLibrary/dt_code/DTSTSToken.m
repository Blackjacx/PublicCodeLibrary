//
//  STSToken.m
//  IphoneEPG
//
//  Created by Stefan Herold on 8/10/10.
//  Copyright 2010 DTAG. All rights reserved.
//

#import "DTSTSToken.h"

/**
 @todo Adapt json and property key paths to the values from backend! (stherold - 2012-07-24)
 */


DT_DEFINE_STRING(DTSTSTokenPropKeyPathToken,						"tokenString")
DT_DEFINE_STRING(DTSTSTokenPropKeyPathTokenFormat,					"tokenFormat")
DT_DEFINE_STRING(DTSTSTokenPropKeyPathTokenEncoding,				"tokenEncoding")
DT_DEFINE_STRING(DTSTSTokenPropKeyPathTokenExpirationDate,			"tokenExpirationDate")
DT_DEFINE_STRING(DTSTSTokenPropKeyPathTokenCreationDate,			"tokenCreationDate")
DT_DEFINE_STRING(DTSTSTokenPropKeyPathTimeCorrectionInterval,		"timeCorrectionInterval")

DT_DEFINE_STRING(DTSTSTokenJsonKeyPathToken,						"token")
DT_DEFINE_STRING(DTSTSTokenJsonKeyPathTokenFormat,					"tokenFormat")
DT_DEFINE_STRING(DTSTSTokenJsonKeyPathTokenEncoding,				"tokenEncoding")
DT_DEFINE_STRING(DTSTSTokenJsonKeyPathTokenExpirationDate,			"tokenExpirationDate")
DT_DEFINE_STRING(DTSTSTokenJsonKeyPathTokenCreationDate,			"tokenCreationDate")
DT_DEFINE_STRING(DTSTSTokenJsonKeyPathTimeCorrectionInterval,		"timeCorrectionInterval")

/*!
 \brief		Implementation of an DLSi model entity.
 \details	This entity holds information about the token obtained during the 
 login process. It is available to determine the expirationstate of the token.
 */

@implementation DTSTSToken
@synthesize tokenString;
@synthesize tokenFormat;
@synthesize tokenEncoding;
@synthesize tokenExpirationDate;
@synthesize tokenCreationDate;
@synthesize timeCorrectionInterval;

// MARK: -
// MARK: Initialisation

- (id)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
	if( (self = [super initWithDictionary:dictionary error:error]) ) {
		/*if(!error || (error && !*error)) {
			// Calculate the time correction interval.
			if( self.tokenCreationDate )
				self.timeCorrectionInterval = [self.tokenCreationDate
											   timeIntervalSinceDate:[NSDate date]];	
			else 
				self.timeCorrectionInterval = 0;	
		}*/
	}
	return self;
}

//MARK: -
//MARK: MCModelProtocol

- (NSDictionary*)propertyMetaData {
	static NSDictionary *dictionary = nil;
	
	if(!dictionary) {
		NSDictionary *superDictionary = [super propertyMetaData];
		
		NSMutableDictionary *tmpDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											  [DTPropertyMetaData propertyWithType:DTModelTypeString	keyPath:DTSTSTokenPropKeyPathToken],					DTSTSTokenJsonKeyPathToken,								
											  [DTPropertyMetaData propertyWithType:DTModelTypeString	keyPath:DTSTSTokenPropKeyPathTokenFormat],				DTSTSTokenJsonKeyPathTokenFormat,								
											  [DTPropertyMetaData propertyWithType:DTModelTypeString	keyPath:DTSTSTokenPropKeyPathTokenEncoding],			DTSTSTokenJsonKeyPathTokenEncoding,								
											  [DTPropertyMetaData propertyWithType:DTModelTypeDate		keyPath:DTSTSTokenPropKeyPathTokenExpirationDate],		DTSTSTokenJsonKeyPathTokenExpirationDate,								
											  [DTPropertyMetaData propertyWithType:DTModelTypeDate		keyPath:DTSTSTokenPropKeyPathTokenCreationDate],		DTSTSTokenJsonKeyPathTokenCreationDate,								
											  [DTPropertyMetaData propertyWithType:DTModelTypeScalar	keyPath:DTSTSTokenPropKeyPathTimeCorrectionInterval],	DTSTSTokenJsonKeyPathTimeCorrectionInterval,
											  nil];
		
		// Enrich temporary dictionary with dictionary from super and assign 
		// to the static variable.
		[tmpDictionary addEntriesFromDictionary:superDictionary];
		dictionary = [tmpDictionary copy];
		
		DT_ASSERT([[self class] checkPropertyMetaData:dictionary error:nil],
				  @"Property meta data are not valid! Check error object for details!");
	}	
	return dictionary;
}

// MARK: -
// MARK: Expiration request

- (BOOL)isExpired {
	
	// Check expiration.
	
	NSDate *correctedCurrentDate = [[NSDate date]
									dateByAddingTimeInterval:self->timeCorrectionInterval];
	
	NSTimeInterval maxLivingTime = [self.tokenExpirationDate
									timeIntervalSinceDate:self.tokenCreationDate];
	
	NSTimeInterval timeIntervalFromCreationDateToNow = [correctedCurrentDate
														timeIntervalSinceDate:self.tokenCreationDate];
	
	BOOL isExpired = timeIntervalFromCreationDateToNow < 0 ||
	timeIntervalFromCreationDateToNow >= maxLivingTime;
	
	return isExpired;
}

@end