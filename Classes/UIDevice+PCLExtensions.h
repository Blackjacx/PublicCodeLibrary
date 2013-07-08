//
//  UIDevice+PCLExtension.h
//  PublicCodeLibrary
//
//  Created by Stefan Herold on 6/24/12.
//  Copyright (c) 2012 Stefan Herold. All rights reserved.
//

@interface UIDevice (PCLExtensions)

+ (BOOL)pcl_isPad;
+ (BOOL)pcl_isPhone;
+ (BOOL)pcl_isIOS7;
+ (NSUInteger)pcl_majorOSVersion;
- (NSString *)pcl_machine;

@end
