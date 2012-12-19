//
//  DTStyleCLWColorset.h
//  MedienCenter
//
//  Created by m.fischer on 15.01.09.
//  Copyright 2009 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIColor ( DTStyle )

// MARK: 
// MARK: Useful Color Definitions

+ (UIColor *) colorWithRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue;
+ (UIColor *) randomColor;

// MARK: 
// MARK: Getting Color Components

- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;
- (CGFloat)alpha;

// MARK: 
// MARK: Color Definitions from Styleguide 2011

+ (UIColor*) sg2011DefaultBackgroundColor;
+ (UIColor*) sg2011DefaultTextColor;
+ (UIColor*) sg2011NavbarBottomLineColor;
+ (UIColor*) sg2011GradientBackgroundViewBorderColor;
+ (UIColor*) sg2011TextInputTextColor;
+ (UIColor*) sg2011DefaultNavBarTintColor;

+ (UIColor*) dt_gray_38;
+ (UIColor*) dt_gray_54;
+ (UIColor*) dt_gray_59;
+ (UIColor*) dt_gray_75;
+ (UIColor*) dt_gray_108;
+ (UIColor*) dt_gray_217;
+ (UIColor*) dt_gray_124;
+ (UIColor*) dt_gray_140;
+ (UIColor*) dt_gray_164;
+ (UIColor*) dt_gray_208;
+ (UIColor*) dt_gray_220;
+ (UIColor*) dt_gray_237;

+ (UIColor *) dt_magenta;

// MARK: 
// MARK: Button Text Colors for Differrent Stati

// Light Button Text Colors

+ (UIColor*) sg2011ButtonDefaultTextColor;
+ (UIColor*) sg2011ButtonHighlightedTextColor;
+ (UIColor*) sg2011ButtonDisabledTextColor;

// Dark Button Text Colors

+ (UIColor*) sg2011ButtonDarkDefaultTextColor;
+ (UIColor*) sg2011ButtonDarkHighlightedTextColor;
+ (UIColor*) sg2011ButtonDarkDisabledTextColor;

// MARK: 
// MARK: Button Text Shadow Colors for Differrent Stati

+ (UIColor*) sg2011ButtonDefaultTextShadowColor;
+ (UIColor*) sg2011ButtonHighlightedTextShadowColor;
+ (UIColor*) sg2011ButtonDisabledTextShadowColor;

// MARK: 
// MARK: Button Border Colors for Differrent Stati

+ (UIColor*) sg2011ButtonDefaultBorderColor;
+ (UIColor*) sg2011ButtonHighlightedBorderColor;
+ (UIColor*) sg2011ButtonDisabledBorderColor;

// MARK: 
// MARK: Bar Color Gradient

+ (UIColor*) sg2011BarGradientTop;
+ (UIColor*) sg2011BarGradientCenter;
+ (UIColor*) sg2011BarGradientBottom;

// MARK: 
// MARK: Sushi Bar Fill Color

+ (UIColor*) sg2011SushiBarFillColor;

// MARK: 
// MARK: Photo Detail Viewer Colors

+ (UIColor*) sg2011PhotoDetailViewerBackgroundColor;

// MARK: 
// MARK: Color Definitions for Table Cells

+ (UIColor *) sg2011SettingsTableCellBottomLineColor;
+ (UIColor *) sg2011SettingsTableCellPressedColor;

@end

