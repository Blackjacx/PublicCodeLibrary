//
//  NSString+DTExtensions.m
//  DTFoundation
//
//  Created by Stefan Herold on 12.05.11.
//  Copyright 2011 Deutsche Telekom AG. All rights reserved.
//

#import "NSString+DTExtensions.h"

// Frameworks
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (DTExtensions)

- ( BOOL ) isEmpty
{
	if( !self )
		return YES;
		
	return [[self trim] length] == 0;
}

- ( BOOL ) isNotEmpty
{
	return ![self isEmpty];
}

- ( NSString * ) trim
{
	return [self stringByTrimmingCharactersInSet:
					[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- ( BOOL ) isNotEqualToString:(NSString *)aString
{
	return [self compare:aString] != NSOrderedSame;
}

- ( BOOL ) isLowerToString:(NSString *)aString
{
	return [self compare:aString] == NSOrderedAscending;
}

- ( BOOL ) isLowerEqualToString:(NSString *)aString
{
	return [self compare:aString] != NSOrderedDescending;
}

- ( NSString * ) truncatedToWidth:(CGFloat)aWidth usingFont:(UIFont *)aFont
{
	NSMutableString * result = [[self mutableCopy] autorelease];
	NSString * ellipsis = @"...";
	
	if( [self sizeWithFont:aFont].width > aWidth ) {
		aWidth -= [ellipsis sizeWithFont:aFont].width;
	}
	
	NSRange outRange = { [result length] - 1, 1};
	
	while ( [self sizeWithFont:aFont].width > aWidth ) {
		[result deleteCharactersInRange:outRange];
		outRange.location--;
	}
	
	return result;
}

// MARK: 
// MARK: UUID Generation

+ (NSString*)uuid 
{
	CFUUIDRef UUID = CFUUIDCreate( NULL );
	NSString * UUIDAsString = (NSString*)CFUUIDCreateString( NULL, UUID );
	CFRelease( UUID );

	return [UUIDAsString autorelease];
}

// MARK: 
// MARK: URL Encoding

- (NSString *)URLEncode 
{
    if (self == nil)
		return nil;

	NSString * preprocessedString = [(NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																							 (CFStringRef) self,
																							 CFSTR(""),
																							 kCFStringEncodingUTF8) autorelease];
	
	if( !preprocessedString )
		preprocessedString = self;
		
    NSString * result = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)preprocessedString,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]{}<> |^"),
                                                                           kCFStringEncodingUTF8) autorelease];	
	return result;
}

- (NSString *)URLDecode
{
	NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8);
    [result autorelease];
	return result;	
}

// MARK: 
// MARK: SHA512 Hash Generation 

- (NSString*)sha512HashFromUTF8String
{
	NSData * const stringData = [self dataUsingEncoding:NSUTF8StringEncoding 
											allowLossyConversion:NO];
	// Create a SHA512 digest and store it in digest
	uint8_t digest[CC_SHA512_DIGEST_LENGTH] = {0};
	CC_SHA512(stringData.bytes, stringData.length, digest);	
	
	// Now convert to NSData structure to make it usable again
    NSData * const hashedData = [NSData dataWithBytes:digest length:CC_SHA512_DIGEST_LENGTH];
	NSString * hashString = [hashedData description];
	hashString = [hashString stringByReplacingOccurrencesOfString:@" " withString:@""];
    hashString = [hashString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hashString = [hashString stringByReplacingOccurrencesOfString:@">" withString:@""];

	return hashString;
}

// MARK: Byte Conversion

+ (NSString *)stringByConvertingBytesToHumanReadableFormat:(DTFileSize)byteCount {

	NSString * result = @"";

	// > 1 TB
	if ( byteCount > 0x10000000000 ) {

		result = [NSString stringWithFormat:@"%.2f TB", byteCount / (double)0x10000000000];
	}
	// > 1 GB
	else if( byteCount > 0x40000000 ) {

		result = [NSString stringWithFormat:@"%.2f GB", byteCount / (double)0x40000000];
	}
	// > 1 MB
	else if( byteCount > 0x100000 ) {

		result = [NSString stringWithFormat:@"%.2f MB", byteCount / (double)0x100000];
	}
	// > 1 kB
	else if( byteCount > 0x400 ) {

		result = [NSString stringWithFormat:@"%lld kB", byteCount / 0x400];
	}
	else {
		
		result = [NSString stringWithFormat:@"%lld Byte", byteCount];
	}
	return result;
}

@end
