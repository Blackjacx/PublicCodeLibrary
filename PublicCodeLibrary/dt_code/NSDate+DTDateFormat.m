//
//  NSDate+DTDateFormat.m
//  DTLibrary
//
//  Created by Said El Mallouki on 14.12.10.
//  Copyright 2010 mallouki.de. All rights reserved.
//

#import "NSDate+DTDateFormat.h"


@implementation NSDate(DTDateFormat)

static NSDateFormatter * DATEFORMATTER;


-(NSDateFormatter *)dateFormatter{
	if (!DATEFORMATTER) 
	{
		DATEFORMATTER =  [[NSDateFormatter alloc] init];
	}
	return DATEFORMATTER;
}


-(NSString *) stringWithDefaultFormat:(DTDateFormat)aDateFormat
{
	[[self dateFormatter] setDateStyle:aDateFormat];
	return [[self dateFormatter] stringFromDate:self];
}

-(NSString *) stringWithCustomFormatString:(NSString *)formatString
{
	// Get format String for key from localization string table.
	[[self dateFormatter] setDateFormat:formatString];
	return [[self dateFormatter] stringFromDate:self];	
}


-(NSString *) stringWithCustomFormatFromLocalizationWithKey:(NSString *)formatKey
{
	// Get format String for key from localization string table.
	[[self dateFormatter] setDateFormat:NSLocalizedString(formatKey, @"")];
	return [[self dateFormatter] stringFromDate:self];	
}

-(NSString *) stringWithCustomFormatFromLocalizationWithKey:(NSString *)formatKey fromBundle:(NSBundle*)bundle
{
	// Get format String for key from localization string table.
	[[self dateFormatter] setDateFormat:NSLocalizedStringFromTableInBundle(formatKey, nil, bundle, @"")];
	return [[self dateFormatter] stringFromDate:self];	
}

@end
