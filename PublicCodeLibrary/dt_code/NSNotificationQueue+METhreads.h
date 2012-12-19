//
//  NSNotificationQueue+METhreads.h
//  IphoneEPG
//
//  Created by Pierre Bongen on 28.01.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSNotificationQueue ( METhreads )

// MARK: 
// MARK:  Enqueuing Notifications on the Main Thread 

+ (void)enqueueNotificationOnMainThreadsDefaultQueue:(NSNotification *)notification 
	postingStyle:(NSPostingStyle)postingStyle;

@end
