/*!
 @file		NSData+PCLExtensions.m
 @brief		Extensions for the class NSData
 @author	Stefan Herold
 @date		2012-12-16
 @copyright	Copyright (c) 2012 Stefan Herold. All rights reserved.
 */

#import "NSData+PCLExtensions.h"
#import "UIDevice+PCLExtensions.h"

@implementation NSData (PCLExtensions)

// MARK: Encoding and Decoding Base64

- (NSString *)pcl_encodedBase64String
{
	NSString * base64EncodedString = nil;

	if( [UIDevice pcl_isIOS7] )
	{
		base64EncodedString = [self base64EncodedStringWithOptions:0];
	}
	else
	{
		base64EncodedString = [self base64Encoding];
	}
	return base64EncodedString;
}

+ (NSData *)pcl_decodedDataFromBase64String:(NSString *)base64String
{
	NSData *decodedData = nil;

	if( [UIDevice pcl_isIOS7] )
	{
		decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
	}
	else
	{
		decodedData = [[NSData alloc] initWithBase64Encoding:base64String];
	}
	return decodedData;
}

@end