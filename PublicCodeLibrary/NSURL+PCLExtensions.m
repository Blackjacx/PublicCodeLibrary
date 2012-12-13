//
//  NSURL+PCLExtensions.m
//  PrivateCodeLibrary
//
//  Created by *** *** on 9/20/11.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#import "NSURL+PCLExtensions.h"

// Library Imports
#import "NSString+PCLExtensions.h"

@implementation NSURL (PCLExtensions)

// MARK: 
// MARK URL Creation

+ (NSURL *)URLWithRoot:(NSString *)root
		path:(NSString *)path 
		getParameters:(NSDictionary *)getParameters
{	
	NSMutableString * URLAsString = [NSMutableString stringWithString:root];
	
	if ( [path length] > 0 ) {
		NSString * urlWithPath = [URLAsString stringByAppendingPathComponent:path];
		URLAsString = [NSMutableString stringWithString:urlWithPath];
	}
	
	NSArray * const parameterKeys = [getParameters allKeys];
	BOOL isFirstParameter = YES;
	
	for ( NSString * key in parameterKeys )
	{
		NSString * const parameter = getParameters[key];
		NSString * const escapedParameter = [parameter URLEncodedString];
		
		if ( isFirstParameter ) {
			isFirstParameter = NO;
			[URLAsString appendString:@"?"];
		}
		else {
			[URLAsString appendString:@"&"];
		}
		
		[URLAsString appendFormat:@"%@=%@", key, escapedParameter];
	}
	
	return [NSURL URLWithString:URLAsString];
}

@end
