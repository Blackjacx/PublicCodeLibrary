//
//  NSDate+DTUTCFormatting.h
//  DTLibrary
//
//  Created by Stefan Herold on 25.11.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (DTUTCFormatting)

/*!
 \brief Converts the given UTC time string to an \c NSDate object.
 \param timeString A string which is expected to have the format
    <tt>yyyy-MM-dd'T'HH:mm:ss.000Z</tt>.
 \return An \c NSDate object or \c nil when failing.
 \note No checks except those regarding the format are made.
*/
+ (NSDate *)dateFromUTCString:(NSString *)timeString;

@end
