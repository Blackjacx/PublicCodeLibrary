/*!
 @brief		NSString category based extensions
 @author	*** ***
 @date		2011-10-24
 @copyright	Copyright (c) 2012 Blackjacx & Co. All rights reserved.
 */

#import "NSString+PCLExtensions.h"


@implementation NSString (PCLExtensions)

// MARK: 
// MARK: Lorem Ipsum Generation

+ (NSString*) loremIpsumWithValue:(NSUInteger)aLengthOrCount type:(NSStringLoremIpsumType)aType
{
	NSString * result;
	NSString * const separationString = @" ";
	static NSString * loremIpsumBaseString = @"Lorem ipsum dolor sit amet, cons"
		"ectetuer adipiscing elit. Nam cursus. Morbi ut mi. Nullam enim leo, eg"
		"estas id, condimentum at, laoreet mattis, massa. Sed eleifend nonummy "
		"diam. Praesent mauris ante, elementum et, bibendum at, posuere sit ame"
		"t, nibh. Duis tincidunt lectus quis dui viverra vestibulum. Suspendiss"
		"e vulputate aliquam dui. Nulla elementum dui ut augue. Aliquam vehicul"
		"a mi at mauris. Maecenas placerat, nisl at consequat rhoncus, sem nunc"
		" gravida justo, quis eleifend arcu velit quis lacus. Morbi magna magna"
		", tincidunt a, mattis non, imperdiet vitae, tellus. Sed odio est, auct"
		"or ac, sollicitudin in, consequat vitae, orci. Fusce id felis. Vivamus"
		" sollicitudin metus eget eros.";
		
	if ( NSStringLoremIpsumTypeMaxLength == aType || NSStringLoremIpsumTypeMaxWords == aType ) {
		// Generate a random number between 1 (!) and the max length | count
		aLengthOrCount = (arc4random() % aLengthOrCount) + 1;
	}
	
	switch (aType) 
	{
		case NSStringLoremIpsumTypeLength:
		case NSStringLoremIpsumTypeMaxLength: {
			if( aLengthOrCount > loremIpsumBaseString.length ) {
				NSString * tmpString = [[loremIpsumBaseString stringByAppendingString:separationString] 
						repeat:(NSUInteger)(aLengthOrCount / loremIpsumBaseString.length + 1)];
				result = [tmpString substringToIndex:aLengthOrCount];
			}
			else {
				result = [loremIpsumBaseString substringToIndex:aLengthOrCount];
			}
		}    
		break;
		
		case NSStringLoremIpsumTypeWords:
		case NSStringLoremIpsumTypeMaxWords: {
			NSMutableArray * resultingWordList = [[NSMutableArray alloc] 
					initWithCapacity:aLengthOrCount];
			NSArray * loremIpsumExploded = [loremIpsumBaseString 
					componentsSeparatedByString:separationString];
			NSUInteger loremIpsumWordCount = loremIpsumExploded.count;
			for (NSUInteger i=0; i<loremIpsumWordCount; i++) {
				// Modulo for the case: requested count > word count
				[resultingWordList addObject:
					loremIpsumExploded[(i % loremIpsumWordCount)]];
			}
			result = [resultingWordList componentsJoinedByString:separationString];
		}    
		break;
	}
	return result;
}

+ (NSString*) loremIpsumWithLength:(NSUInteger)aLength {
	return [self loremIpsumWithValue:NSStringLoremIpsumTypeLength type:aLength];
}

+ (NSString*) loremIpsumWithMaxLength:(NSUInteger)aLength {
	return [self loremIpsumWithValue:NSStringLoremIpsumTypeMaxLength type:aLength];
}

+ (NSString*) loremIpsumWithWords:(NSUInteger)aCount {
	return [self loremIpsumWithValue:NSStringLoremIpsumTypeWords type:aCount];
}

+ (NSString*) loremIpsumWithMaxWords:(NSUInteger)aCount {
	return [self loremIpsumWithValue:NSStringLoremIpsumTypeMaxWords type:aCount];
}

// MARK: 
// MARK: Repeating Strings

- (NSString*)repeat:(NSUInteger)times {
	NSMutableString * mutableResult = [self mutableCopy];
	for( NSUInteger i=0; i<times; i++ ) {
		[mutableResult appendString:self];
	}
	NSString * immutableResult = [mutableResult copy];
	
	return immutableResult;
}

// MARK: 
// MARK: URL Encoding

- (NSString *)URLEncodedString 
{
    if (self == nil)
		return nil;
	CFStringRef preprocessedString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, 
																							 (CFStringRef) self, 
																							 CFSTR(""), 
																							 kCFStringEncodingUTF8);
    CFStringRef resultRef = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           preprocessedString,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);							   
	NSString * result = (__bridge NSString*)resultRef;
																
	CFRelease(resultRef);
	CFRelease(preprocessedString);
	return result;
}

- (NSString *)URLDecodedString
{
	CFStringRef resultRef = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8);
	NSString * result = (__bridge NSString*)resultRef;
	CFRelease(resultRef);
	return result;
}

// MARK: 
// MARK: UUID Generation

+ (NSString*)uniqueID
{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef uuidStringRef = CFUUIDCreateString(kCFAllocatorDefault,uuidRef);
	NSString * uuid = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
	CFRelease(uuidRef);
	CFRelease(uuidStringRef);
	return uuid;
}

// MARK: 
// MARK: Comparison

- (BOOL)isNotEqualToString:(NSString*)aString
{
    return [self compare:aString] != NSOrderedSame;
}

- (BOOL)isLowerToString:(NSString*)aString
{
    return [self compare:aString] == NSOrderedAscending;
}

- (BOOL)isLowerEqualToString:(NSString*)aString
{
    return [self compare:aString] != NSOrderedDescending;
}

// MARK: 
// MARK: Truncation

- (NSString*)trim
{
    return [self stringByTrimmingCharactersInSet:
            [NSCharacterSet 
             whitespaceAndNewlineCharacterSet]];
}

- (NSString*)truncatedToWidth:(CGFloat)aWidth withFont:(UIFont*)aFont
{
    NSMutableString * result  = [self mutableCopy];
    NSString * const ellipsis = @"...";
    
    if( [self sizeWithFont:aFont].width > aWidth )
    {
        aWidth -= [ellipsis sizeWithFont:aFont].width;
        
        NSRange resultRange = {[result length] - 1, 1};
        
        while ( [result sizeWithFont:aFont].width > aWidth ) 
        {
            [result deleteCharactersInRange:resultRange];
            resultRange.location--;
        }
        
        [result replaceCharactersInRange:resultRange withString:ellipsis];
    }
    return result;
}

// MARK: 
// MARK: Strings Length 

- (BOOL)empty
{
    return [[self trim] length] == 0;
}

// MARK: 
// MARK: File Paths

- (NSString*)concatWithDocumentsDirectoryPath
{
    NSString * result = nil;    
    NSError * anError = nil;
    NSURL * const documentsDirectroryUrl = [[NSFileManager defaultManager]
                                                          URLForDirectory:NSDocumentDirectory
                                                                 inDomain:NSUserDomainMask
                                                        appropriateForURL:NULL
                                                                   create:YES 
                                                                    error:&anError];
    
    if( !anError && documentsDirectroryUrl )
    {
        result = [[documentsDirectroryUrl absoluteString] 
                  stringByAppendingPathComponent:self];
    }    
    
    return result;
}

- (NSString*)concatWithTemporaryDirectoryPath
{
    NSString * result = nil;    
    NSError * anError = nil;
    NSURL * const temporaryDirectroryUrl = [[NSFileManager defaultManager]
                                            URLForDirectory:NSItemReplacementDirectory
                                            inDomain:NSUserDomainMask
                                            appropriateForURL:NULL
                                            create:YES
                                            error:&anError];
    
    if( !anError && temporaryDirectroryUrl )
    {
        result = [[temporaryDirectroryUrl absoluteString] 
                  stringByAppendingPathComponent:self];
    }    
    
    return result;    
}

// MARK: 
// MARK: Regular Expression Checking

- (BOOL)matchesRegularExpression:(NSString*)regexPattern
{
	NSError * error = nil;
	
	NSRegularExpression * regex = [NSRegularExpression 
			regularExpressionWithPattern:regexPattern
			options:NSRegularExpressionCaseInsensitive
			error:&error];
			
	// --- regex creation generated error
	if( error ) {
		return NO;
	}
	
	NSRange expectedRangeOfMatch = NSMakeRange(0, [self length]);
	NSRange actualRangeOfMatch = [regex rangeOfFirstMatchInString:self options:0 range:expectedRangeOfMatch];
	BOOL regexMatched = [NSStringFromRange(expectedRangeOfMatch) 
			isEqualToString:NSStringFromRange(actualRangeOfMatch)];
	
	// --- regex didn't match
	if( !regexMatched ) {
		return NO;
	}
	
	// --- everything worked fine
	return YES;
}

@end
