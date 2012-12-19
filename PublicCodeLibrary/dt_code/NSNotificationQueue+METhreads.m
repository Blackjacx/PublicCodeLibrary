//
//  NSNotificationQueue+METhreads.m
//  IphoneEPG
//
//  Created by Pierre Bongen on 28.01.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "NSNotificationQueue+METhreads.h"



@interface NSNotificationQueue ( METhreadsPrivate )

// MARK:  
// MARK:  Enqueuing Notifications on the Main Thread (private)

+ (void)enqueueNotificationOnMainThreadsDefaultQueueASAP:(NSNotification *)notification;
+ (void)enqueueNotificationOnMainThreadsDefaultQueueNow:(NSNotification *)notification;
+ (void)enqueueNotificationOnMainThreadsDefaultQueueWhenIdle:(NSNotification *)notification;

@end

// MARK:  
// MARK:  
// MARK:  

@implementation NSNotificationQueue ( METhreadsPrivate )

// MARK: 
// MARK:  Enqueuing Notifications on the Main Thread 

+ (void)enqueueNotificationOnMainThreadsDefaultQueueASAP:(NSNotification *)notification
{
	NSThread * const mainThread = [NSThread mainThread];

	if ( [NSThread currentThread] != mainThread )
	{
		[self 
			performSelector:_cmd
			onThread:mainThread
			withObject:notification
			waitUntilDone:NO];
	}
	else 
	{
		[[NSNotificationQueue defaultQueue] 
			enqueueNotification:notification
			postingStyle:NSPostASAP
			coalesceMask:NSNotificationNoCoalescing
			forModes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
	}
}

+ (void)enqueueNotificationOnMainThreadsDefaultQueueNow:(NSNotification *)notification
{
	NSThread * const mainThread = [NSThread mainThread];

	if ( [NSThread currentThread] != mainThread )
	{
		[self 
			performSelector:_cmd
			onThread:mainThread
			withObject:notification
			waitUntilDone:NO];
	}
	else 
	{
		[[NSNotificationQueue defaultQueue] 
			enqueueNotification:notification
			postingStyle:NSPostNow
			coalesceMask:NSNotificationNoCoalescing
			forModes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
	}
}

+ (void)enqueueNotificationOnMainThreadsDefaultQueueWhenIdle:(NSNotification *)notification
{
	NSThread * const mainThread = [NSThread mainThread];

	if ( [NSThread currentThread] != mainThread )
	{
		[self 
			performSelector:_cmd
			onThread:mainThread
			withObject:notification
			waitUntilDone:NO];
	}
	else 
	{
		[[NSNotificationQueue defaultQueue] 
			enqueueNotification:notification
			postingStyle:NSPostWhenIdle
			coalesceMask:NSNotificationNoCoalescing
			forModes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
	}
}

@end

// MARK:  
// MARK:  
// MARK:  

@implementation NSNotificationQueue ( METhreads )

// MARK:  

+ (void)enqueueNotificationOnMainThreadsDefaultQueue:(NSNotification *)notification 
	postingStyle:(NSPostingStyle)postingStyle
{
	@synchronized( self )
	{
		switch ( postingStyle )
		{
		case NSPostASAP:
			[self enqueueNotificationOnMainThreadsDefaultQueueASAP:notification];
			break;
			
		case NSPostNow:
			[self enqueueNotificationOnMainThreadsDefaultQueueNow:notification];
			break;

		case NSPostWhenIdle:
			[self enqueueNotificationOnMainThreadsDefaultQueueWhenIdle:notification];
			break;
			
		default :
			NSAssert( NO, @"Yet unhandled posting style." );
		}
	}
}

@end
