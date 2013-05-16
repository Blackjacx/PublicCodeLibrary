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
- (NSString *)pcl_machine;

@end
