//
//  DTStrings.h
//  IphoneEPG
//
//  Created by Pierre Bongen on 17.07.09.
//  Copyright 2009 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

// MARK: Declaring and Defining Strings

/*!
	\name Declaring and Defining Strings
	
	@{
*/

#define DT_DECLARE_STRING( name ) extern NSString * const name;
#define DT_DEFINE_STRING_WITH_AUTO_VALUE( name ) NSString * const name = @ #name;
#define DT_DEFINE_STRING( name, value ) NSString * const name = @ value;

//!@}



// MARK: -
// MARK: Declaring and Defining Keys

/*!
	\name Declaring and Defining Keys
	
	@{
*/

#define DT_DECLARE_KEY( key ) extern NSString * const key;
#define DT_DEFINE_KEY( key ) NSString * const key = @ #key;
#define DT_DEFINE_KEY_WITH_PROPERTY( key, property ) NSString * const key = @ #property;
#define DT_DEFINE_KEY_WITH_VALUE( key, value ) NSString * const key = @ value;

//!@}



// MARK: -
// MARK: Stringification

/*!
	\name Stringification
	
	@{
*/

#define DT_STRINGIFY( ID ) ( @ #ID )

//!@}