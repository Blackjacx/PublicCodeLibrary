//
//  UIColor+PCLExtensions.m
//  PrivateCodeLibrary
//
//  Created by noskill on 23.05.11.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#import "UIColor+PCLExtensions.h"


@implementation UIColor (PCLExtensions)

- (CGFloat)red
{
    const CGFloat * aColor = CGColorGetComponents(self.CGColor);
    return aColor[0];
}

- (CGFloat)green
{
    const CGFloat * aColor = CGColorGetComponents(self.CGColor);
    return aColor[1];
}

- (CGFloat)blue
{
    const CGFloat * aColor = CGColorGetComponents(self.CGColor);
    return aColor[2];
}

- (CGFloat)alpha
{
    return CGColorGetAlpha(self.CGColor);
}

+ (UIColor*)colorWithRed:(NSUInteger)redValue 
                   green:(NSUInteger)greenValue
                    blue:(NSUInteger)blueValue
{
	NSUInteger max = 255;
    return [UIColor colorWithRed:MIN(redValue,max)/255.0f
                    green:MIN(greenValue,max)/255.0f 
                     blue:MIN(blueValue, max)/255.0f
                    alpha:1.0f];
}

+ (UIColor*)randomColor
{
    return [self colorWithRed:arc4random()%256
                        green:arc4random()%256
                         blue:arc4random()%256];
}

@end
