//
//  DTError.h
//  DTFoundation
//
//  Created by Pierre Bongen on 2010-11-24.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "DTStrings.h"

DT_DECLARE_STRING( DLSErrorDomain );


/*!
	\brief \c NSError sub-class enriched with convenience.
	
	\section DTError_Overview Overview
	
	This class uses the domain and the code of an error to access localised
	string tables in order to set the error description as well as the failure
	reason. The strings obtained from the string tables are regarded as format
	strings which may contain <tt>\%\@</tt> format specifiers. If present the 
	values for these format specifiers are provided through arrays containing
	objects of an arbitrary class, most likely \c NSString objects though.
	
	\section DTError_String_Tables String Tables
	
	The string tables are <tt>*.strings</tt> files. Their name's are composed
	using the error domain for which they contain the description and failure
	reason strings and the <tt>.strings</tt> file extension. For example,
	<tt>de.telekom.mediencenter.backend_errors.strings</tt> could be the strings
	file for errors of the error domain 
	<tt>de.telekom.mediencenter.backend_errors</tt>.

	The keys of the key-value pairs in the string tables need to comply with the
	following pseudo BNF:
	
	<tt>'D'|'F'\<integer_error_code_as_string\></tt>
	
	<tt>D</tt> is used to denote the error description of an error, <tt>F</tt>
	to denite the failure reason. For example, <tt>"D1025"</tt> is the key of 
	the error description of the error no. \c 1025.
*/
@interface DTError : NSError 

// MARK: Register Bundles

+ (void)registerBundle:(NSBundle *)bundle forErrorDomain:(NSString *)errorDomain;

// MARK: Init

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)userInfo;
+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code;

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)userInfo;
- (id)initWithDomain:(NSString *)domain code:(NSInteger)code;

@end
