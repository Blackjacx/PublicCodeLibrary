/*!
 \file		
 \brief		Header file containing the protocol for the DLSi model 
 entities.
 \details	All model sub classes must implement this protocol to provide support 
 for transformation between the proxy data format (currently JSON) and the 
 internal data structures. This protocol is especially intended to handle the 
 KVC pattern.
 \attention Copyright 2010 Deutsche Telekom AG. All rights reserved.
 \author	Stefan Herold
 \date		2010-11-15
 */

#import <Foundation/Foundation.h>

@protocol DTModelProtocol <NSObject, NSCopying, NSCoding>

@required

+ (id)alloc;

/*!
 \name Initialization
 
 @{
 */

/*!
 \brief The designated initializer when receiving an answer from the backend.
 \details The answer from the backend is parsed into a dictionary that is input for this method.
 \param dictionary The dictionary that is created by a parser that parsed the backend answer.
 \param error A pointer to a \c NSError reference which, if non-NULL, is set
    if the object could not have been created.
 \return An object of type MCAbstractModel or \c nil.
 */
- (id)initWithDictionary:(NSDictionary*)dictionary error:(NSError**)error;

//!@}

/*!
 \name Property Meta Data
 
 @{
 */

/*!
 \brief Protocol method for obtaining meta data for each property.
 \details The returned object contains meta data about the actual properties of 
 this object but also meta data of the elements of NSDictionary properties.
 \attention It is mandatory to implement this method in subclasses of 
 MCAbstractModel to support a correct KVC implementation in the base class.
 \returns An object of type NSDictionary containing the objects of type 
 MCPropertyDescription.
 */
- (NSDictionary*)propertyMetaData;

//!@}

@end