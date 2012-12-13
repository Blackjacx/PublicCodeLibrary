//
//  UIApplication+PCLExtension.m
//  PrivateCodeLibrary
//
//  Created by Stefan Herold on 6/24/12.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#import "UIApplication+PCLExtension.h"

@implementation UIApplication (PCLExtension)

+ (NSString*)appVersion {
	NSCharacterSet * trimmingSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	id bundleVerObj = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString * bundleVer = [NSString stringWithFormat:@"%@", bundleVerObj];
	NSString * bundleVerTrimmed = [bundleVer stringByTrimmingCharactersInSet:trimmingSet];
	return bundleVerTrimmed;
}

+ (NSString*)applicationName {
	id appNameObj = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	NSString * appName = [NSString stringWithFormat:@"%@", appNameObj];
	return appName;
}

@end
