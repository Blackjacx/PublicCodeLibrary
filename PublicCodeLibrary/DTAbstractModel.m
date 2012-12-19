/*!
 \file		
 \brief		Source file implementing the base class for an DLSi model entity.
 \details	This file holds base implementations for all DLSi model entities.
 \attention Copyright 2010 Deutsche Telekom AG. All rights reserved.
 \author	Stefan Herold
 \author    Pierre Bongen
 \author    Said El Mallouki
 \author    Manuel Carrasco Molina
 \date		2010-11-15
 */

#import "DTAbstractModel.h"
#import "DTModelProtocol.h"
#import "DTPropertyMetaData.h"
#import "DTError.h"
#import "NSDate+DTUTCFormatting.h"

DT_DEFINE_STRING(DTErrorDomainModel, "de.telekom.dtLibrary.model")
DT_DEFINE_KEY( DTAbstractModelErrorKeyPropertyKey );
DT_DEFINE_KEY( DTAbstractModelErrorKeyJSONKeyPath );
DT_DEFINE_KEY( DTAbstractModelErrorKeyUnderlyingErrors );

@interface DTAbstractModel ( DTPrivate )
- (id)validateObject:(id)object forJsonKeyPath:(NSString*)keyPath;

- (id) validatedPropertyFromObject:(id)object 
					forJsonKeyPath:(NSString*)formattedKeyPath
				  propertyMetaData:(NSDictionary*)propertyMetaData
						errorArray:(NSMutableArray*)errorArray;

@end

/*!
 \brief		Implementation of the base class for all model objects.
 \details	This class is responsible for initializing, destroying, describing, 
 copying, encoding, decoding of all business objects. Subclasses only have to
 override the propertyMetaData() method and deliver a NSDictionary of
 DTPropertyMetaData objects. That enables this super class to perform the
 mentioned operations using the KVC pattern. An example of propertyMetaData is 
 as follows:
 
 \code 
- (NSDictionary*)propertyMetaData {
	
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								[DTPropertyMetaData propertyWithType:DTModelTypeString 
															 keyPath:DTSTSTokenPropKeyPathToken],
								DTSTSTokenJsonKeyPathToken,
								
								[DTPropertyMetaData propertyWithType:DTModelTypeString 
															 keyPath:DTSTSTokenPropKeyPathTokenFormat],
								DTSTSTokenJsonKeyPathTokenFormat,
								
								[DTPropertyMetaData propertyWithType:DTModelTypeString 
															 keyPath:DTSTSTokenPropKeyPathTokenEncoding],
								DTSTSTokenJsonKeyPathTokenEncoding,
								
								[DTPropertyMetaData propertyWithType:DTModelTypeDate 
															 keyPath:DTSTSTokenPropKeyPathTokenExpirationDate],
								DTSTSTokenJsonKeyPathTokenExpirationDate,
								
								[DTPropertyMetaData propertyWithType:DTModelTypeDate 
															 keyPath:DTSTSTokenPropKeyPathTokenCreationDate],
								DTSTSTokenJsonKeyPathTokenCreationDate,
								
								[DTPropertyMetaData propertyWithType:DTModelTypeScalar
															 keyPath:DTSTSTokenPropKeyPathTimeCorrectionInterval],
								DTSTSTokenJsonKeyPathTimeCorrectionInterval,
								
								nil];
	
	DT_ASSERT([[self class] checkPropertyMetaData:dictionary error:nil],
			  @"Property meta data are not valid! Check error object for details!");
	
	return dictionary;
}
 \endcode
 */

@implementation DTAbstractModel

//MARK: -
//MARK: DTModelProtocol

- (id)initWithDictionary:(NSDictionary*)dictionary error:(NSError**)error {
	if( (self = [super init]) ) {
		NSMutableArray *errorArray = [[NSMutableArray alloc] init];
		
		// Error checking.
		if(![[self class] validDictForObject:dictionary]) {
			[errorArray addObject:[DTError errorWithDomain:DTErrorDomainModel 
													  code:DTErrorCodeModelRootDictionaryInvalid
												  userInfo:nil]];
		}				
		else if ( ![self respondsToSelector:@selector(propertyMetaData)] ) {
			[errorArray addObject:[DTError errorWithDomain:DTErrorDomainModel 
													  code:DTErrorCodeModelPropertyMetaDataSelectorNotFound
												  userInfo:nil]];
		}
		else {			
			// Traverse root objects in dictionary.
			NSDictionary *propertyMetaData = [self propertyMetaData];
			for (NSString *jsonKey in [dictionary allKeys]) {	
				id validatedObject = [self validatedPropertyFromObject:[dictionary objectForKey:jsonKey]
														forJsonKeyPath:jsonKey
													  propertyMetaData:propertyMetaData
															errorArray:errorArray];
				
				if( validatedObject ) {
					DTPropertyMetaData *singleMetaData = [propertyMetaData objectForKey:jsonKey];
					[self setValue:validatedObject forKeyPath:singleMetaData.propertyKeyPath];
				}
			}	
		}
		
		// Check if an error occurred.
		if([errorArray count]) {
			if(error) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
										  errorArray, DTAbstractModelErrorKeyUnderlyingErrors,
										  nil];
				*error = [DTError errorWithDomain:DTErrorDomainModel
											 code:DTErrorCodeModelParseErrorsOccurred
										 userInfo:userInfo];
			}
		}
		[errorArray release];
	}
	return self;
}

- (id) validatedPropertyFromObject:(id)object 
					forJsonKeyPath:(NSString*)composedJsonKeyPath
				  propertyMetaData:(NSDictionary*)propertyMetaData
						errorArray:(NSMutableArray*)errorArray
{
	id validatedObject = nil;
	
	if( !composedJsonKeyPath ) {
		// The keypath could not be created.
		[errorArray addObject:[DTError errorWithDomain:DTErrorDomainModel 
												  code:DTErrorCodeModelJsonKeyPathMissing
											  userInfo:nil]];
		return nil;
	}	
	
	// Read and validate properties meta data.
	DTPropertyMetaData *singleMetaData = [propertyMetaData objectForKey:composedJsonKeyPath];
	if( !singleMetaData ) {
		// No property description for this keypath! Check PropertyMetaData!
		[errorArray addObject:[DTError errorWithDomain:DTErrorDomainModel 
												  code:DTErrorCodeModelUndefinedJsonKeyPath
												  userInfo:[NSDictionary dictionaryWithObject:composedJsonKeyPath forKey:DTAbstractModelErrorKeyJSONKeyPath]]];
		return nil;
	}
	
	// Read the property meta data in simple to use var's.
	NSUInteger type = singleMetaData.propertyType;
	//	NSString *propertyKeyPath = singleMetaData.propKeyPath;

//	Debug
	
//	if( [object isKindOfClass:[NSNull class]] ) {
//		//NSLog(@"Object is NSNull: %@\npropertyMetaData: %@", composedJsonKeyPath, propertyMetaData);
//		NSLog(@"Object is NSNull: %@    pmd: %@", composedJsonKeyPath, propertyMetaData);
//	}
	
	switch (type) {
			
		case DTModelTypeDictionary: {
			// Tranform and check the incoming dictionary.
			NSDictionary *value = [[self class] validDictForObject:object];
			NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
			
			if( !value ) {
				// Object could not be validated as NSDictionary.
				[errorArray addObject:[DTError 
					errorWithDomain:DTErrorDomainModel 
					code:DTErrorCodeModelDictionaryValidationError
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
						singleMetaData.propertyKeyPath,
						DTAbstractModelErrorKeyPropertyKey,
						nil]]];
				return nil;
			}
			
			// Recursive traversal of the dictionary.
			for (NSString *jsonKey in [value allKeys]) {
				NSString *currentJsonKeyPath = [NSString stringWithFormat:@"%@.%@", composedJsonKeyPath, jsonKey];
				id validationResult = [self validatedPropertyFromObject:[value objectForKey:jsonKey]
														 forJsonKeyPath:currentJsonKeyPath
													   propertyMetaData:propertyMetaData
															 errorArray:errorArray];											
				
				if( validationResult ) {
					DTPropertyMetaData *singleMetaData = [propertyMetaData objectForKey:currentJsonKeyPath];
					NSString *propKeyPath = [singleMetaData keyFromKeyPath];
					[tmpDict setObject:validationResult forKey:propKeyPath];
				}
			}
			validatedObject = tmpDict;
		}
			break;
			
		case DTModelTypeArrayOfUniformType: {
			// Transform and check the incoming array.
			NSArray *value = [[self class] validArrayForObject:object];
			if( !value ) {
				// Object could not be validated as NSArray.
				[errorArray addObject:[DTError 
					errorWithDomain:DTErrorDomainModel
					code:DTErrorCodeModelArrayOfUniformTypeValidationError
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
						singleMetaData.propertyKeyPath,
						DTAbstractModelErrorKeyPropertyKey,
						nil]]];
				return nil;
			}
			
			// Get and Check property class.
			Class propertyClass = singleMetaData.propertyElementClass;
			if( !propertyClass ) {
				// The properties class is nil. Check property meta data!
				[errorArray addObject:[DTError 
					errorWithDomain:DTErrorDomainModel 
					code:DTErrorCodeModelMissingPropertyClass
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
						singleMetaData.propertyKeyPath,
						DTAbstractModelErrorKeyPropertyKey,
						nil]]];
				return nil;
			}
			
			// Construct temp array with initialized and validated objects.
			NSMutableArray *tmpArray = [NSMutableArray array];
			NSError *error = nil;

            
            for (id rootObject in value) {
				error = nil;
				
                if ([rootObject isKindOfClass:[NSString class]]) {
                    
                    id validatedResult = [[self class] validUrlForObject:rootObject];
                    if(validatedResult)
                    {
                        [tmpArray addObject:validatedResult];
                    }
                }
                else if( [rootObject isKindOfClass:[NSDictionary class]])
				/**
				 @todo (stherold - 2012-07-24): Add  propertyElementClass isEqualTo: DTAbstractModel class
				 */
                {
                    id subValue = [[[propertyClass alloc] initWithDictionary:rootObject error:&error] autorelease];
                    if( subValue ) {
                        [tmpArray addObject:subValue];
                    }
                    else if( error ) {
                        // An element contained in the array could not be initialized!
                        [errorArray addObject:[DTError 
                                               errorWithDomain:DTErrorDomainModel 
                                               code:DTErrorCodeModelUnknownValidationErrorInitializingInternalObject
                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         singleMetaData.propertyKeyPath,
                                                         DTAbstractModelErrorKeyPropertyKey,
                                                         nil]]];
                    }
                } 
                else
                {
                    DT_ASSERT(nil, @"Unknown PropertyElementClass in Array" );
                }
                
                
                
			}
            
			validatedObject = tmpArray;
		}
			break;
			
		case DTModelTypeScalar: {
			validatedObject = [[self class] validNumberForObject:object];
						
			// No number objecxt could be extracted
			if( !validatedObject ) {
				[errorArray addObject:[DTError 
					errorWithDomain:DTErrorDomainModel 
					code:DTErrorCodeModelScalarValidationError
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
						singleMetaData.propertyKeyPath,
						DTAbstractModelErrorKeyPropertyKey,
						nil]]];
				return nil;
			}
		}
			break;
			
		case DTModelTypeDate: {
			NSString *validUTCString = [[self class] validStringForObject:object];
			if( !validUTCString ) {
				// Object could not be validated as NSString.
				[errorArray addObject:[DTError 
					errorWithDomain:DTErrorDomainModel 
					code:DTErrorCodeModelDateValidationError
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
						singleMetaData.propertyKeyPath,
						DTAbstractModelErrorKeyPropertyKey,
						nil]]];
				return nil;
			}

			if ( [validUTCString isKindOfClass:[NSString class]] )
			{
				if ( [validUTCString length] )
				{
					validatedObject = [NSDate dateFromUTCString:validUTCString];
					if( !validatedObject ) {
						// Object could not be validated as NSString.
						[errorArray addObject:[DTError 
							errorWithDomain:DTErrorDomainModel 
							code:DTErrorCodeModelDateValidationError
							userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
								singleMetaData.propertyKeyPath,
								DTAbstractModelErrorKeyPropertyKey,
								nil]]];
						return nil;
					}
				}
				else 
				{
					validatedObject = [NSNull null];
				}
			}
		}
			break;
			
		case DTModelTypeApplicationSpecific: {
			// Get and check property class.
			Class propertyClass = singleMetaData.propertyElementClass;
			if( !propertyClass ) {
				// The properties class is nil. Check property meta data!
				[errorArray addObject:[DTError 
					errorWithDomain:DTErrorDomainModel 
					code:DTErrorCodeModelMissingPropertyClass
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
						singleMetaData.propertyKeyPath,
						DTAbstractModelErrorKeyPropertyKey,
						nil]]];
				return nil;
			}
			
			// Construct the object.
			NSDictionary *rootDictionary = (NSDictionary*)object;
			NSError *error = nil;
			validatedObject = [[[propertyClass alloc] initWithDictionary:rootDictionary 
															   error:&error] autorelease];
			
			if( !validatedObject ) {
				// An element contained in the array could not be initialized!
				[errorArray addObject:[DTError 
					errorWithDomain:DTErrorDomainModel 
					code:DTErrorCodeModelUnknownValidationErrorInitializingInternalObject
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
						singleMetaData.propertyKeyPath,
						DTAbstractModelErrorKeyPropertyKey,
						nil]]];
				return nil;
			}	
			
			if( error ) {
				// An element contained in the array could not be initialized!
				[errorArray addObject:error];
				return nil;
			}	
		}
			break;
			
		case DTModelTypeString: {
			validatedObject = [[self class] validStringForObject:object];
			if( !validatedObject ) {
				// Object could not be validated as NSString.
				[errorArray addObject:[DTError 
					errorWithDomain:DTErrorDomainModel 
					code:DTErrorCodeModelStringValidationError
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
						singleMetaData.propertyKeyPath,
						DTAbstractModelErrorKeyPropertyKey,
						nil]]];
				return nil;
			}
		}
			break;
			
		case DTModelTypeUrl: {
			validatedObject = [[self class] validUrlForObject:object];
			if( !validatedObject ) {
				// Object could not be validated as NSURL.
				[errorArray addObject:[DTError 
					errorWithDomain:DTErrorDomainModel 
					code:DTErrorCodeModelUrlValidationError
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
						singleMetaData.propertyKeyPath,
						DTAbstractModelErrorKeyPropertyKey,
						nil]]];
				return nil;
			}
		}
			break;
			
		default: {
			// %@ type is not implemented in %s.
			[errorArray addObject:[DTError 
				errorWithDomain:DTErrorDomainModel
				code:DTErrorCodeModelDataTypeNotImplemented
				userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
					singleMetaData.propertyKeyPath,
					DTAbstractModelErrorKeyPropertyKey,
					nil]]];
			return nil;
		}
			break;
	}		
	
	return validatedObject;
}

- (void)dealloc {
	id<DTModelProtocol> selfObject = (id<DTModelProtocol>)self;
	DT_ASSERT_RETURN([self respondsToSelector:@selector(propertyMetaData)], 
					 @"Implement %@ in %@!",
					 NSStringFromSelector(@selector(propertyMetaData)), NSStringFromClass([self class]));
	
	NSDictionary *allMetaData = [selfObject propertyMetaData];
	NSArray * const allMetaDataKeys = [allMetaData allKeys];
	
	for (NSString *singleMetaDataKey in allMetaDataKeys ) 
	{
		DTPropertyMetaData *singleMetaData = [allMetaData objectForKey:singleMetaDataKey];
		
		if([singleMetaData isRootProperty]) 
		{
			@try
			{
				[self setValue:nil forKeyPath:singleMetaData.propertyKeyPath];
			}
			@catch ( NSException *e ) 
			{
				DT_LOG(@"ABSTRACT_MODEL", @"Failed to set property at key path %@ of object %@ "
					"to nil: %@", singleMetaData.propertyKeyPath, self, e );
			}
		}
	}
	
	[super dealloc];
}

- (NSDictionary*)propertyMetaData {
	return nil;
}

//MARK: -
//MARK: KVC Overrides

- (void)setNilValueForKey:(NSString *)key {
	// Set the default value '0' for all scalar types that should be set to
	// 'nil' by [self setValue:forKey].
	[self setValue:[NSNumber numberWithInt:0] forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key {
	return nil;
}

//MARK: -
//MARK: NSCopying & NSCoding

- (id) copyWithZone:(NSZone *)zone {
	// Error checking.
	if(![self respondsToSelector:@selector(propertyMetaData)]) {
		DT_ASSERT(NO,
				  @"Implement %@ in %@", 
				  NSStringFromSelector(@selector(propertyMetaData)),
				  NSStringFromClass([self class]));	
		return nil;
	}
	
	// Copy and set properties coming from th meta data.
	id result = [[[self class] allocWithZone:zone] init];
	NSDictionary *allMetaData = [self propertyMetaData];
	for(DTPropertyMetaData *singleMetaData in [allMetaData allValues]) {
		if([singleMetaData isRootProperty]) {
			NSString *propertyKeyPath = singleMetaData.propertyKeyPath;
			id value = [self valueForKeyPath:propertyKeyPath];
			id copiedValue = nil;
			id valueToSet = nil;
			
			// Scalar types dont need to be copied.
			if(singleMetaData.propertyType == DTModelTypeScalar) {
				valueToSet = value;
			}
			else if([value isKindOfClass:[NSDictionary class]]) {
				copiedValue = [[NSDictionary alloc] initWithDictionary:value
															 copyItems:YES];
				valueToSet = copiedValue;
			}
			else if([value isKindOfClass:[NSArray class]]) {
				copiedValue = [[NSArray alloc] initWithArray:value 
												   copyItems:YES];
				valueToSet = copiedValue;
			}
			else {
				copiedValue = [value copy];
				valueToSet = copiedValue;				
			}
			[result setValue:valueToSet forKeyPath:propertyKeyPath];
			[copiedValue release];
		}
	}
	return result;
}

- (id) initWithCoder: (NSCoder *)decoder {
	// Error checking.
	if(![self respondsToSelector:@selector(propertyMetaData)]) {
		DT_ASSERT(NO,
				  @"Implement %@ in %@", 
				  NSStringFromSelector(@selector(propertyMetaData)),
				  NSStringFromClass([self class]));	
		
		[self release];
		self = nil;
		return nil;
	}
	
	id result = nil;	
	if( (result = [self init]) ) 
	{
		// Decode and set only root properties.
		NSDictionary * const allMetaData = [self propertyMetaData];
		for(DTPropertyMetaData *singleMetaData in [allMetaData allValues]) 
		{
			if([singleMetaData isRootProperty]) 
			{
				NSString *propertyKeyPath = singleMetaData.propertyKeyPath;
				id value = [decoder decodeObjectForKey:propertyKeyPath];
				[self setValue:value forKeyPath:propertyKeyPath];
			}
		}
	}
	return result;
}

- (void)encodeWithCoder:(NSCoder *)encoder {	
	// Error checking.
	DT_ASSERT_RETURN([self respondsToSelector:@selector(propertyMetaData)],
					 @"Implement %@ in %@", 
					 NSStringFromSelector(@selector(propertyMetaData)),
					 NSStringFromClass([self class]));
	
	// Encode the properties coming from the meta data..
	NSDictionary *allMetaData = [self propertyMetaData];
	for(DTPropertyMetaData *singleMetaData in [allMetaData allValues]) 
	{
		if([singleMetaData isRootProperty]) 
		{
			NSString *propertyKeyPath = singleMetaData.propertyKeyPath;
			id value = [self valueForKeyPath:propertyKeyPath];
			[encoder encodeObject:value forKey:propertyKeyPath];	
		}
	}
}

//MARK: -
//MARK: Description

- (NSString*)description {
	id<DTModelProtocol> selfObject = (id<DTModelProtocol>)self;
	NSMutableString *result = [NSMutableString stringWithFormat:@"%@:\n", 
		[super description]];
	
	if(![self respondsToSelector:@selector(propertyMetaData)]) {
		DT_ASSERT(NO, 
				  @"Implement %@ in %@!",
				  NSStringFromSelector(@selector(propertyMetaData)),
				  NSStringFromClass([self class]));	
	}
	
	NSDictionary *allMetaData = [selfObject propertyMetaData];
	for (NSString *singleMetaDataKey in [allMetaData allKeys]) {
		DTPropertyMetaData *singleMetaData = [allMetaData objectForKey:singleMetaDataKey];
		
		if([singleMetaData isRootProperty]) {
			id value = [self valueForKeyPath:singleMetaData.propertyKeyPath];
			
			if([value isKindOfClass:[NSArray class]]) {
				[result appendFormat:@"%@: [%@ with %i Elements] : \n [ \n", 
						 singleMetaData.propertyKeyPath, 
						 NSStringFromClass([value class]),  
						 [(NSArray*)value count]];
				 
				for (id containerObject in (NSArray*)value) {
					[result appendFormat:@"\t%@\n", containerObject];
				}
				[result appendString:@"]"];
			}
			else if([value isKindOfClass:[NSDictionary class]]) {
				[result appendFormat:@"%@: [%@ with %i Elements] : \n {", 
						 singleMetaData.propertyKeyPath, 
						 NSStringFromClass([value class]),  
						 [(NSDictionary*)value count]];
						 
				for (id key in [(NSDictionary*)value allKeys]) {
					[result appendFormat:@"\t%@ = \"%@\";\n", key, [(NSDictionary*)value objectForKey:key]];
				}
				[result appendString:@"}"];
			}
			else if([value isKindOfClass:[NSSet class]]) {
				[result appendFormat:@"%@: [%@ with %i Elements]", 
				 singleMetaData.propertyKeyPath, 
				 NSStringFromClass([value class]),  
				 [(NSSet*)value count]];
			}
			else {
				[result appendFormat:@"%@: %@", 
				 singleMetaData.propertyKeyPath,
				 value];
			}			
			[result appendString:@"\n"];
		}
	}	
	
	return result;
}

//MARK: -
//MARK: Parameter validation

+ (NSString*)validStringForObject:(id)object{

	/**
	 @todo (stherold - 2012-07-24): If required we must introduce mandatory and optional versions of model types.
	 */
	
	if ( !object || [object isKindOfClass:[NSString class]] )
	{
		return object ? object : @"";	
	}
	else if ( [object isKindOfClass:[NSNull class]] )
	{
		return @"";
	}
	return nil;
}

+ (NSURL*)validUrlForObject:(id)object{
	if (([object isKindOfClass:[NSURL class]]))
		return (NSURL*)object;	
	else if( ([object isKindOfClass:[NSString class]]) && ([(NSString*)object length] > 0) )
		return [NSURL URLWithString:(NSString*)object];
	
	return nil;
}

+ (NSDate*)validDateForObject:(id)object{
	if ([object isKindOfClass:[NSDate class]])
	{
		return (NSDate*)object;	
	}
	return nil;	
}

+ (NSDictionary*)validDictForObject:(id)object
{
	if ( [object isKindOfClass:[NSDictionary class]] )
	{
		return (NSDictionary*)object;
	}
	return nil;
}

+ (NSArray*)validArrayForObject:(id)object
{
	if ( [object isKindOfClass:[NSArray class]] )
	{
		return (NSArray*)object;
	}
	return nil;
}

+ (NSNumber*)validNumberForObject:(id)object{
	NSNumber * result = nil;
	if ([object isKindOfClass:[NSNumber class]])
	{
		result = (NSNumber *)object;
	}
	else if ( [object isKindOfClass:[NSNull class]] )
	{
		// Set all NSNull numbers to 0
		result = [NSNumber numberWithInt:0];
	}
	// Boolean values are treated as scalars / NSNumbers too
	else if ([object isKindOfClass:[NSString class]])
	{
		if([(NSString *) object isEqualToString:@"true"]) {
			result = [NSNumber numberWithInt:1];
		}
		else if ([(NSString *) object isEqualToString:@"false"]) {
			result = [NSNumber numberWithInt:0];
		}
		else if ([(NSString *) object isEqualToString:@"null"]) {
			result = [NSNumber numberWithInt:0];
		}
		else {
			DT_LOG(@"MODEL_INIT", @"Expected Number ... got String (%@): %@", NSStringFromClass([self class]), object);
		
			// Try to 	1) convert the object to a string value.
			//			2) extract the scalar.
			//			3) wrap that scalar into a number object.
			
			NSString * validatedObjectAsString = [[self class] validStringForObject:object];

			if( validatedObjectAsString ) {
				long long objectAsScalar = [validatedObjectAsString longLongValue];
				result = [NSNumber numberWithLongLong:objectAsScalar];
				result = [[self class] validNumberForObject:result];
			}
		}
	}
	return result;
}

+ (BOOL)checkPropertyMetaData:(NSDictionary*)dictionary error:(NSError**)error {
	NSMutableArray *errorArray = [NSMutableArray array];
	
	//
	// Check for wrong types in propertyMetaData dictionary.
	//
	
	for (NSString *singleMetaDataKey in [dictionary allKeys]) {
		id object = [dictionary objectForKey:singleMetaDataKey];
		
		// Construct error object.
		if( ![object isKindOfClass:[DTPropertyMetaData class]] ) {
			NSString *description = [NSString stringWithFormat:@"The type of an element is of kind %@ instead of %@", 
									 NSStringFromClass([object class]),
									 NSStringFromClass([DTPropertyMetaData class])];
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description
																 forKey:NSLocalizedDescriptionKey];
			
			[errorArray addObject:[DTError errorWithDomain:DTErrorDomainModel 
													  code:DTErrorCodeModelPropertyMetaDataContainsWrongTypedElement
												  userInfo:userInfo]];
		}
	}
	
	//
	// Check for duplicate propertyKeyPaths.
	//
	/*
	NSArray *distinctUnionOfObjetcs = [[dictionary allValues] valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@", DTPropertyMetaDataPropertyKeyKeyPath]];
	NSArray *unionOfObjetcs = [[dictionary allValues] valueForKeyPath:[NSString stringWithFormat:@"@unionOfObjects.%@", DTPropertyMetaDataPropertyKeyKeyPath]];
	if([distinctUnionOfObjetcs count] != [unionOfObjetcs count]) {
		[errorArray addObject:[DTError errorWithDomain:DTErrorDomainModel
												  code:DTErrorCodeModelPropertyMetaDataDuplicatePropertyKeyPaths]];
	}
	*/
	//
	// Check if an error occurred.
	//
	
	if([errorArray count]) {
		if(error) {			   
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorArray
																 forKey:DTAbstractModelErrorKeyUnderlyingErrors];
			*error = [DTError errorWithDomain:DTErrorDomainModel
										 code:DTErrorCodeModelPropertyMetaDataPlausibilityCheckErrorsOccurred
									 userInfo:userInfo];
		}
		return NO;
	}
	return  YES;
}

@end
