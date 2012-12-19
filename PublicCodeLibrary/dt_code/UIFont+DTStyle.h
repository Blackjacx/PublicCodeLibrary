//
//  styleCLWMetrics.h
//  Conference
//
//  Created by Stefan Herold on 08.10.09.
//  Copyright 2009 Deutsche Telekom AG. All rights reserved.
//
// Class stores metric values defined in Mobile touch style guide
// Version 1.2 - Draft

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define DTFontTeleGroteskOffsetCorrectionVertical 4

@interface UIFont ( DTStyle ) 

// MARK: 
// MARK: New Font Definitions (Style Guide 2011)

+ (UIFont*) telegroteskFatOfSize:(CGFloat)size;
+ (UIFont*) telegroteskNormalOfSize:(CGFloat)size;
+ (UIFont*) telegroteskLightOfSize:(CGFloat)size;
+ (UIFont*) arialNormalOfSize:(CGFloat)size;

// MARK: 
// MARK: New alpha-value based font sized

+ (CGFloat) bigFontSize;
+ (CGFloat) medium1FontSize;
+ (CGFloat) medium2FontSize;
+ (CGFloat) smallFontSize;



// MARK: 
// MARK: Font default (not pressed) sizes

+ (CGFloat) list60TitleDefaultFontSize;
+ (CGFloat) list60TitlePressedFontSize;
+ (CGFloat) list60SubTitleDefaultFontSize;
+ (CGFloat) list60SubTitlePressedFontSize;
+ (CGFloat) list60IndicationDefaultFontSize;
+ (CGFloat) list60IndicationPressedFontSize;

+ (CGFloat) list40TitleDefaultFontSize;
+ (CGFloat) list40TitlePressedFontSize;
+ (CGFloat) list40SubTitleDefaultFontSize;
+ (CGFloat) list40SubTitlePressedFontSize;
+ (CGFloat) list40IndicationDefaultFontSize;
+ (CGFloat) list40IndicationPressedFontSize;

+ (CGFloat) homeScreenItemTitleDefaultFontSize;

+ (CGFloat) textAreaDefaultFontSize;

+ (CGFloat) simpleClusterTitleDefaultFontSize;
+ (CGFloat) simpleClusterTitlePressedFontSize;
+ (CGFloat) simpleClusterIndicationDefaultFontSize;
+ (CGFloat) simpleClusterIndicationPressedFontSize;

+ (CGFloat) expandableClusterTitleDefaultFontSize;
+ (CGFloat) expandableClusterTitlePressedFontSize;
+ (CGFloat) expandableClusterIndicationDefaultFontSize;
+ (CGFloat) expandableClusterIndicationPressedFontSize;

+ (CGFloat) indicationalAreaTitleDefaultFontSize;
+ (CGFloat) indicationalAreaTitlePressedFontSize;
+ (CGFloat) indicationalAreaSubTitleDefaultFontSize;
+ (CGFloat) indicationalAreaSubTitlePressedFontSize;

+ (CGFloat) buttonLabelDefaultFontSize;
+ (CGFloat) buttonLabelPressedFontSize;

+ (CGFloat) checkBoxLabelDefaultFontSize;
+ (CGFloat) checkBoxLabelPressedFontSize;

+ (CGFloat) inputFieldTextDefaultFontSize;
+ (CGFloat) inputFieldTextPressedFontSize;
+ (CGFloat) inputFieldLableAboveDefaultFontSize;
+ (CGFloat) inputFieldLableAbovePressedFontSize;
+ (CGFloat) inputFieldLabelBehindDefaultFontSize;
+ (CGFloat) inputFieldLabelBehindPressedFontSize;

+ (CGFloat) progressBarLabelDefaultFontSize;
+ (CGFloat) progressBarLabelPressedFontSize;

@end
