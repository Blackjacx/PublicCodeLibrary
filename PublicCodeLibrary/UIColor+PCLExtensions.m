//
//  UIColor+PCLExtensions.m
//  PublicCodeLibrary
//
//  Created by noskill on 23.05.11.
//  Copyright (c) 2012 Stefan Herold. All rights reserved.
//

#import <PublicCodeLibrary/UIColor+PCLExtensions.h>


@implementation UIColor (PCLExtensions)

- (CGFloat)pcl_red
{
    const CGFloat * aColor = CGColorGetComponents(self.CGColor);
    return aColor[0];
}

- (CGFloat)pcl_green
{
    const CGFloat * aColor = CGColorGetComponents(self.CGColor);
    return aColor[1];
}

- (CGFloat)pcl_blue
{
    const CGFloat * aColor = CGColorGetComponents(self.CGColor);
    return aColor[2];
}

- (CGFloat)pcl_alpha
{
    return CGColorGetAlpha(self.CGColor);
}

+ (UIColor*)pcl_colorWithRed:(NSUInteger)redValue
					   green:(NSUInteger)greenValue
						blue:(NSUInteger)blueValue
{
	NSUInteger max = 255;
    return [UIColor colorWithRed:MIN(redValue,max)/255.0f
                    green:MIN(greenValue,max)/255.0f 
                     blue:MIN(blueValue, max)/255.0f
                    alpha:1.0f];
}

+ (UIColor*)pcl_randomColor
{
    return [self pcl_colorWithRed:arc4random()%256
							green:arc4random()%256
							 blue:arc4random()%256];
}

@end
