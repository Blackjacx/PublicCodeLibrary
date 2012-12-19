//
//  DTBackgroundTaskHandler.m
//  MedienCenter
//
//  Created by Stefan Herold on 18.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DTBackgroundTaskHandler.h"
#import "DTDebugging.h"

@interface DTBackgroundTaskHandler ()
- (NSString *)idForObject:(id)anObject;
- (void)fireDelayedKillOfBackgroundTask:(NSTimer*)timer;
- (BOOL)hasObjectsRegisteredToRunInBackground;
- (void)stopBackgroundTaskTimer;
@property(retain, nonatomic)NSMutableSet * registeredObjects;
@property(assign, nonatomic)UIBackgroundTaskIdentifier backgroundTaskID;
@property(retain, nonatomic)NSTimer * backgroundTaskTimer;

@end

@implementation DTBackgroundTaskHandler
@synthesize registeredObjects = _registeredObjects;
@synthesize backgroundTaskID = _backgroundTaskID;
@synthesize backgroundTaskTimer = _backgroundTaskTimer;

// MARK: 
// MARK: Singleton pattern

- (id)copyWithZone:(NSZone *)zone { return self; }
- (void)dealloc { [super dealloc]; /* should never be called */ }
- (id)autorelease { return self; }
- (oneway void)release { /* won't be released */ }
- (id)retain { return self; }
- (NSUInteger)retainCount { return NSUIntegerMax; /* this is soooo non-zero */ }

+ (DTBackgroundTaskHandler *)sharedInstance {
    static dispatch_once_t predicate;
	static DTBackgroundTaskHandler * instance = nil;
	
    dispatch_once(&predicate, ^{
        instance = [[super allocWithZone:NULL] init];
    });
		
	return instance;	
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (id)init {
    if ( self = [super init] ) {
		self.registeredObjects = [NSMutableSet set];
		self.backgroundTaskID = UIBackgroundTaskInvalid;
		self.backgroundTaskTimer = nil;		
    }
	return self;
}

// MARK: 
// MARK: Handling Background Tasks

- (void)registerObjectForBackgroundExecution:(id)anObject
{
	// If device doesn't support multi tasking, we don't need to register
	if( ![[UIDevice currentDevice] isMultitaskingSupported] ) {
		return;
	}
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		NSString * ID = [self idForObject:anObject];
		
		if( !anObject || !ID || [_registeredObjects containsObject:ID] )
			return;

		[_registeredObjects addObject:ID];
			
	//	DT_LOG(@"BACKGROUND_TASK_HANDLER", @"parameter address: 0x%lx   objects in list (%d): \n%@", anObject, [_registeredObjects count], _registeredObjects);
		DT_LOG(@"BACKGROUND_TASK_HANDLER", @"parameter type: %@   objects in list (%d)", NSStringFromClass([anObject class]), [_registeredObjects count]);
			
		// We got new commands in the list - so dont end the background task.
		[self stopBackgroundTaskTimer];
	});
}

- (void)unregisterObjectForBackgroundExecution:(id)anObject
{
	// If device doesn't support multi tasking, we don't need to unregister
	if( ![[UIDevice currentDevice] isMultitaskingSupported] ) {
		return;
	}
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	
		if( !anObject )
			return;
		
		NSString * ID = [self idForObject:anObject];
		[_registeredObjects removeObject:ID];
		
	//	DT_LOG(@"BACKGROUND_TASK_HANDLER", @"parameter address: 0x%lx   objects in list (%d): \n%@", anObject, [_registeredObjects count], _registeredObjects);
		DT_LOG(@"BACKGROUND_TASK_HANDLER", @"parameter type: %@   objects in list (%d)", NSStringFromClass([anObject class]), [_registeredObjects count]);
		
		// No more objects in queue, so end the background task
		// Wait some seconds to be shure that nothing else needs this task.
		if( ![self hasObjectsRegisteredToRunInBackground] && [self isBackgroundTaskRunning] ) 
		{
			CGFloat secondsToWait = 3.0f;
			[self stopBackgroundTaskTimer];
			self.backgroundTaskTimer = [NSTimer timerWithTimeInterval:secondsToWait 
					target:self 
					selector:@selector(fireDelayedKillOfBackgroundTask:) 
					userInfo:nil 
					repeats:NO];
					
			[[NSRunLoop mainRunLoop] addTimer:self.backgroundTaskTimer forMode:NSDefaultRunLoopMode];
			
			DT_LOG(@"BACKGROUND_TASK_HANDLER", @"timer scheduled for in %.1f sec.", secondsToWait);
		}
	});
}

- (NSString *)idForObject:(id)anObject
{
	if( !anObject ) {
		return nil;
	}		
	Class objectsClass = [anObject class];
	NSString * hexAddress = [NSString stringWithFormat:@"%p", anObject];
	NSString * ID = [NSString stringWithFormat:@"[%@]_[%@]", hexAddress, NSStringFromClass(objectsClass)];
	return ID;
}

- (void)startBackgroundTask
{
	if( ![[UIDevice currentDevice] isMultitaskingSupported] ) {
		return;
	}
	
	// No need to start background task - return
	if( ![self hasObjectsRegisteredToRunInBackground] ) {
		return;
	}
		
	self.backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{

		[self killBackgroundTask];
	}];
		
//	// Start the long-running task and return immediately
//	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//		
//		NSAutoreleasePool * innerPool = nil;
//		NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
//		NSTimeInterval nextActionTime = 0;
//		NSTimeInterval actionCycle = 0.5;
//		
//		do
//		{	
//			if( !innerPool ) {
//				innerPool = [[NSAutoreleasePool alloc] init];
//			}
//			
//			NSDate * nextRunDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0.1f];
//			NSTimeInterval runTime = [NSDate timeIntervalSinceReferenceDate] - startTime;
//			BOOL itsActionTime = runTime > nextActionTime;
//							
//			@try 
//			{									
//				// Run this run loop to be able to register/unregister events
//				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nextRunDate];
//			
//				// Run the main run loop to receive the timer event
//				[[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:nextRunDate];
//			}
//			@finally 
//			{
//				[nextRunDate release]; nextRunDate = nil;
//				
//				// Don't take action every cycle
//				if(  itsActionTime  ) {
//					
//					[innerPool release]; innerPool = nil;
//									
//					DT_LOG(@"BACKGROUND_TASK_HANDLER", @"MainThread: %d     Time Remaining: %.1f     ", 
//                       [NSThread isMainThread], 
//                       [[UIApplication sharedApplication] backgroundTimeRemaining]);
//					
//					nextActionTime = runTime + actionCycle;
//				}
//			}
//		}
//		while ( [self isBackgroundTaskRunning] );
//		
//		[self killBackgroundTask];
//    });
}

- (void)killBackgroundTask
{	
	if( ![[UIDevice currentDevice] isMultitaskingSupported] ) {
		return;
	}
	
	[self stopBackgroundTaskTimer];
	
	DT_LOG(@"BACKGROUND_TASK_HANDLER", @"Background Task ended!");
				
    if ( [self isBackgroundTaskRunning] )
	{
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskID];
		self.backgroundTaskID = UIBackgroundTaskInvalid;
	}
}

- (BOOL)isBackgroundTaskRunning
{
	return self.backgroundTaskID != UIBackgroundTaskInvalid;
}

- (void)fireDelayedKillOfBackgroundTask:(NSTimer *)timer
{	
	DT_LOG(@"BACKGROUND_TASK_HANDLER", @"");
	
	[self killBackgroundTask];
}

- (BOOL)hasObjectsRegisteredToRunInBackground 
{
	NSUInteger registeredObjectsCount = [_registeredObjects count];
	return registeredObjectsCount > 0;	
}

- (void)stopBackgroundTaskTimer
{
	[self.backgroundTaskTimer invalidate];
	self.backgroundTaskTimer = nil;
}

@end