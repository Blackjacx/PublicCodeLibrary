//
//  DTUtilities.m
//  DTLibrary
//
//  Created by Stefan Herold on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DTUtilities.h"

@implementation DTUtilities

+ (NSString *)userVisibleAppVersionString {
	NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"DTAppVersion"];

	// Trim the most current revision from the version string
	NSRange range = [version rangeOfString:@":"];
	if( range.location != NSNotFound ) {
		range.length = [version length] - range.location;
		version = [version stringByReplacingCharactersInRange:range withString:@""];
	}

	// Trim the modified character from the version string
	version = [version stringByReplacingOccurrencesOfString:@"M" withString:@""];
	
	if (!version) {
		version =  @"n.a.";
	} 
	
	return version;
}

@end
