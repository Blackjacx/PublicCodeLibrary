//
//  NSObject+NSInvocation.h
//  DTLibrary
//
//  Created by Pierre Bongen on 07.10.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>



// MARK: 

@interface NSObject ( NSInvocation )

// MARK: 
// MARK: Perform Delayed Invocations

+ (void)cancelPreviousPerformRequestOfInvocationWithDelay:(NSInvocation *)invocation;
	
+ (void)performInvocation:(NSInvocation *)invocation afterDelay:(NSTimeInterval)delay;

// MARK: 
// MARK: Perform Invocations on the Main Thread

/*!
	\name Perform Invocations on the Main Thread
	
	@{
*/

+ (void)cancelPreviousPerformRequestOfInvocationOnMainThread:(NSInvocation *)invocation;

/*!
	\brief Performs the given invocation on the main thread.
	\param invocation The invocation which is to be performed in the main 
		thread.
	
	This method does not wait for the invocation to be performed. Possible
	return values are dropped.
*/
+ (void)performInvocationOnMainThread:(NSInvocation *)invocation;

// MARK: 
// MARK: Perform Invocations on Arbitrary Threads

/*!
	\name Perform Invocations on Arbitrary Threads
	
	@{
*/

/*!
 \brief Performs the given invocation on the given Thread.
 \param invocation The invocation which is to be performed.
 \param thread The thread to use If thread is nil then the 
	main thread will be used.
 
 This method does not wait for the invocation to be performed. Possible
 return values are dropped.
 */
+ (void)performInvocation:(NSInvocation *)invocation onThread:(NSThread *)thread;

//!@}

// MARK: 
// MARK: Obtaining Invocations

/*!
	\name Obtaining Invocations
	
	@{
*/

/*!
	\brief Returns an invocation object for a given selector.
	\param selector The selector for which the invocation is to be returned.
	\return The \c NSInvocation object or \c nil if the receiver does not
		respond to the selector \c selector.
	
	The target and selector of the invocation returned are set to the receiver
	and \c selector.
*/
- (NSInvocation *)invocationForSelector:(SEL)selector;

//!@}

@end

// MARK: 
