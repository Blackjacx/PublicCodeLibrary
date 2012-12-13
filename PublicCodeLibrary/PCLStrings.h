/*!
 @brief		Definition of useful macros for declaring/defining strings.
 @author	Blackjacx
 @date		2011-10-24
 @copyright	Copyright (c) 2012 Blackjacx & Co. All rights reserved.
 */


// MARK: 
// MARK: Declaring and Defining Strings

/*!
	\name Declaring and Defining Strings
	
	@{
*/

#define PCL_DECLARE_STRING( name ) extern NSString * const name;
#define PCL_DEFINE_STRING( name, value ) NSString * const name = value;

//!@}



// MARK: 
// MARK: Declaring and Defining Keys

/*!
	\name Declaring and Defining Keys
	
	@{
*/

#define PCL_DECLARE_KEY( key ) extern NSString * const key;
#define PCL_DEFINE_KEY( key ) NSString * const key = @#key;

//!@}