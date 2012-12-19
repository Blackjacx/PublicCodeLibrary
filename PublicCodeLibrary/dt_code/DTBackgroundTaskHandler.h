//
//  DTBackgroundTaskHandler.h
//  MedienCenter
//
//  Created by Stefan Herold on 18.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@interface DTBackgroundTaskHandler : NSObject

+ (DTBackgroundTaskHandler *)sharedInstance;

- (void)registerObjectForBackgroundExecution:(id)anObject;
- (void)unregisterObjectForBackgroundExecution:(id)anObject;

- (void)startBackgroundTask;
- (void)killBackgroundTask;

- (BOOL)isBackgroundTaskRunning;

@end
