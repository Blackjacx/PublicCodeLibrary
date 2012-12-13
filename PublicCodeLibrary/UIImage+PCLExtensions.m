//
//  UIImage+PCLExtensions.m
//  PrivateCodeLibrary
//
//  Created by *** *** on 9/12/11.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#import "UIImage+PCLExtensions.h"

@implementation UIImage (PCLExtensions)

- (UIImage*)randomImageOfSize:(CGSize)aSize
{
	CGFloat nX = arc4random() % (NSUInteger)(self.size.width - aSize.width);
	CGFloat nY = arc4random() % (NSUInteger)(self.size.height - aSize.height);
	CGRect finalCropRect = CGRectMake(nX, nY, aSize.width, aSize.height);
	
	CGImageRef resultingImageRef = CGImageCreateWithImageInRect(self.CGImage, 
			finalCropRect);
	UIImage * resultingImage = [UIImage imageWithCGImage:resultingImageRef];
	CGImageRelease(resultingImageRef);
	return resultingImage;
}

@end
