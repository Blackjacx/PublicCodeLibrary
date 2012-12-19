//
//  UIApplication+DTAdditions.m
//  DTLibrary
//
//  Created by Stefan Herold on 11.01.11.
//  Copyright 2011 Deutsche Telekom AG. All rights reserved.
//

#import "UIApplication+DTAdditions.h"
#import "DTDebugging.h"

@implementation UIApplication (DTAdditions)

+ (NSString*)appVersion {
	return [[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString*)applicationName {
	return [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]];
}

// MARK:
// MARK: Debug

+ (void)performDebugOperationsInBackground {

	#if defined( DEBUG ) && DEBUG == 1

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

		// Check Bundle For Non PNG Files

		NSArray * jpgList = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"jpg" subdirectory:nil];
		NSArray * bmpList = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"bmp" subdirectory:nil];

		DT_ASSERT( !jpgList || [jpgList count] == 0, @"There are jpeg images in main bundle - fix this! (\n%@\n)", jpgList);
		DT_ASSERT( !bmpList || [bmpList count] == 0, @"There are bmp images in main bundle - fix this! (\n%@\n)", bmpList);
	});

	#endif
}

@end
