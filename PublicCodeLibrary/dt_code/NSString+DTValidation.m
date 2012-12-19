//
//  NSString+Validation.m
//  DTLibrary
//
//  Created by Said El Mallouki on 21.12.10.
//  Copyright 2010 mallouki.de. All rights reserved.
//

#import "NSString+DTValidation.h"


@implementation NSString(DTValidation)

- (BOOL)matchesRegexPattern:(NSString*)pattern
{
	NSError * regexConstructionError = nil;
	NSRegularExpression * regex = [NSRegularExpression
			regularExpressionWithPattern:pattern
			options:NSRegularExpressionCaseInsensitive
			error:&regexConstructionError];
			
	// --- regex creation generated error
	if( regexConstructionError ) {
		return NO;
	}
	
	NSRange expectedRange = NSMakeRange(0, [self length]);
	NSRange actualRange = [regex rangeOfFirstMatchInString:self options:0 range:expectedRange];
	BOOL isMatch = [NSStringFromRange(expectedRange) isEqualToString:NSStringFromRange(actualRange)];
	
	// --- regex didn't match
	if( !isMatch ) {
		return NO;
	}
		
	// --- everything worked fine
	return YES;
}

- (BOOL)isValidEmail
{	
	// This one is better than the one from the net below. 
	// It declines domains with more than 4 characters. 
	// The below one does this not (but it should - there must be an error).
	NSString * const emailRegex = @"([A-Z0-9a-z_%+-]|([A-Z0-9a-z_%+-]+[A-Z0-9a-z._%+-]*[^.]))@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";		
	
	// --- found at: http://www.regular-expressions.info/email.html (read the discussion)
//	NSString * const emailRegex = @"^[A-Z0-9._%+-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4}$";
	
	BOOL result = [self matchesRegexPattern:emailRegex];		
	
	if( result ) {
		// --- check for multiple dots
		NSString * const multipleDotsRegex = @"^.*[.]{2,}.*$";
		result = ![self matchesRegexPattern:multipleDotsRegex];
	}
    
    if (result)
    {
        // --- check for @@
        NSString * twoAt = @"@@";
        NSRange range = [self rangeOfString:twoAt];
        result = !(range.length > 0);
    }
	return result;
}

@end
