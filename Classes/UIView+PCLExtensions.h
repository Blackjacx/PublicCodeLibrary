//
//  UIView+PCLExtensions.h
//  PublicCodeLibrary
//
//  Created by noskill on 23.05.11.
//  Copyright (c) 2012 Stefan Herold. All rights reserved.
//

@interface UIView (PCLExtensions)

// MARK: 
// MARK: Animations

- (void)pcl_jump;

// MARK: 
// MARK: Style

- (void)pcl_enableRoundRect;
- (void)pcl_enableRoundRectWithRadius:(CGFloat)aRadius;
- (void)pcl_enableRoundRectWithRadius:(CGFloat)aRadius borderWidth:(CGFloat)aWidth borderColor:(UIColor*)aColor;

@end

