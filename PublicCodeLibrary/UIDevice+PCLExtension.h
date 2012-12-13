//
//  UIDevice+PCLExtension.h
//  PrivateCodeLibrary
//
//  Created by Stefan Herold on 6/24/12.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (PCLExtension)

+ (BOOL)isPad;
- (NSString *)machine;

@end
