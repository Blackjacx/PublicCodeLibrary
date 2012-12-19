//
//  sytleAppBackground.m
//  MedienCenter
//
//  Created by m.fischer on 02.02.09.
//  Copyright 2009 Deutsche Telekom AG. All rights reserved.
//

#import "DTViewBackground.h"

// DTLibrary - UIKit Additions.
#import "UIColor+DTStyle.h"



@implementation DTViewBackground

// MARK: 

- (void)drawRect:(CGRect)rect {
	
    // Drawing code
	CGContextRef graphContext = UIGraphicsGetCurrentContext();  
	
	//CGContextClearRect(graphContext, rect);
	// fillarea for the gradient
	CGRect contentRect = rect;
	
	
	// CLW background gradient style
	CGGradientRef gradient;
	CGFloat locations[2] = { 0.0, 1.0 };

	CGFloat components[8] = { (float)75/255, (float)75/255, (float)75/255, 1.0,  // Start color
	(float)34/255, (float)34/255, (float)34/255, 1.0 }; // End color
	
	// fillarea for the gradient
	CGContextClipToRect(graphContext, contentRect);
	CGColorSpaceRef deviceRGBColorSpace = CGColorSpaceCreateDeviceRGB();
	gradient = CGGradientCreateWithColorComponents (
		deviceRGBColorSpace, 
		components,
		locations, 
		2 );
	
	
	// linear gradient from top to bottom
	CGPoint startPoint = CGPointMake(0.0,0.0);
	CGPoint endPoint = CGPointMake(0.0,contentRect.size.height-contentRect.origin.y);
	CGContextDrawLinearGradient (graphContext, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradient);
	CGColorSpaceRelease( deviceRGBColorSpace );
}

@end
