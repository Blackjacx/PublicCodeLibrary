//
//  NSNotificationCenter+METhreads.h
//  IphoneEPG
//
//  Created by Pierre Bongen on 12.03.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSNotificationCenter ( METhreads )

// MARK: 
// MARK: Working with the Main Threads Notification Centre

/*!
	\name Working with the Main Threads Notification Centre
	
	@{
*/

+ (void)addObserverOnMainThread:(id)notificationObserver 
	selector:(SEL)notificationSelector name:(NSString *)notificationName 
	object:(id)notificationSender;

+ (void)removeObserverOnMainThread:(id)notificationObserver;

+ (void)removeObserverOnMainThread:(id)notificationObserver 
	name:(NSString *)notificationName object:(id)notificationSender;
	
//!@}

@end
