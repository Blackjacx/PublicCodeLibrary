//
//  styleCLWMetrics.m
//  Conference
//
//  Created by Stefan Herold on 08.10.09.
//  Copyright 2009 Deutsche Telekom AG. All rights reserved.
//

#import "UIFont+DTStyle.h"
//#import "DTMetrics.h"


// DTStyle - Style Definitions.
#import "UIView+DTMetrics.h"



#define DT_PDE_ALPHA_VALUE ([UIView alphaValue])



@implementation UIFont ( DTStyle )

// MARK: 
// MARK: New Font Definitions (Style Guide 2011)

+ (UIFont*) telegroteskFatOfSize:(CGFloat)size {
	return [UIFont fontWithName:@"Tele-GroteskFet" size:size];
}

+ (UIFont*) telegroteskNormalOfSize:(CGFloat)size {
	return [UIFont fontWithName:@"Tele-GroteskNor" size:size];
}

+ (UIFont*) telegroteskLightOfSize:(CGFloat)size {
	return [UIFont fontWithName:@"Tele-GroteskHal" size:size];
}

+ (UIFont*) arialNormalOfSize:(CGFloat)size {
	return [UIFont fontWithName:@"Arial" size:size];
}

#pragma mark -
#pragma mark New alpha-value based font sized

+ (CGFloat) bigFontSize															{return (int) (0.28 * DT_PDE_ALPHA_VALUE);}
+ (CGFloat) medium1FontSize														{return (int) (0.25 * DT_PDE_ALPHA_VALUE);}
+ (CGFloat) medium2FontSize														{return (int) (0.22 * DT_PDE_ALPHA_VALUE);}
+ (CGFloat) smallFontSize														{return (int) (0.20 * DT_PDE_ALPHA_VALUE);}



#pragma mark -
#pragma mark Default and pressed font sizes 

+ (CGFloat) list60TitleDefaultFontSize {return (CGFloat)16.0;}
+ (CGFloat) list60TitlePressedFontSize {return (CGFloat)16.0;}
+ (CGFloat) list60SubTitleDefaultFontSize {return (CGFloat)12.0;}
+ (CGFloat) list60SubTitlePressedFontSize {return (CGFloat)12.0;}
+ (CGFloat) list60IndicationDefaultFontSize {return (CGFloat)16.0;}
+ (CGFloat) list60IndicationPressedFontSize {return (CGFloat)16.0;}

+ (CGFloat) list40TitleDefaultFontSize {return (CGFloat)12.0;}
+ (CGFloat) list40TitlePressedFontSize {return (CGFloat)12.0;}
+ (CGFloat) list40SubTitleDefaultFontSize {return (CGFloat)12.0;}
+ (CGFloat) list40SubTitlePressedFontSize {return (CGFloat)12.0;}
+ (CGFloat) list40IndicationDefaultFontSize {return (CGFloat)12.0;}
+ (CGFloat) list40IndicationPressedFontSize {return (CGFloat)12.0;}

+ (CGFloat) homeScreenItemTitleDefaultFontSize									{return (int) (0.2 * DT_PDE_ALPHA_VALUE);}

+ (CGFloat) textAreaDefaultFontSize {return [self medium1FontSize];}

+ (CGFloat) simpleClusterTitleDefaultFontSize {return (CGFloat)16.0;}
+ (CGFloat) simpleClusterTitlePressedFontSize {return (CGFloat)16.0;}
+ (CGFloat) simpleClusterIndicationDefaultFontSize {return (CGFloat)16.0;}
+ (CGFloat) simpleClusterIndicationPressedFontSize {return (CGFloat)16.0;}

+ (CGFloat) expandableClusterTitleDefaultFontSize {return (CGFloat)16.0;}
+ (CGFloat) expandableClusterTitlePressedFontSize {return (CGFloat)16.0;}
+ (CGFloat) expandableClusterIndicationDefaultFontSize {return (CGFloat)16.0;}
+ (CGFloat) expandableClusterIndicationPressedFontSize {return (CGFloat)16.0;}

+ (CGFloat) indicationalAreaTitleDefaultFontSize {return (CGFloat)16.0;}
+ (CGFloat) indicationalAreaTitlePressedFontSize {return (CGFloat)16.0;}
+ (CGFloat) indicationalAreaSubTitleDefaultFontSize {return (CGFloat)12.0;}
+ (CGFloat) indicationalAreaSubTitlePressedFontSize {return (CGFloat)12.0;}

+ (CGFloat) buttonLabelDefaultFontSize {return (CGFloat)18.0;}
+ (CGFloat) buttonLabelPressedFontSize {return (CGFloat)18.0;}

+ (CGFloat) checkBoxLabelDefaultFontSize {return (CGFloat)16.0;}
+ (CGFloat) checkBoxLabelPressedFontSize {return (CGFloat)16.0;}

+ (CGFloat) inputFieldTextDefaultFontSize {return (CGFloat)16.0;}
+ (CGFloat) inputFieldTextPressedFontSize {return (CGFloat)16.0;}
+ (CGFloat) inputFieldLableAboveDefaultFontSize {return (CGFloat)12.0;}
+ (CGFloat) inputFieldLableAbovePressedFontSize {return (CGFloat)12.0;}
+ (CGFloat) inputFieldLabelBehindDefaultFontSize {return (CGFloat)16.0;}
+ (CGFloat) inputFieldLabelBehindPressedFontSize {return (CGFloat)16.0;}

+ (CGFloat) progressBarLabelDefaultFontSize {return (CGFloat)12.0;}
+ (CGFloat) progressBarLabelPressedFontSize {return (CGFloat)12.0;}

@end
