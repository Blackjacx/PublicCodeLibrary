//
//  UIView+PCLExtensions.h
//  PrivateCodeLibrary
//
//  Created by noskill on 23.05.11.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView (PCLExtensions)

// MARK: 
// MARK: Animations

- (void)jump;

// MARK: 
// MARK: Style

- (void)enableRoundRect;
- (void)enableRoundRectWithRadius:(CGFloat)aRadius;
- (void)enableRoundRectWithRadius:(CGFloat)aRadius borderWidth:(CGFloat)aWidth borderColor:(UIColor*)aColor;

@end

