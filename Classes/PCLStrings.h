/*!
 @file		PCLStrings.h
 @brief		Macros for declaring/defining strings
 @author	Stefan Herold
 @date		2011-10-24
 @copyright	Copyright (c) 2012 Stefan Herold. All rights reserved.
 */

// MARK: Declaring and Defining Strings
/*!
	\name Declaring and Defining Strings
	@{
*/
#define PCL_DECLARE_STRING( name ) extern NSString * const name;
#define PCL_DEFINE_STRING( name, value ) NSString * const name = value;
//!@}


// MARK: Declaring and Defining Keys
/*!
	\name Declaring and Defining Keys
	@{
*/
#define PCL_DECLARE_KEY( key ) extern NSString * const key;
#define PCL_DEFINE_KEY( key ) NSString * const key = @#key;
#define PCL_DEFINE_KEY_WITH_VALUE( key, value ) NSString * const key = value;
//!@}