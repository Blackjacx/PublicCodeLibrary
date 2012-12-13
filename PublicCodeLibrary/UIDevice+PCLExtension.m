//
//  UIDevice+PCLExtension.m
//  PrivateCodeLibrary
//
//  Created by Stefan Herold on 6/24/12.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#include <sys/types.h>
#include <sys/sysctl.h>

#import "UIDevice+PCLExtension.h"

@implementation UIDevice (PCLExtension)

+ (BOOL)isPad {
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

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
		
		result = @(machineCString);
	}
	@finally 
	{
		free( machineCString );
		machineCString = NULL;
	}
	
	return result;
}

@end
