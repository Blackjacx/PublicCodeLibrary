//
//  UIColor+PCLExtensions.h
//  PrivateCodeLibrary
//
//  Created by noskill on 23.05.11.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor (PCLExtensions)

- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;
- (CGFloat)alpha;

+ (UIColor*)colorWithRed:(NSUInteger)redValue 
                  green:(NSUInteger)greenValue
                   blue:(NSUInteger)blueValue;

+ (UIColor*)randomColor;

@end
