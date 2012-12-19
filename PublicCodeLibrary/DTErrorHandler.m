//
//  MCErrorHandler.m
//  MedienCenter
//
//  Created by said.el-mallouki on 23.03.09.
//  Copyright 2009 mallouki.de. All rights reserved.
//
#import "DTErrorHandler.h"
#import <UIKit/UIKit.h>

static DTErrorHandler * DTErrorHandlerSharedInstance = nil;

@implementation DTErrorHandler 

#pragma mark
#pragma mark NSObject: Creating, Copying, and Deallocating Objects

+ (id)allocWithZone:(NSZone *)zone
{
	return [[self sharedErrorHandler] retain];
}

#pragma mark 
#pragma mark 
#pragma mark NSObject: Managing Reference Counts

- (id)autorelease
{
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (void)release
{
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax;
}

#pragma mark
#pragma mark
#pragma mark Getting the Shared Error Handler

+ (DTErrorHandler *)sharedErrorHandler
{
	if ( !DTErrorHandlerSharedInstance )
	{
		DTErrorHandlerSharedInstance = [[super allocWithZone:NULL] init];
	}
	
	return DTErrorHandlerSharedInstance;
}

#pragma mark
#pragma mark 
#pragma mark Handling Errors
-(void)handleError:(DTError *)anError inView:(UIViewController *)aView
{
}

- (void)handleError:(NSError *)error 
			delegate:(id)delegate
{
	//DT_ASSERT(NO, @"Overwrite this Method!");
}

@end