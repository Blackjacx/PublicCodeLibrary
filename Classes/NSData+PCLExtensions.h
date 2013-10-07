/*!
 @file		NSData+PCLExtensions.h
 @brief		Extensions for the class NSData
 @author	Stefan Herold
 @date		2012-12-16
 @copyright	Copyright (c) 2012 Stefan Herold. All rights reserved.
 */

@interface NSData (PCLExtensions)

// MARK: Encoding and Decoding Base64
/*!
 @name Encoding and Decoding Base64
 @{
 */
/*!
 The NSData method from which this method is called needs to be a string with 
 UTF8 encoding.
 */
- (NSString *)pcl_encodedBase64String;
+ (NSData *)pcl_decodedDataFromBase64String:(NSString *)base64String;
//!@}

@end