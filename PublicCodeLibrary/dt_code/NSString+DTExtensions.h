//
//  NSString+DTExtensions.h
//  DTFoundation
//
//  Created by Stefan Herold on 12.05.11.
//  Copyright 2011 Deutsche Telekom AG. All rights reserved.
//

#import "DTTypeDefs.h"

@interface NSString (DTExtensions)

- ( BOOL ) isEmpty;
- ( BOOL ) isNotEmpty;
- ( NSString * ) trim;
- ( BOOL ) isNotEqualToString:(NSString *)aString;
- ( BOOL ) isLowerToString:(NSString *)aString;
- ( BOOL ) isLowerEqualToString:(NSString *)aString;
- ( NSString * ) truncatedToWidth:(CGFloat)aWidth usingFont:(UIFont *)aFont;

// MARK: UID Generation

+ (NSString*)uuid;

// MARK: URL Encoding

- (NSString *)URLEncode;
- (NSString *)URLDecode;

// MARK: SHA512 Hash Generation 

- (NSString *)sha512HashFromUTF8String;

// MARK: Byte Conversion

+ (NSString *)stringByConvertingBytesToHumanReadableFormat:(DTFileSize)byteCount;

@end
