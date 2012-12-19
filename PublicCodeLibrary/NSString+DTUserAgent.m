//
//  NSString+DTUserAgent.m
//  DTBackend
//
//  Created by Pierre Bongen on 2011-03-15.
//  Copyright 2011 Deutsche Telekom AG. All rights reserved.
//

#import "NSString+DTUserAgent.h"

// DTUserInterface.
#import "UIDevice+DTAdditions.h"
#import "UIApplication+DTAdditions.h"



@implementation NSString ( DTUserAgent )

+ (NSString*)userAgentString 
{
	NSString *result = [NSString stringWithFormat:@"%@/%@/iOS/%@/%@",
        [[UIApplication applicationName] 
        	stringByReplacingOccurrencesOfString:@" " 
            withString:@"_"],
        [[UIApplication appVersion] 
            stringByReplacingOccurrencesOfString:@" " 
            withString:@"_"],
        [[[UIDevice currentDevice] systemVersion]  
            stringByReplacingOccurrencesOfString:@" " 
            withString:@"_"],
        [[[UIDevice currentDevice] machine] 
        stringByReplacingOccurrencesOfString:@" " 
        withString:@"_"]];

	return result;
}

@end
