/*!
 @file		PCLBackgroundTaskHandler.h
 @brief		Easy management of background tasks
 @author	Stefan Herold
 @date		2011-10-24
 @copyright	Copyright (c) 2012 Stefan Herold. All rights reserved.
 */

@interface PCLBackgroundTaskHandler : NSObject

+ (PCLBackgroundTaskHandler *)sharedInstance;

- (void)registerObjectForBackgroundExecution:(id)anObject;
- (void)unregisterObjectForBackgroundExecution:(id)anObject;

- (void)startBackgroundTask;
- (void)killBackgroundTask;

- (BOOL)isBackgroundTaskRunning;

@end
