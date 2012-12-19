/*!
 \file		
 \brief		Header file declaring the base class for an DLSi model entity.
 \details	This file holds base declarations for all DLSi model entities.
 \attention Copyright 2010 Deutsche Telekom AG. All rights reserved.
 \author	Stefan Herold
 \author    Pierre Bongen
 \date		2010-11-15
 */

#import <Foundation/Foundation.h>

// DTLibrary.
#import "DTModelProtocol.h"
#import "DTPropertyMetaData.h"
#import "DTStrings.h"
#import "DTDebugging.h"

DT_DECLARE_STRING(DTErrorDomainModel);

//! \brief Error codes for the \c DTErrorDomainModel error domain.
typedef enum _DTErrorCodeModel {
	DTErrorCodeModelRootDictionaryInvalid								= 1000,
	DTErrorCodeModelPropertyMetaDataSelectorNotFound					= 1001,
	DTErrorCodeModelUnknownValidationError								= 1002,
	DTErrorCodeModelJsonKeyPathMissing									= 1003,
	DTErrorCodeModelUndefinedJsonKeyPath								= 1004,
	DTErrorCodeModelDictionaryValidationError							= 1005,
	DTErrorCodeModelArrayOfUniformTypeValidationError					= 1007,
	DTErrorCodeModelMissingPropertyClass								= 1008,
	DTErrorCodeModelUnknownValidationErrorInitializingInternalObject	= 1009,
	DTErrorCodeModelScalarValidationError								= 1010,
	DTErrorCodeModelDateValidationError									= 1011,
	DTErrorCodeModelStringValidationError								= 1012,
	DTErrorCodeModelUrlValidationError									= 1013,
	DTErrorCodeModelDataTypeNotImplemented								= 1014,
	DTErrorCodeModelPropertyMetaDataContainsWrongTypedElement			= 1015,
	DTErrorCodeModelPropertyMetaDataDuplicatePropertyKeyPaths			= 1016,
	DTErrorCodeModelPropertyMetaDataPlausibilityCheckErrorsOccurred		= 1017,
	
	DTErrorCodeModelParseErrorsOccurred									= 2000
} DTErrorCodeModel;

DT_DECLARE_KEY( DTAbstractModelErrorKeyPropertyKey );
DT_DECLARE_KEY( DTAbstractModelErrorKeyJSONKeyPath );
DT_DECLARE_KEY( DTAbstractModelErrorKeyUnderlyingErrors );


@interface DTAbstractModel : NSObject <DTModelProtocol> {
}

//MARK: -
//MARK: Validation & Plausibility Checks
/*!
 \brief Method to validate an object that is expected to be a non-zero length NSString.
 \param object Object to validate.
 \return The valid string object or \c nil.
 */
+ (NSString*)validStringForObject:(id)object;
/*!
 \brief Method to validate an object that is expected to be a NSURL.
 \param object Object to validate.
 \return The valid url object or \c nil.
 */
+ (NSURL*)validUrlForObject:(id)object;
/*!
 \brief Method to validate an object that is expected to be a NSDate.
 \param object Object to validate.
 \return The valid date object or \c nil.
 */
+ (NSDate*)validDateForObject:(id)object;
/*!
 \brief Method to validate an object that is expected to be a non-zero counted NSDictionary.
 \param object Object to validate.
 \return The valid dictionary object or \c nil.
 */
+ (NSDictionary*)validDictForObject:(id)object;
/*!
 \brief Method to validate an object that is expected to be a non-zero counted NSArray.
 \param object Object to validate.
 \return The valid array object or \c nil.
 */
+ (NSArray*)validArrayForObject:(id)object;
/*!
 \brief Method to validate an object that is expected to be a NSNumber.
 \param object Object to validate.
 \return The valid number object or \c nil.
 */
+ (NSNumber*)validNumberForObject:(id)object;
/*!
 \brief Checks the propertyMetaData dictionary for plausibility.
 \param dictionary The dictionary containing the meta data for all properties.
 \param error A reference to an error pointer that will contain the error in case of such.
 \return YES in case of an plausible or NO in case of an invalid dictionary. 
 */
+ (BOOL)checkPropertyMetaData:(NSDictionary*)dictionary error:(NSError**)error;



@end