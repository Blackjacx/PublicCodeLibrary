//
//  UIApplication+DTAdditions.h
//  DTLibrary
//
//  Created by Stefan Herold on 11.01.11.
//  Copyright 2011 Deutsche Telekom AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIApplication (DTAdditions) 

+ (NSString*)appVersion;
+ (NSString*)applicationName;

// MARK:
// MARK: Debug

+ (void)performDebugOperationsInBackground;

@end
