//
//  NSURLRequest+DTExtendedDescription.m
//  DTLibrary
//
//  Created by Pierre Bongen on 08.12.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "NSURLRequest+DTExtendedDescription.h"


@implementation NSURLRequest ( DTExtendedDescription )

// MARK: 
// MARK: Extended Description

- (NSString *)extendedDescription
{
	NSMutableString * const mutableResult = [NSMutableString 
		stringWithFormat:@"%@\n", [self description]];
	
	// Add header fields.
	NSDictionary * const HTTPHeaderFields = [self allHTTPHeaderFields];
	NSArray * const fieldNames = [HTTPHeaderFields allKeys];
	
	for ( NSString *fieldName in fieldNames )
	{
		[mutableResult appendFormat:@"%@ = %@\n", 
			fieldName, 
			[HTTPHeaderFields objectForKey:fieldName]];
	}
	
	[mutableResult appendFormat:@"\n HTTP Method is %@", [self HTTPMethod]];
	//[mutableResult appendFormat:@"\n HTTP Body is %@", [self HTTPBody]];
	
	return mutableResult;
}

@end
