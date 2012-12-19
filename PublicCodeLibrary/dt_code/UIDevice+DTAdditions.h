//
//  UIDevice+DTAdditions.h
//  DTLibrary
//
//  Created by Stefan Herold on 11.01.11.
//  Copyright 2011 Deutsche Telekom AG. All rights reserved.
//

#import "DTTypeDefs.h"


@interface UIDevice (DTAdditions) 

- (NSString *)machine;
+ (BOOL)isPad;
+ (BOOL)isPhone;
+ (NSUInteger)majorOSVersion;
+ (BOOL)hasDeviceEnoughFreeSpaceToSaveDataOfSize:(DTFileSize)dataSize;
+ (BOOL)isOSEqualOrGreaterIOS6;
@end