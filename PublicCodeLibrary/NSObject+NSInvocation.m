//
//  NSObject+NSInvocation.m
//  DTLibrary
//
//  Created by Pierre Bongen on 07.10.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "NSObject+NSInvocation.h"



// MARK: 

@interface NSObject ( NSInvocationPrivate )

// MARK: 
// MARK: Invoking Invocations

+ (void)invokeInvocation:(NSInvocation *)invocation;

@end



// MARK: 
// MARK: -
// MARK: 

@implementation NSObject ( NSInvocation )

// MARK: 
// MARK: Perform Delayed Invocations

+ (void)cancelPreviousPerformRequestOfInvocationWithDelay:(NSInvocation *)invocation
{
	if ( invocation )
	{
		[self 
			cancelPreviousPerformRequestsWithTarget:invocation
			selector:@selector( invokeInvocation: )
			object:invocation];
	}
}
	
+ (void)performInvocation:(NSInvocation *)invocation afterDelay:(NSTimeInterval)delay
{
	[invocation retainArguments];
	
	[self 
		performSelector:@selector( invokeInvocation: ) 
		withObject:invocation 
		afterDelay:delay];
}

// MARK: 
// MARK: Perform Invocations on the Main Thread

+ (void)cancelPreviousPerformRequestOfInvocationOnMainThread:(NSInvocation *)invocation
{
	if ( invocation )
	{
		[NSObject 
			cancelPreviousPerformRequestsWithTarget:self
			selector:@selector( performInvocationOnMainThread: )
			object:invocation];
	}
}

+ (void)performInvocationOnMainThread:(NSInvocation *)invocation
{
	if ( [NSThread currentThread] != [NSThread mainThread] )
	{
		[invocation retainArguments];

		[self 
			performSelectorOnMainThread:_cmd 
			withObject:invocation
			waitUntilDone:NO];
	}
	else 
	{
		[invocation invoke];
	}
}

+ (void)performInvocationOnCurrentThread:(NSInvocation *)invocation
{
	[invocation invoke];
}

// MARK: 
// MARK: Perform Invocations on Arbitrary Threads

+ (void)performInvocation:(NSInvocation *)invocation onThread:(NSThread *)thread
{
	thread = thread ? thread : [NSThread mainThread];

	if ( [NSThread currentThread] == thread )
	{
		[invocation invoke];
	}
	else 
	{
		[invocation retainArguments];

		[self performSelector:@selector(performInvocationOnCurrentThread:)
					 onThread:thread 
				   withObject:invocation 
				waitUntilDone:NO];
	}
}

// MARK: 
// MARK: Obtaining Invocations

- (NSInvocation *)invocationForSelector:(SEL)selector
{
	NSInvocation *result = nil;
	
	//
	// Check parameter.
	//
	
	if ( ![self respondsToSelector:selector] )
	{
		return nil;
	}
	
	//
	// Create NSInvocation object.
	//
	
	NSMethodSignature * const methodSignature = [self methodSignatureForSelector:selector];
	
	if ( !methodSignature )
	{
		return result;
	}
	
	result = [NSInvocation invocationWithMethodSignature:methodSignature];
	
	[result setTarget:self];
	[result setSelector:selector];
	
	return result;
}

@end



// MARK: 
// MARK: -
// MARK: 

@implementation NSObject ( NSInvocationPrivate )

// MARK: 
// MARK: Invoking Invocations

+ (void)invokeInvocation:(NSInvocation *)invocation
{
	[invocation invoke];
}

@end

// MARK: 
