//
//  DTPropertyMetaData.m
//  MedienCenter
//
//  Created by Stefan Herold on 17.11.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "DTPropertyMetaData.h"

DT_DEFINE_STRING(DTPropertyMetaDataPropertyKeyType, "propertyType" );
DT_DEFINE_STRING(DTPropertyMetaDataPropertyKeyKeyPath, "propertyKeyPath" );
DT_DEFINE_STRING(DTPropertyMetaDataPropertyKeyElementClass, "propertyElementsClass" );

/*!
 \brief		Implementation of a class encapsulating property meta data / 
 property description.
 \details	This class holds meta data of a property that is needed to 
 operate on objects with the KVC pattern.
 */

@implementation DTPropertyMetaData
@synthesize propertyKeyPath;
@synthesize propertyType;
@synthesize propertyElementClass;

// MARK: -
// MARK: NSObject: Describing Objects

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@: {propertyKeyPath = %@, "
		"propertyType = %@, propertyElementClass = %@",
		[super description],
		self.propertyKeyPath,
		[[self class] stringFromModelType:self.propertyType],
		NSStringFromClass( self.propertyElementClass )];
}

// MARK: -
// MARK: Conversions

+ (NSString *)stringFromModelType:(DTModelType)modelType
{
	NSString *result = nil;

	switch ( modelType )
	{
	case DTModelTypeArrayOfUniformType:
		result = DT_STRINGIFY( DTModelTypeArrayOfUniformType );
		break;
	
	case DTModelTypeDictionary:
		result = DT_STRINGIFY( DTModelTypeDictionary );
		break;
	
	case DTModelTypeScalar:
		result = DT_STRINGIFY( DTModelTypeScalar );
		break;
	
	case DTModelTypeDate:
		result = DT_STRINGIFY( DTModelTypeDate );
		break;
	
	case DTModelTypeApplicationSpecific:
		result = DT_STRINGIFY( DTModelTypeApplicationSpecific );
		break;
	
	case DTModelTypeString:
		result = DT_STRINGIFY( DTModelTypeString );
		break;
	
	case DTModelTypeUrl:
		result = DT_STRINGIFY( DTModelTypeUrl );
		break;
	
	default :
		result = @"<unkown>";
	}
	
	return result;
}

//MARK: -
//MARK: Initializing

- (id)initWithType:(NSUInteger)aType 
		   keyPath:(NSString*)aKeyPath
	  elementClass:(Class)anElementClass 
{
	if( (self = [super init]) ) {
		self.propertyType = aType;
		self.propertyKeyPath = aKeyPath;
		self.propertyElementClass = anElementClass;
	}
	return self;
}

- (id)initWithType:(NSUInteger)aType 
		   keyPath:(NSString*)aKeyPath
{
	return [self initWithType:aType keyPath:aKeyPath elementClass:Nil];
}

+ (id)propertyWithType:(NSUInteger)aType 
			   keyPath:(NSString*)aKeyPath
		  elementClass:(Class)anElementClass 
{
	DTPropertyMetaData *metaData = nil;
	metaData = [[[DTPropertyMetaData alloc] initWithType:aType
												 keyPath:aKeyPath
											elementClass:anElementClass] autorelease];
	return metaData;
}

+ (DTPropertyMetaData*)propertyWithType:(NSUInteger)aType
								keyPath:(NSString*)aKeyPath
{
	return [self propertyWithType:aType
						  keyPath:aKeyPath
					 elementClass:Nil];
}

//MARK: -
//MARK: Key handling

- (NSString*)keyFromKeyPath {
	NSString *result = nil;	
	NSArray *allComponents = [self.propertyKeyPath componentsSeparatedByString:@"."];
	if(allComponents)
		result = [allComponents objectAtIndex:([allComponents count]-1)];
	return result;
}

- (NSString*)basePathFromKeyPath {
	NSString *result = nil;
	NSRange lastDotRange = [self.propertyKeyPath rangeOfString:@"." options:NSBackwardsSearch];
	
	if(lastDotRange.location != NSNotFound) {
		result = [self.propertyKeyPath substringToIndex:lastDotRange.location];
	}
	return result;
}

- (BOOL)isRootProperty {
	return self.propertyKeyPath && [self basePathFromKeyPath] == nil;
}

@end
