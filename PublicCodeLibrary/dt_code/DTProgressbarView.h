//
//  DTProgressbarView.h
//  Assistent
//
//  Created by Stefan Herold on 14.06.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DTProgressbarView : UIView 
@property(nonatomic, assign) CGFloat progress;

- (UIImage*)foregroundStretchableImage;
- (void)setForegroundStretchableImage:(UIImage *)anImage;
- (UIImage*)backgroundStretchableImage;
- (void)setBackgroundStretchableImage:(UIImage *)anImage;
- (CGFloat)trackHeight;

@end
