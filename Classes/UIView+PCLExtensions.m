//
//  UIView+PCLExtensions.m
//  PublicCodeLibrary
//
//  Created by noskill on 23.05.11.
//  Copyright (c) 2012 Stefan Herold. All rights reserved.
//

#import "UIView+PCLExtensions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (PCLExtensions)

// MARK: 
// MARK: Animations

- (void)pcl_jump
{
    CGAffineTransform upJump = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -25);
    CGAffineTransform downJump = CGAffineTransformTranslate(CGAffineTransformIdentity, 0,  25);
    
    // -- Start with upJump
    self.transform = upJump;
    
    [UIView animateWithDuration:0.2f 
                          delay:0.0f 
                        options:UIViewAnimationOptionAllowUserInteraction
                                | UIViewAnimationOptionAutoreverse
                                | UIViewAnimationOptionCurveEaseIn                    
                     animations:^
                     {
                         [UIView setAnimationRepeatCount:5];
                         self.transform = downJump;
                     }
                     completion:^(BOOL finished)
                     {
                         self.transform = CGAffineTransformIdentity;                         
                     }];
}

// MARK: 
// MARK: Style

- (void)pcl_enableRoundRect
{
    [self pcl_enableRoundRectWithRadius:5.0f];
}

- (void)pcl_enableRoundRectWithRadius:(CGFloat)aRadius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = aRadius;
}

- (void)pcl_enableRoundRectWithRadius:(CGFloat)aRadius borderWidth:(CGFloat)aWidth borderColor:(UIColor*)aColor
{
    [self pcl_enableRoundRectWithRadius:aRadius];
    self.layer.borderWidth = aWidth;
    self.layer.borderColor = aColor.CGColor;
}

@end
