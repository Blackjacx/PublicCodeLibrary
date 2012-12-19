//
//  UIDevice+DTAdditions.m
//  DTLibrary
//
//  Created by Stefan Herold on 11.01.11.
//  Copyright 2011 Deutsche Telekom AG. All rights reserved.
//

#import "UIDevice+DTAdditions.h"

#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice (DTAdditions)

- (NSString *)machine
{
	NSString *result = nil;

	//
	// Obtain machine type.
	//
	
	size_t size = 0;

	if ( sysctlbyname("hw.machine", NULL, &size, NULL, 0) )
	{
		return result;
	}
	
	char *machineCString = malloc(size);
	
	@try
	{
		if ( sysctlbyname("hw.machine", machineCString, &size, NULL, 0) )
		{
			return result;
		}
	
		result = [NSString 
			stringWithCString:machineCString 
			encoding:NSUTF8StringEncoding];
	}
	@finally 
	{
		free( machineCString );
		machineCString = NULL;
	}
	
	return result;
}

+ (BOOL)isPad {
	return ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad );
}

+ (BOOL)isPhone {
	return ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone );
}

+ (BOOL)isOSEqualOrGreaterIOS6
{    
    return 6 <=  [self majorOSVersion] ? YES : NO;
}


+ (NSUInteger)majorOSVersion {

	NSCharacterSet * divider = [NSCharacterSet characterSetWithCharactersInString:@"."];
	NSString * osVersion = [[[self class] currentDevice] systemVersion];
	NSArray * comps = [osVersion componentsSeparatedByCharactersInSet:divider];
	NSString * majorVersion = [comps objectAtIndex:0]; // first value
	NSInteger majorVersionAsInteger = [majorVersion integerValue];

	if( majorVersionAsInteger < 0 )
		return 0;

	return (NSUInteger)majorVersionAsInteger;
}

+ (BOOL)hasDeviceEnoughFreeSpaceToSaveDataOfSize:(DTFileSize)dataSize {

	NSFileManager * const fileManager = [NSFileManager defaultManager];
	NSString * tempDirectory = NSTemporaryDirectory();
	NSError * error = nil;
	NSDictionary * fsDict = [fileManager attributesOfFileSystemForPath:tempDirectory error:&error];
	DTFileSize freeSize = [(NSNumber*)[fsDict objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];

	if( freeSize > dataSize )
		return YES;

	return NO;
}

@end
