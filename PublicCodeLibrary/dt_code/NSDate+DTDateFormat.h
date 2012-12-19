//
//  NSDate+DTDateFormat.h
//  DTLibrary
//
//  Created by Said El Mallouki on 14.12.10.
//  Copyright 2010 mallouki.de. All rights reserved.
//
#import <Foundation/Foundation.h>



typedef enum _DTDateFormat {
	DTDateFormatDefaultShort = NSDateFormatterShortStyle,
	DTDateFormatDefaultMedium = NSDateFormatterMediumStyle,
	DTDateFormatDefaultLong = NSDateFormatterLongStyle,
	DTDateFormatDefaultFull = NSDateFormatterFullStyle
} DTDateFormat;



@interface NSDate (DTDateFormat) 

- (NSString *)stringWithDefaultFormat:(DTDateFormat)aDateFormat;
- (NSString *)stringWithCustomFormatString:(NSString *)formatString;
- (NSString *)stringWithCustomFormatFromLocalizationWithKey:(NSString *)formatKey __attribute__((deprecated("Use stringWithCustomFormatFromLocalizationWithKey:fromBundle: instead!")));
- (NSString *)stringWithCustomFormatFromLocalizationWithKey:(NSString *)formatKey fromBundle:(NSBundle*)bundle;

@end
