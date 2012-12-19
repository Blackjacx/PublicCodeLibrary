//
//  NSString+DTFormatting.m
//  DTLibrary
//
//  Created by Pierre Bongen on 24.11.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "NSString+DTFormatting.h"

// DTLibrary - Utilities.
#import "DTDebugging.h"



@implementation NSString ( DTFormatting )

// MARK: 
// MARK: Formatting Strings

+ (NSString *)stringWithFormat:(NSString *)format argumentsAsArray:(NSArray *)arguments
{
	NSString *result = nil;
	
	//
	// Check parameters.
	//

	if ( !format )
	{
		return result;
	}
	
	//
	// Perform formatting.
	//
	
	if ( [format length] )
	{
		NSUInteger const numberOfArguments = [arguments count];
		
		if ( numberOfArguments )
		{
			void * vaList = malloc( sizeof(NSString *) * numberOfArguments );
			
			if ( vaList )
			{
				@try 
				{
					[arguments getObjects:(id *)vaList];
					
					result = [[[NSString alloc] 
						initWithFormat:format 
						arguments:vaList] autorelease];
				}
				@finally 
				{
					free( vaList );
				}
			}
		}
		else
		{
			result = format;
		}
	} 
	else
	{
		result = @"";
	} 
	
	return result;
}

+ (NSString*)stringFromTimeInSeconds:(NSTimeInterval)timeInSeconds includeHoursInMinutesIfUnderAnHour:(BOOL)includeHoursInMinutes
{
	NSString * result = nil;
	
	if( timeInSeconds > 0 ) {
		NSInteger timeIntervalAsInteger = (NSInteger)timeInSeconds;
		NSInteger hours 				= timeIntervalAsInteger / 3600;
		NSInteger minutes 				= (timeIntervalAsInteger - (hours*3600)) / 60;
		NSInteger minutesWithHours 		= timeIntervalAsInteger / 60;
		NSInteger seconds 				= timeIntervalAsInteger % 60;
		
		result = ( includeHoursInMinutes && ( minutesWithHours < 60 ) )
		? [NSString stringWithFormat:@"%02d:%02d", minutesWithHours, seconds]
		: [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
	}
	else {
		result = includeHoursInMinutes ? @"00:00" : @"00:00:00";
	}
	
	return result;
}

@end
