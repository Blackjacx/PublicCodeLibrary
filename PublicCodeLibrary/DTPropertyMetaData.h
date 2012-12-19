//
//  DTPropertyMetaData.h
//  MedienCenter
//
//  Created by Stefan Herold on 17.11.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

// DTLibrary.
#import "DTStrings.h"

DT_DECLARE_STRING(DTPropertyMetaDataPropertyKeyType)
DT_DECLARE_STRING(DTPropertyMetaDataPropertyKeyKeyPath)
DT_DECLARE_STRING(DTPropertyMetaDataPropertyKeyElementClass)

typedef enum _DTModelType {
	/*!
	 \brief Entries of array types are iterated, sub elements initialized and 
	 stored in an array property.
	 */
	DTModelTypeArrayOfUniformType,
	/*!
	 \brief Entries of this type are preserved as dictionary inside the 
	 business object.
	 */
	DTModelTypeDictionary,
	/*!
	 \brief This type represents all scalar data types such as bool, int, etc.
	 */
	DTModelTypeScalar,
	/*!
	 \brief Entities of this type come as UTC formatted strings from the 
	 backend and are converted to NSDate properties.
	 */
	DTModelTypeDate,
	/*!
	 \brief Set this type to indicate that an entity is of an type that is 
	 implemented in a specific application, e.g. MCDiscoveryInformation, 
	 MCEntity, ...
	 */
	DTModelTypeApplicationSpecific,
	/*!
	 \brief Entities of this type are taken as they are: NSStrings.
	 */
	DTModelTypeString,
	/*!
	 \brief Entities of this type are converted to NSURL.
	 */
	DTModelTypeUrl,
	DTModelTypeMIN = DTModelTypeArrayOfUniformType,
	DTModeltypeMAX = DTModelTypeUrl
} DTModelType;

/*!
 \brief		Declaration of a class encapsulating property meta data / 
 property description.
 \details	This class holds meta data of a property that is needed to 
 operate on objects with the KVC pattern.
 */

@interface DTPropertyMetaData : NSObject {
	//! \brief Needed for type validation in the initializer.
	DTModelType propertyType;
	//! \brief Needed to set property values using KVC.
	NSString *proprtyKeyPath;
	//! \brief Used to store the class of an object behind a property. Prominent use for arrays since element types are equal inside a single array.
	Class propertyElementClass;
}
@property(nonatomic, assign) DTModelType propertyType;
@property(nonatomic, copy)NSString *propertyKeyPath;
@property(nonatomic, retain)Class propertyElementClass;

// MARK: -
// MARK: Conversions

+ (NSString *)stringFromModelType:(DTModelType)modelType;

//MARK: -
//MARK: Initializing

/*!
 \brief Designated initializer.
 \param aType The internal type specifier used to determine the properties class.
 \param aKeyPath The fully qualified key path to the property (it can also lay inside a dictionary/array).
 \param anElementClass The class of the object behind the property. 
 \return An initialized object of the class's type.
 */
- (id)initWithType:(NSUInteger)aType 
		   keyPath:(NSString*)aKeyPath
	  elementClass:(Class)anElementClass;

/*!
 \brief An initializer.
 \param aType The internal type specifier used to determine the properties class.
 \param aKeyPath The fully qualified key path to the property (it can also lay inside a dictionary/array).
 \return An initialized object of the class's type.
 */
- (id)initWithType:(NSUInteger)aType 
		   keyPath:(NSString*)aKeyPath;

/*!
 \brief Designated convenience constructor.
 \param aType The internal type specifier used to determine the properties class.
 \param aKeyPath The fully qualified key path to the property (it can also lay inside a dictionary/array).
 \param anElementClass The class of the object behind the property. 
 \return An initialized object of the class's type.
 */
+ (id)propertyWithType:(NSUInteger)aType 
			   keyPath:(NSString*)aKeyPath
		  elementClass:(Class)anElementClass;

/*!
 \brief An convenience constructor.
 \param aType The internal type specifier used to determine the properties class.
 \param aKeyPath The fully qualified key path to the property (it can also lay inside a dictionary/array).
 \return An initialized object of the class's type.
 */
+ (id)propertyWithType:(NSUInteger)aType
			   keyPath:(NSString*)aKeyPath;


//MARK: -
//MARK: Key handling

/*!
 \name Key handling (Key-Value Coding).
 \brief These methods all operate on the property propKeyPath.
 @{
 */

/*!
 \brief Determines the key from a key path or a key. Keys are seperated by '.'.
 \return The last element of a key path, called the key or the key if it is taken as input.
 */
- (NSString*)keyFromKeyPath;
/*!
 \brief Determines the base path from a key path.
 \return All elements except the last key from a key path or \c nil if a key is taken as input.
 */
- (NSString*)basePathFromKeyPath;
/*!
 \brief Determines if the key path has a base path.
 \return \c NO if a base path is found (input must have more than one single key seperated by '.') or the input is \c nil. Else \c YES is returned.
 */
- (BOOL)isRootProperty;

//!@}

@end
