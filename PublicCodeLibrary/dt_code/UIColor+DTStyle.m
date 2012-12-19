//
//  DTStyleCLWColorset.m
//  MedienCenter
//
//  Created by m.fischer on 15.01.09.
//  Copyright 2009 Deutsche Telekom AG. All rights reserved.
//

#import "UIColor+DTStyle.h"

@implementation UIColor ( DTStyle )

// MARK: 
// MARK: DEPRECATED

+ (UIColor*) sg2011DefaultNavBarTintColor {
	return [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
}

// MARK: 
// MARK: Useful Color Definitions

+ (UIColor *) colorWithRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue
{
	return [UIColor colorWithRed:red / 255.0f 
						green:green / 255.0f 
						blue:blue / 255.0f 
						alpha:1.0f];
}

+ (UIColor *) randomColor
{
	CGFloat r = arc4random() % 256;
	CGFloat g = arc4random() % 256;
	CGFloat b = arc4random() % 256;
	return [UIColor colorWithRed:r green:g blue:b];
}

// MARK: 
// MARK: Getting Color Components

- (CGFloat)red {
    const CGFloat * aColor = CGColorGetComponents(self.CGColor);
    return aColor[0];
}

- (CGFloat)green {
    const CGFloat * aColor = CGColorGetComponents(self.CGColor);
    return aColor[1];
}

- (CGFloat)blue {
    const CGFloat * aColor = CGColorGetComponents(self.CGColor);
    return aColor[2];
}

- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}

// MARK: 
// MARK: Color Definitions from Styleguide 2011

+ (UIColor*) sg2011DefaultBackgroundColor {
	return [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
}
+ (UIColor*) sg2011DefaultTextColor {
	return [UIColor colorWithRed:75.0f/255.0f green:75.0f/255.0f blue:75.0f/255.0f alpha:1.0f];
}
+ (UIColor*) sg2011NavbarBottomLineColor {
	return [UIColor colorWithRed:208.0f/255.0f green:208.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
}
+ (UIColor*) sg2011GradientBackgroundViewBorderColor {
	return [UIColor colorWithRed:208.0f/255.0f green:208.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
}
+ (UIColor*) sg2011TextInputTextColor {
	return [UIColor colorWithRed:140.0f/255.0f green:140.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
}
+ (UIColor*) dt_gray_38 {
	return [UIColor colorWithWhite:38.0/255.0 alpha:1.0];
}
+ (UIColor*) dt_gray_54 {
	return [UIColor colorWithWhite:54.0/255.0 alpha:1.0];
}
+ (UIColor*) dt_gray_59 {
	return [UIColor colorWithWhite:59/255.0 alpha:1.0];
}

+ (UIColor*) dt_gray_75 {
	return [UIColor colorWithWhite:75.0/255.0 alpha:1.0];
}

+ (UIColor*) dt_gray_108 {
	return [UIColor colorWithWhite:108.0/255.0 alpha:1.0];
}
+ (UIColor*) dt_gray_124 {
	return [UIColor colorWithWhite:124.0/255.0 alpha:1.0];
}
+ (UIColor*) dt_gray_140 {
	return [UIColor colorWithWhite:140.0/255.0 alpha:1.0];
}
+ (UIColor*) dt_gray_164 {
	return [UIColor colorWithWhite:164.0/255.0 alpha:1.0];
}
+ (UIColor*) dt_gray_208 {
	return [UIColor colorWithWhite:208.0/255.0 alpha:1.0];
}
+ (UIColor*) dt_gray_217 {
	return [UIColor colorWithWhite:217.0/255.0 alpha:1.0];
}
+ (UIColor*) dt_gray_220 {
	return [UIColor colorWithWhite:220.0/255.0 alpha:1.0];
}
+ (UIColor*) dt_gray_237 {
	return [UIColor colorWithWhite:237.0/255.0 alpha:1.0];
}
+ (UIColor*) dt_magenta {
	return [UIColor colorWithRed:(float)226.0/255.0 green:(float)0.0/255.0 blue:(float)116.0/255.0 alpha:1.0];
}

// MARK: 
// MARK: Button Text Colors for Differrent Stati

// Light Button Colors

+ (UIColor*) sg2011ButtonDefaultTextColor {
	return [UIColor colorWithRed:75.0/255.0 green:75.0/255.0 blue:75.0/255.0 alpha:1.0];
}
+ (UIColor*) sg2011ButtonHighlightedTextColor {
		return [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0];
}
+ (UIColor*) sg2011ButtonDisabledTextColor {
	return [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1.0];
}

// Dark Button Colors

+ (UIColor*) sg2011ButtonDarkDefaultTextColor {
	return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
}
+ (UIColor*) sg2011ButtonDarkHighlightedTextColor {
		return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
}
+ (UIColor*) sg2011ButtonDarkDisabledTextColor {
	return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
}

// MARK: 
// MARK: Button Text Shadow Colors for Differrent Stati

// Light Button Colors

+ (UIColor*) sg2011ButtonDefaultTextShadowColor {
	return [UIColor whiteColor];
}
+ (UIColor*) sg2011ButtonHighlightedTextShadowColor {
	return [UIColor clearColor];
}
+ (UIColor*) sg2011ButtonDisabledTextShadowColor {
	return [UIColor clearColor];
}

// Dark Button Colors

		// No shadow color here...

// MARK: 
// MARK: Button Border Colors for Differrent Stati

+ (UIColor*) sg2011ButtonDefaultBorderColor {
	return [UIColor grayColor];
}
+ (UIColor*) sg2011ButtonHighlightedBorderColor {
	return [UIColor grayColor];
}
+ (UIColor*) sg2011ButtonDisabledBorderColor {
	return [UIColor grayColor];
}

// MARK: 
// MARK: Bar Color Gradient

+ (UIColor*) sg2011BarGradientTop {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}
+ (UIColor*) sg2011BarGradientCenter {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}
+ (UIColor*) sg2011BarGradientBottom {
	return [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1];
}

// MARK: 
// MARK: Sushi Bar Fill Color

+ (UIColor*) sg2011SushiBarFillColor {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

// MARK: 
// MARK: Photo Detail Viewer Colors

+ (UIColor*) sg2011PhotoDetailViewerBackgroundColor {
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}

// MARK: 
// MARK: Progress Bar Gradient Definitions

+ (UIColor *) sg2011ProgressbarGradientGrayTop {
	return [UIColor colorWithRed:(float)130.0/255.0 green:(float)130.0/255.0 blue:(float)130.0/255.0 alpha:1.0];
}

+ (UIColor *) sg2011ProgressbarGradientGrayBottom {
	return [UIColor colorWithRed:(float)164.0/255.0 green:(float)164.0/255.0 blue:(float)164.0/255.0 alpha:1.0];
}

+ (UIColor *) sg2011ProgressbarGradientMagentaTop {
	return [UIColor colorWithRed:(float)250.0/255.0 green:(float)0.0/255.0 blue:(float)129.0/255.0 alpha:1.0];
}

+ (UIColor *) sg2011ProgressbarGradientMagentaCenter {
	return [UIColor colorWithRed:(float)226.0/255.0 green:(float)0.0/255.0 blue:(float)116.0/255.0 alpha:1.0];
}

+ (UIColor *) sg2011ProgressbarGradientMagentaBottom {
	return [UIColor colorWithRed:(float)178.0/255.0 green:(float)0.0/255.0 blue:(float)92.0/255.0 alpha:1.0];
}

// MARK: 
// MARK: Color Definitions for Table Cells

+ (UIColor *) sg2011SettingsTableCellBottomLineColor {
	return [UIColor colorWithRed:(float)220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
}
+ (UIColor *) sg2011SettingsTableCellPressedColor {
	return [UIColor colorWithRed:(float)219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
}

@end
