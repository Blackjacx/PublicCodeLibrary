//
//  NSData+DTBase64.h
//  DTFoundation
//
//  Created by Pierre Bongen on 2010-02-02.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>



/*!
    \brief Adds base64 support to NSData.
*/

NSUInteger unsignedIntegerForBase64Byte( uint8_t const byte );

@interface NSData ( DTBase64 )

- (NSString *)encodeAsBase64;
+ (NSData *)decodeFromBase64:(NSString *)base64String;

@end