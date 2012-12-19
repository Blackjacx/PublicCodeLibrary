//
//  NSString+DTFormatting.h
//  DTLibrary
//
//  Created by Pierre Bongen on 24.11.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString ( DTFormatting )

+ (NSString *)stringWithFormat:(NSString *)format argumentsAsArray:(NSArray *)arguments;

+ (NSString*)stringFromTimeInSeconds:(NSTimeInterval)timeInSeconds includeHoursInMinutesIfUnderAnHour:(BOOL)includeHours;

@end
