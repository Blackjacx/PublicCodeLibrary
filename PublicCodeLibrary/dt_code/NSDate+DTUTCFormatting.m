//
//  NSDate+DTUTCFormatting.m
//  DTLibrary
//
//  Created by Stefan Herold on 25.11.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "NSDate+DTUTCFormatting.h"


@implementation NSDate (DTUTCFormatting)

// yyyy-MM-dd'T'HH:mm:ss.000Z
+ (NSDate *)dateFromUTCString:(NSString *)timeString
{
	NSDate * result = nil;
	NSScanner * const scanner = [[NSScanner alloc] initWithString:timeString];
	
	NSInteger year = 0;
	NSInteger month = 0;
	NSInteger day = 0;
	NSInteger hour = 0;
	NSInteger minute = 0;
	NSInteger second = 0;
	
	@try
	{
		if ( ![scanner scanInteger:&year] )               return result;
		if ( ![scanner scanString:@"-" intoString:NULL] ) return result;
		if ( ![scanner scanInteger:&month] )              return result;
		if ( ![scanner scanString:@"-" intoString:NULL] ) return result;
		if ( ![scanner scanInteger:&day] )                return result;
		if ( ![scanner scanString:@"T" intoString:NULL] ) return result;
		if ( ![scanner scanInteger:&hour] )               return result;
		if ( ![scanner scanString:@":" intoString:NULL] ) return result;
		if ( ![scanner scanInteger:&minute] )             return result;
		if ( ![scanner scanString:@":" intoString:NULL] ) return result;
		if ( ![scanner scanInteger:&second] )             return result;
	}
	@finally 
	{
		[scanner release];
	}
	
	NSDateComponents * const dateComponents = [NSDateComponents new];
	[dateComponents setYear:year];
	[dateComponents setMonth:month];
	[dateComponents setDay:day];
	[dateComponents setHour:hour];
	[dateComponents setMinute:minute];
	[dateComponents setSecond:second];
	
	// Create new calendar and get components from it.
	NSCalendar *calendar = [[NSCalendar alloc] 
							initWithCalendarIdentifier:NSGregorianCalendar];
	//[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	result = [calendar dateFromComponents:dateComponents];
	[calendar release];	
	[dateComponents release];
	
	return result;
}

@end
