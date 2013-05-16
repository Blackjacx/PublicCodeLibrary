/*!
 @file		NSData+PCLExtensions.m
 @brief		Extensions for the class NSData
 @author	Stefan Herold
 @date		2012-12-16
 @copyright	Copyright (c) 2012 Stefan Herold. All rights reserved.
 */

#import "NSData+PCLExtensions.h"

char const NSDataBase64CharacterTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";


NSUInteger pcl_unsignedIntegerForBase64Byte( uint8_t const byte );


@implementation NSData (PCLExtensions)


// MARK: Helper Method

NSUInteger pcl_unsignedIntegerForBase64Byte( uint8_t const byte )
{
	for ( NSUInteger i = 0; i < 64; i++ )
	{
		if ( byte == NSDataBase64CharacterTable[ i ] )
			return i;
	}

	return NSUIntegerMax;
}


// MARK: Encoding and Decoding Base64

- (NSString *)pcl_encodedBase64String
{
	NSString * result = nil;
	
	NSUInteger const lengthOfData = [self length];
    NSMutableData * const base64Data = [[NSMutableData alloc] 
		initWithLength:((lengthOfData + 2) / 3) * 4];
		
    uint8_t* const input = (uint8_t*)[self bytes];
    uint8_t* const output = (uint8_t*)[base64Data bytes];
	
    for ( NSUInteger i = 0; i < lengthOfData; i += 3) 
	{
        NSUInteger value = 0;
        for ( NSUInteger j = i; j < (i + 3); j++ ) 
		{
            value <<= 8;
            if ( j < lengthOfData ) 
                value |= ( 0xFF & input[j] );
        }
		
        NSUInteger index = (i / 3) * 4;
        output[index + 0] = NSDataBase64CharacterTable[(value >> 18) & 0x3F];
        output[index + 1] = NSDataBase64CharacterTable[(value >> 12) & 0x3F];
        output[index + 2] = ( (i + 1) < lengthOfData ) 
			? NSDataBase64CharacterTable[(value >> 6)  & 0x3F] 
			: '=';
        output[index + 3] = ( (i + 2) < lengthOfData ) 
			? NSDataBase64CharacterTable[(value >> 0)  & 0x3F] 
			: '=';
    }
	
    result = [[NSString alloc] initWithData:base64Data encoding:NSASCIIStringEncoding];
	return result;
}

+ (NSData *)pcl_decodedDataFromBase64String:(NSString *)base64String
{
	NSUInteger lengthOfData = 0;
	NSUInteger const lengthOfSelf = [base64String length];

	NSMutableData * const mutableResult = [NSMutableData data];

	uint8_t const * input = (uint8_t const *)[base64String cStringUsingEncoding:NSASCIIStringEncoding];

	for ( NSUInteger i = 0; i < lengthOfSelf; i += 4 )
	{
		NSUInteger value = 0;
		NSUInteger part = 0;

		part = pcl_unsignedIntegerForBase64Byte( input[ i ] );

		if ( NSUIntegerMax != part )
			value |= part << 18;

		part = pcl_unsignedIntegerForBase64Byte( input[ i + 1 ] );

		if ( NSUIntegerMax != part )
			value |= part << 12;

		part = pcl_unsignedIntegerForBase64Byte( input[ i + 2 ] );

		if ( NSUIntegerMax != part )
		{
			value |= part << 6;
		}
		else
		{
			lengthOfData += 1;
		}

		part = pcl_unsignedIntegerForBase64Byte( input[ i + 3 ] );

		if ( NSUIntegerMax != part )
		{
			value |= part;
			lengthOfData += 3;
		}
		else
		{
			lengthOfData += 2;
		}


		NSUInteger const baseIndex = ( i / 4 ) * 3;

		for ( NSUInteger j = 0; j < 3; j++ )
		{
			NSUInteger const index = baseIndex + j;

			if ( index < lengthOfData )
			{
				uint8_t const byte = ( value >> ( ( 2 - j ) * 8 ) ) & 0xff;
				[mutableResult appendBytes:&byte length:1];
			}
		}
	}

	return [mutableResult copy];
}

@end