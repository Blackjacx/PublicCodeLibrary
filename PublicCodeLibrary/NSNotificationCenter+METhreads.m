//
//  NSNotificationCenter+METhreads.m
//  IphoneEPG
//
//  Created by Pierre Bongen on 12.03.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "NSNotificationCenter+METhreads.h"

// DTAG classes and macros.
#import "DTStrings.h"



DT_DEFINE_KEY( NSNotificationCenterMEThreadsKeyObserver );
DT_DEFINE_KEY( NSNotificationCenterMEThreadsKeyName );
DT_DEFINE_KEY( NSNotificationCenterMEThreadsKeyObject );
DT_DEFINE_KEY( NSNotificationCenterMEThreadsKeySelector );



// MARK: 
// MARK: 
// MARK: 

@interface NSNotificationCenter ( METhreadsPrivate )

// MARK: 
// MARK:  Working with the Main Threads Notification Centre (private)

+ (void)addObserverOnMainThreadWithParameters:(NSDictionary *)dictionary;
+ (void)removeObserverOnMainThreadWithParameters:(NSDictionary *)dictionary;

@end



// MARK: 
// MARK: 
// MARK: 

@implementation NSNotificationCenter ( METhreads )

// MARK: 
// MARK:  Working with the Main Threads Notification Centre

+ (void)addObserverOnMainThread:(id)notificationObserver 
	selector:(SEL)notificationSelector name:(NSString *)notificationName 
	object:(id)notificationSender
{
	@synchronized ( self )
	{
		NSMutableDictionary * const parameters = [NSMutableDictionary 
			dictionaryWithObjectsAndKeys:
				notificationObserver,
				NSNotificationCenterMEThreadsKeyObserver,
				[NSValue valueWithPointer:notificationSelector],
				NSNotificationCenterMEThreadsKeySelector,
				nil];
		
		if ( notificationName )
			[parameters 
				setObject:notificationName
				forKey:NSNotificationCenterMEThreadsKeyName];
		
		if ( notificationSender )
			[parameters
				setObject:notificationSender 
				forKey:NSNotificationCenterMEThreadsKeyObject];
		
		[self addObserverOnMainThreadWithParameters:parameters];
	}
}

+ (void)removeObserverOnMainThread:(id)notificationObserver
{
	NSAutoreleasePool * const autoreleasePool = [NSAutoreleasePool new];
	
	@try
	{
		if ( [NSThread currentThread] == [NSThread mainThread] )
		{
			[[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
		}
		else 
		{
			[self
				performSelectorOnMainThread:_cmd
				withObject:notificationObserver
				waitUntilDone:YES];
		}
	}
	@finally 
	{
		[autoreleasePool release];
	}
}

+ (void)removeObserverOnMainThread:(id)notificationObserver 
	name:(NSString *)notificationName object:(id)notificationSender
{
	@synchronized ( self )
	{
		NSMutableDictionary * const parameters = [NSMutableDictionary
			dictionaryWithObject:notificationObserver
			forKey:NSNotificationCenterMEThreadsKeyObserver];
		
		if ( notificationName )
			[parameters
				setObject:notificationName
				forKey:NSNotificationCenterMEThreadsKeyName];

		if ( notificationSender )
			[parameters
				setObject:notificationSender
				forKey:NSNotificationCenterMEThreadsKeyObject];
		
		[self removeObserverOnMainThreadWithParameters:parameters];
	}
}
	
@end




// MARK: 
// MARK: 
// MARK: 

@implementation NSNotificationCenter ( METhreadsPrivate )

// MARK: 
// MARK:  Working with the Main Threads Notification Centre (private)

+ (void)addObserverOnMainThreadWithParameters:(NSDictionary *)dictionary;
{
	if ( [NSThread currentThread] == [NSThread mainThread] )
	{
		SEL selector = NULL;
		NSValue * const selectorAsValue = [dictionary objectForKey:
			NSNotificationCenterMEThreadsKeySelector];
		selector = [selectorAsValue pointerValue];
	
		[[NSNotificationCenter defaultCenter]
			addObserver:[dictionary objectForKey:NSNotificationCenterMEThreadsKeyObserver]
			selector:selector
			name:[dictionary objectForKey:NSNotificationCenterMEThreadsKeyName]
			object:[dictionary objectForKey:NSNotificationCenterMEThreadsKeyObject]];
	}
	else 
	{
		[self 
			performSelectorOnMainThread:_cmd
			withObject:dictionary
			waitUntilDone:NO];
	}

}

+ (void)removeObserverOnMainThreadWithParameters:(NSDictionary *)dictionary
{
	NSAutoreleasePool * const autoreleasePool = [NSAutoreleasePool new];
	
	@try
	{
		if ( [NSThread currentThread] == [NSThread mainThread] )
		{
			[[NSNotificationCenter defaultCenter]
				removeObserver:[dictionary objectForKey:NSNotificationCenterMEThreadsKeyObserver]
				name:[dictionary objectForKey:NSNotificationCenterMEThreadsKeyName]
				object:[dictionary objectForKey:NSNotificationCenterMEThreadsKeyObject]];
		}
		else
		{
			[self
				performSelectorOnMainThread:_cmd
				withObject:dictionary
				waitUntilDone:NO];
		}
	}
	@finally 
	{
		[autoreleasePool release];
	}
}

@end