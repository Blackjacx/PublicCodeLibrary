//
//  DTRestCommand.m
//  DTLibrary
//
//  Created by stefan herold on 11.07.09.
//  Copyright 2009 Deutsche Telekom AG. All rights reserved.
//

#import "DTRESTCommand.h"
//#import "DTRESTCommand_private.h"

// DTFoundation.
#import "DTStrings.h"
#import "NSObject+NSInvocation.h"
#import "DTBackgroundTaskHandler.h"
#import "DTCache.h"
#import "NSString+DTExtensions.h"

// DTBackend.
#import "NSString+DTUserAgent.h"
#import "NSURLRequest+DTExtendedDescription.h"
#import "DTError.h"


@interface DTRESTCommand ()

@property ( retain, readwrite ) NSThread * callingThread;

@end

// MARK:  
// MARK: Error Domains

DT_DEFINE_STRING( DTHTTPErrorDomain, "de.telekom.dtlibrary.errors.http" );

/*!
	@name Global Public Contants
	{
*/
		
// MARK: 
// MARK: Global Public Contants

NSStringEncoding const DTRestCommandDefaultStringEncoding = NSUTF8StringEncoding;

//! }

// MARK:  
// MARK: Keys

/*!
 \name KVC Keys
 
 @{
 */

DT_DEFINE_STRING( DTRESTCommandKeyFinished, "finished" );
DT_DEFINE_STRING( DTRESTCommandKeyCanceled, "canceled" );

//!@}


static NSMutableSet * DTRESTCommandExecutedCommands = nil;
static NSMutableSet * DTRESTCommandScheduledCommands = nil;

id <DTSession> DTRESTCommandDefaultSession = nil;
id <DTAuthenticationHandler> DTRESTCommandDefaultAuthenticationHandler = nil;


@interface DTRESTCommand ()
@property ( assign, readwrite, getter=isExecuting ) BOOL executing;
@property ( assign, readwrite, getter=isScheduledForExecution ) BOOL scheduledForExecution;
@end

// MARK:  
// MARK: -
// MARK: 

@implementation DTRESTCommand
@synthesize URL;
@synthesize URLResponse;
@synthesize callingThread = _callingThread;
@synthesize identifier;
@synthesize session;
@synthesize error;
@synthesize result;
@synthesize canceled;
@synthesize cancelling;
@synthesize executing;
@synthesize scheduledForExecution;
@synthesize finished;
@synthesize failed;
@synthesize finishesOnCacheHit;
@synthesize cancelsOnCacheMiss;
@synthesize hitCache;
@synthesize delegate;
@synthesize progressDelegate;
@synthesize URLConnection;
@synthesize receivedData;
@synthesize receivedDataAsString = _receivedDataAsString;
@synthesize terminationCondition;
@synthesize authenticationHandler;
@synthesize percentageLoaded = _percentageLoaded;

// MARK:
// MARK: NSObject: Creating, Copying, and Deallocating Objects

+ (void)initialize {

	DTRESTCommandExecutedCommands = [[NSMutableSet alloc] init];
	DTRESTCommandScheduledCommands = [[NSMutableSet alloc] init];
}

- (void)dealloc 
{	
	NSAssert( 
		 !self.executing, 
		 @"The command must be finished or cancelled before is can be deallocated." );
    
	NSAssert(
		 ![DTRESTCommandExecutedCommands containsObject:self],
		 @"Command is still contained in set of executed commands." );
    
	NSAssert(
		 ![DTRESTCommandScheduledCommands containsObject:self],
		 @"Command is still contained in set of scheduled commands." );
		 	
	[self->receivedData release];
	self->receivedData = nil;
	
	[_receivedDataAsString release];
	_receivedDataAsString = nil;
	
	[self->URLConnection release];
	self->URLConnection = nil;
	
	[self->URLResponse release];
	self->URLResponse = nil;
	
	[self->URL release];
	self->URL = nil;
	
	[self->identifier release];
	self->identifier = nil;
    
	self.error = nil;
	self.result = nil;
    
	self.callingThread = nil;
	
	[self->terminationCondition release];
	self->terminationCondition = nil;
    
	[super dealloc]; 
}

// MARK:
// MARK: NSObject: Describing Objects

- (NSString *)description
{
	//
	// Do NOT call the URL-Request here with its lazy initialization method (the getter)!!!
	//
    
	NSURLRequest * aRequest = nil;//[[[self URLRequest] copy] autorelease];
	
	return [NSString
            stringWithFormat:@"%@:\n\tURL=%@\n\tMethod:%@\n\tHeader Fields=%@\n\tBody=%@",
			[super description],
			[aRequest URL],
			[aRequest HTTPMethod],
			[aRequest allHTTPHeaderFields],
			[[[NSString alloc]
              initWithData:[aRequest HTTPBody]
              encoding:DTRestCommandDefaultStringEncoding] autorelease]];
}

// MARK: 
// MARK: NSObject: Identifying and Comparing Objects

- (BOOL)isEqual:(id)object
{
	if ( ![object isKindOfClass:[DTRESTCommand class]] )
		return NO;
	
	return [[(DTRESTCommand *)object identifier] 
            isEqualToString:self.identifier];
}

- (NSUInteger)hash
{
	return [self.identifier hash];
}

// MARK: 
// MARK: NSURLConnection: Connection Data and Responses

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	@synchronized ( self )
	{
		if ([self.progressDelegate respondsToSelector:@selector(restCommand:didUploadPercentage:)])
		{
			// Call the delegate to notify about progress: 
			// Calculate the percentage of data transferred:
			float percentage = 1;
			if (totalBytesExpectedToWrite > 0)
				percentage = (float)totalBytesWritten/ (float)totalBytesExpectedToWrite;

			_percentageLoaded = percentage;
			
			DT_LOG(@"BACKEND", @"DidSendBodyData:(%i/%i) Percent: %f",totalBytesWritten, totalBytesExpectedToWrite, percentage);
			NSMethodSignature * const methodSignature = [(NSObject *)self.progressDelegate 
				methodSignatureForSelector:@selector(restCommand:didUploadPercentage:)];
			
			NSInvocation * const invocation = [NSInvocation 
				invocationWithMethodSignature:methodSignature];
			
			[invocation setTarget:self.progressDelegate];
			[invocation setSelector:@selector(restCommand:didUploadPercentage:)];
			[invocation setArgument:&self atIndex:2];
			[invocation setArgument:&percentage atIndex:3];
			[invocation retainArguments];

			[NSObject performInvocation:invocation onThread:_callingThread];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{	
	if ( !self->receivedData )
		self->receivedData = [NSMutableData new];
    
	[self->receivedData appendData:data];
	
	DT_LOG(@"PROGRESS_TESTING", @"LOG_PROGRESS_DELEGATE: ");
	DT_LOG(@"PROGRESS_TESTING", @"%@ ",self.progressDelegate);
	
	@synchronized ( self )
	{
		if ([self.progressDelegate respondsToSelector:@selector(restCommand:didDownloadPercentage:)]) 
		{		
			// Call the delegate to notify about progress: 
			// Calculate the percentage of data transferred: 
			float percentage = 1;
			
			DT_LOG(@"PROGRESS_TESTING", @"LOG_EXPECTED_CONTENT_LENGTH: ");
			DT_LOG(@"PROGRESS_TESTING", @"%lld ",[self.URLResponse expectedContentLength]);
			
			if ( [self.URLResponse expectedContentLength] > 0 )
				percentage =  (float)[self->receivedData length] / (float)[self.URLResponse expectedContentLength];
			
			DT_LOG(@"BACKEND", @"didReceiveData:(%ld/%ld) Percent: %f", 
				(long)[self->receivedData length], 
				(long)[self.URLResponse expectedContentLength], 
				percentage );
				
			DT_LOG(@"PROGRESS_TESTING", @"didReceiveData:(%ld/%ld) Percent: %f", 
				(long)[self->receivedData length], 
				(long)[self.URLResponse expectedContentLength], 
				percentage );

			
			NSMethodSignature * const methodSignature = [(NSObject *)self.progressDelegate 
				methodSignatureForSelector:@selector(restCommand:didDownloadPercentage:)];
			
			NSInvocation * const invocation = [NSInvocation 
				invocationWithMethodSignature:methodSignature];
			
			[invocation setTarget:self.progressDelegate];
			[invocation setSelector:@selector(restCommand:didDownloadPercentage:)];
			[invocation setArgument:&self atIndex:2];
			[invocation setArgument:&percentage atIndex:3];
			[invocation retainArguments];
			
			[NSObject performInvocation:invocation onThread:_callingThread];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)aResponse
{	
	DT_LOG(@"BACKEND", @"Code (%d - %@) & Response for Cmd (%@): %@", 
			[aResponse statusCode], 
			[NSHTTPURLResponse localizedStringForStatusCode:[aResponse statusCode]], 
			NSStringFromClass([self class]), 
			[aResponse allHeaderFields]);

	[self->URLResponse release];
	self->URLResponse = [aResponse retain];
		
	long long size = [self->URLResponse expectedContentLength];
    
	if ( size == NSURLResponseUnknownLength )	
		size = 1024;
    
	[self->receivedData release];
	self->receivedData = [[NSMutableData alloc] initWithCapacity:size];
}

#if ( defined( ACCEPT_ALL_CERTIFICATES ) && ( ACCEPT_ALL_CERTIFICATES == 1 ) )

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
  return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
	  [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
  [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#endif 

// MARK: 
// MARK: NSURLConnection: Connection Completion

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)anError
{
	DT_LOG( @"CONNECTION_ERROR", @"Connection Error: %@", anError );
    
	@synchronized ( self )
	{
		if ( self.cancelling || self.canceled )
		{
			return;
		}
		
		[URLConnection release];
		URLConnection = nil;
	}
	
	self.error = anError;
    
    [self checkIfOffline:self.error];
    
	// call the registered listeners and return the result
	[self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	@synchronized ( self )
	{
		if ( self.cancelling || self.canceled ) {
			return;
		}
		
		// Save JSON response as string
		_receivedDataAsString = [[NSString alloc] initWithData:self.receivedData 
													  encoding:DTRestCommandDefaultStringEncoding];
		
		DT_LOG( @"JSON_RESPONSE", @"Processing JSON for Command: %@\n\n%@", self, self.receivedDataAsString );

		// --- determine error occurred - set self.error property
		if ( [self isHTTPError] ) {
			[self checkReceivedStringObjectForError:_receivedDataAsString];
		}
		
		if( receivedData && !self.error ) {
			id receivedObject = [self processReceivedData:receivedData];
			
			if( receivedObject ) {
				self.result = receivedObject;
			}
		}

		[URLConnection release];
		URLConnection = nil;
        
        [self set2Online];
	}
		
	[self finish];
}

// MARK: 
// MARK: Initialisation

- (id)initWithSession:(id <DTSession>)aSession
		authenticationHandler:(id<DTAuthenticationHandler>)anAuthenticationHandler
		delegate:(id<DTRESTCommandDelegate>)aDelegate
{
	@try
	{
		if (!anAuthenticationHandler) 
		{
			anAuthenticationHandler = [[self class] defaultAuthenticationHandler];
		}
		
		if ( !aSession )
		{
			aSession = [[self class] defaultSession];
		}
        
		if ( (self = [super init]) ) 
		{
			self->session = [aSession retain];
            self->authenticationHandler = [anAuthenticationHandler retain];
			self.delegate = aDelegate;
			_percentageLoaded = 0;
			
			// Create unique id. 
			CFUUIDRef UUID = CFUUIDCreate( NULL );
			CFStringRef UUIDAsString = CFUUIDCreateString( NULL, UUID );
			self->identifier = [(NSString *)UUIDAsString retain];
			CFRelease( UUID );
			CFRelease( UUIDAsString );
			
			self->finishesOnCacheHit = NO;
			self->cancelsOnCacheMiss = NO;
			
			self->terminationCondition = [NSCondition new];
            
            self->failed = NO;
            self.task = NO;
		}
	}
	@catch ( NSException *e ) 
	{
		[self release];
		self = nil;
	}
    
	return self;
}

// MARK: 
// MARK: Executing the Command

- (void)backgroundExecutionMain
{
	NSException *exception = nil;
	NSAutoreleasePool * const outerAutoreleasePool = [NSAutoreleasePool new];
	
	@try
	{		
		[self execute];        
        BOOL done = NO;
		
		do
		{
			NSAutoreleasePool * const innerAutoreleasePool = [NSAutoreleasePool new];
						
			@try 
			{
				NSDate * dateToRunTo = [[NSDate alloc] initWithTimeIntervalSinceNow:0.1];
				done = ![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:dateToRunTo];
				[dateToRunTo release];
			}
			@catch ( NSException *e ) 
			{
				exception = [e retain];
				@throw;
			}
			@finally 
			{
				[innerAutoreleasePool release];
				[exception autorelease];
			}
		}
		while ( !done && !self.finished && !self.cancelling );
				
		[self->terminationCondition lock];
		if (self.cancelling) 
		{
			self->canceled = YES;
			self->executing = NO;
		}
		[self->terminationCondition signal];
		[self->terminationCondition unlock];
	}
	@catch ( NSException *e ) 
	{
        DT_LOG(@"DT_REST_COMMAND",  @"-[%@ %@]: Caught exception: %@",
					NSStringFromClass( [DTRESTCommand class] ),
					NSStringFromSelector( _cmd ),
					e );
	}
	@finally 
	{
		[outerAutoreleasePool release];
	}
}

- (void)execute
{		
	@synchronized ( self )
	{
		DT_ASSERT_RETURN( !self.executing, @"Command has been executed already. Use reset." );
		DT_ASSERT_RETURN( !self.finished, @"%@ has been finished already. Use reset. Call Stack: %@", NSStringFromClass([self class]), [NSThread callStackSymbols]);
		//DT_ASSERT_RETURN( !self.canceled, @"Command has been cancelled already. Use reset." );
		DT_ASSERT_RETURN ( ![DTRESTCommandExecutedCommands containsObject:self], @"Command is already being executed." );
        		
		DT_LOG(@"BACKEND", @"Is Main Thread: %d  self->thread: %@   currentThread: %@", [NSThread isMainThread], _callingThread, [NSThread currentThread]);
				
		self.scheduledForExecution = NO;
		[[self class] removeScheduledCommand:self];
        
		// Commands run only once in their lifetime.
		if ( self.finished || self.canceled )
		{
			return;
		}
		
		if ( [DTRESTCommandExecutedCommands containsObject:self] ) {

			return;
		}
		
		if ( !_callingThread )
			self.callingThread = [NSThread currentThread];
        
		self.executing = YES;

		//
		// Check cache before we send a request to the server.
		//
		
		id const cachedResult = [self cachedResult];
		
		if ( self.canceled )
			return;
		
		if ( cachedResult )
		{
            DT_LOG(@"BACKEND", @"Cache hit!");

            self.result = cachedResult;
            self->hitCache = YES; 
            
            if( [self useNewCachingStrategy])
            {
                DT_LOG(@"BACKEND", @"New Caching Strategy");
                
                if ([self.delegate respondsToSelector:@selector(restCommandDidSucceed:)]) 
                {
                    NSMethodSignature * const methodSignature = [(NSObject *)self.delegate 
                                                                 methodSignatureForSelector:@selector(restCommandDidSucceed:)];
                    
                    NSInvocation * const invocation = [NSInvocation 
                                                       invocationWithMethodSignature:methodSignature];
                    
                    [invocation setTarget:self->delegate];
                    [invocation setSelector:@selector(restCommandDidSucceed:)];
                    [invocation setArgument:&self atIndex:2];
                    [invocation retainArguments];
                    
                    [NSObject performInvocation:invocation onThread:self.callingThread];
                    
                    if( [self isCacheOutdated] == NO )
                    {
                        DT_LOG(@"BACKEND", @"New Caching Strategy: Cache is _not_ OUTDATED");
                        // Cache is NOT outdated
                        // Don't pickup server data if cache is not outdated ( based on modified date. Not expiration date!)
                        [self finish];
                        return;
                    }
                    DT_LOG(@"BACKEND", @"New Caching Strategy: Cache is OUTDATED!!!");
                }
            }
            else
            {
                DT_LOG(@"BACKEND", @"OLD Caching Strategy");
                
                if ( self.finishesOnCacheHit )
                {
                    [self finish];
                }
                else
                {
                    [[self class] addExecutedCommand:self];
                    [self deferredFinish];
                }
                return;
            }
            
		}
		else if ( self.cancelsOnCacheMiss )
		{
			self->executing = NO;
			[self cancel];
			return;
		}
        
		DT_LOG(@"BACKEND", @"NO Cache hit!");

        
		//
		// If there is no cached result send request.
		//
		
		NSMutableURLRequest * const aRequest = [self URLRequest];
		DT_ASSERT( aRequest, @"Failed to obtain URL request." );

		NSError * credentialsError = nil;
		[self setCredentialsOfRequest:aRequest error:&credentialsError];
        
        DT_LOG( @"DT_REST_REQUEST",
               @"-[%@ %@]: Request is %@\nBody is:\n<body part commented out!!!>",
               NSStringFromClass( [self class] ),
               NSStringFromSelector( _cmd ),
               [aRequest extendedDescription] );
        
        DT_LOG( @"BACKEND_BODY",
               @"-[%@ %@]: Request is %@\nBody is:\n%@",
               NSStringFromClass( [self class] ),
               NSStringFromSelector( _cmd ),
               [aRequest extendedDescription],
               [[[NSString alloc]
                 initWithData:[aRequest HTTPBody]
                 encoding:NSASCIIStringEncoding] autorelease] );
                     
		[[self class] addExecutedCommand:self];
		
		if ( credentialsError )
		{			
			self.error = credentialsError;
			[self deferredFinish];
		}
		else
		{		
			[self->URLConnection release];
			self->URLConnection = [[NSURLConnection
                                    connectionWithRequest:aRequest 
                                    delegate:self] retain];
			
			if ( !self->URLConnection )
			{				
				self.error = [NSError
                              errorWithDomain:DTHTTPErrorDomain 
                              code:DTRESTCommandErrorCodeDidFailToCreateURLRequest
                              userInfo:nil];
				[self deferredFinish];
			}
		}
	}
}

- (void)executeInBackground
{	
	DT_ASSERT_RETURN(!self.executing && !self.scheduledForExecution, @"Command is already being executed.");
	DT_ASSERT(!self.callingThread, @"Expected thread to be nil.");

	self.scheduledForExecution = YES;
	self.callingThread = [NSThread currentThread];

	[[self class] addScheduledCommand:self];

//	static dispatch_queue_t queue;
//	if( !queue )
//		queue = dispatch_queue_create("de.telekom.mediencenter.DTRestCommandBackgroundQueue", DISPATCH_QUEUE_CONCURRENT);
//
//	dispatch_async(queue, ^{
//
//		[self backgroundExecutionMain];
//	});


	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

		[self backgroundExecutionMain];
	});
}

- (void)reexecute
{	
	[self cancel];
	[self reset];
	[self execute];
}

- (void)reexecuteInBackground
{		
	[self cancel];
	[self reset];
	[self executeInBackground];
}

- (void)reset
{
	@synchronized ( self )
	{
		DT_ASSERT_RETURN( !self.executing, 
			@"The command (%@) with delegate (%@) must be canceled first.", 
			NSStringFromClass([self class]), 
			NSStringFromClass([self.delegate class]))
        
		[self willChangeValueForKey:DTRESTCommandKeyCanceled];
		self->canceled = NO;
		[self didChangeValueForKey:DTRESTCommandKeyCanceled];
        
		[self willChangeValueForKey:DTRESTCommandKeyFinished];
		self->finished = NO;
		[self didChangeValueForKey:DTRESTCommandKeyFinished];
		
        self->failed = NO;
        
		self.result = nil;
		self.error = nil;
		self.callingThread = nil;
		
		_percentageLoaded = 0;
	}
}

// MARK: 
// MARK: Finishing the Command

-(void)cancel
{
	[self cancelAndNotifyDelegate:NO];
}


- (void)cancelAndNotifyDelegate:(BOOL)notifyDelegate
{
	@synchronized ( self ) 
	{
		if ((self->executing || self->scheduledForExecution) && ( [NSThread currentThread] != self.callingThread ))
		{
			@try
			{
				[self->terminationCondition lock];
		
				self.cancelling = YES;
	
				while (!self->canceled || !self->finished)
				{
					[self->terminationCondition wait];
				}
			}
			@finally 
			{
				[self->terminationCondition unlock];
			}
		}
			
		[self willChangeValueForKey:DTRESTCommandKeyCanceled];
		self.executing = NO;
		self.scheduledForExecution = NO;
		self->canceled = YES;
		[self didChangeValueForKey:DTRESTCommandKeyCanceled];
        
		[self->URLConnection cancel];
		[self->URLConnection release];
		self->URLConnection = nil;

		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		[NSObject cancelPreviousPerformRequestsWithTarget:self->delegate];
        
		[[self class] removeScheduledCommand:self];
		[[self class] removeExecutedCommand:self];
		
		// Call commandCancelled Delegate method: 
		if (notifyDelegate && [self.delegate respondsToSelector:@selector(restCommandDidCancel:)]) 
		{
			
			NSMethodSignature * const methodSignature = [(NSObject *)self.delegate 
				methodSignatureForSelector:@selector(restCommandDidCancel:)];
			
			NSInvocation * const invocation = [NSInvocation 
				invocationWithMethodSignature:methodSignature];
			
			[invocation setTarget:self->delegate];
			[invocation setSelector:@selector(restCommandDidCancel:)];
			[invocation setArgument:&self atIndex:2];
			[invocation retainArguments];
			
			[NSObject performInvocation:invocation onThread:self.callingThread];
		}

		self.callingThread = nil;
	}
}

- (void)deferredFinish
{
	[self performSelector:@selector(finish) withObject:nil afterDelay:0.0];
}

- (void)finish
{
	[self->terminationCondition lock];
	
	@try  
	{        
		[self willChangeValueForKey:DTRESTCommandKeyFinished];
		self.executing = NO;
		self.scheduledForExecution = NO;
		self->finished = YES;
		[self didChangeValueForKey:DTRESTCommandKeyFinished];
		
		NSInvocation * invocation = nil;
		
		if (
			!( self.finishesOnCacheHit && self->hitCache )
			&& self.delegate
            )
		{
			// Make this condition on self.thread for commands that have their 
			// own execute method and cant set self.thread but execute other
			// commands.
			if (self.error) 
			{
				
                // Handle Authorization Error
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                    [self handleAuthorizationError:self.error];
                               });
                
                
                // Call "restCommandDidFail ..." 
                NSMethodSignature * const methodSignature = [(NSObject *)self.delegate 
															 methodSignatureForSelector:@selector(restCommandDidFail:withError:)];
				
				invocation = [NSInvocation invocationWithMethodSignature:methodSignature];				
				[invocation setTarget:self->delegate];
				[invocation setSelector:@selector(restCommandDidFail:withError:)];
				[invocation setArgument:&self atIndex:2];
				[invocation setArgument:&self->error atIndex:3];
                
                self->failed = YES;
			} 
			else 
			{	
				if (self.delegate && [self.delegate respondsToSelector:@selector(restCommandDidSucceed:)])
				{
					NSMethodSignature * const methodSignature = [(NSObject *)self.delegate 
																 methodSignatureForSelector:@selector(restCommandDidSucceed:)];
					
					invocation = [NSInvocation invocationWithMethodSignature:methodSignature];					
					[invocation setTarget:self->delegate];
					[invocation setSelector:@selector(restCommandDidSucceed:)];
					[invocation setArgument:&self atIndex:2];
				}
			}
		}
		[self->terminationCondition signal];
				
		// Remove executed command from queue to prevent reexecuted commands 
		// from being kicked out because they are still in the execution queue.
		[[self class] removeExecutedCommand:self];
		NSThread * originalThread = self.callingThread;
		self.callingThread = nil;

		// Always! inform the progressDelegate that transfer of data has ended: 
		if (
			self.progressDelegate 
			&& [(NSObject *)self.progressDelegate 
				respondsToSelector:@selector(restCommandDidFinishTransfer:)]
		){
			NSMethodSignature * const methodSignature = [(NSObject *)self.progressDelegate
				methodSignatureForSelector:@selector(restCommandDidFinishTransfer:)];
			
			NSInvocation * const progressDelegateInvocation = 
				[NSInvocation invocationWithMethodSignature:methodSignature];
					
			[progressDelegateInvocation setTarget:self.progressDelegate];
			[progressDelegateInvocation setSelector:@selector(restCommandDidFinishTransfer:)];
			[progressDelegateInvocation setArgument:&self atIndex:2];
			[progressDelegateInvocation retainArguments];

			[NSObject 
				performInvocation:progressDelegateInvocation 
				onThread:originalThread];
		} 

		// Do this at the latest point in this method!!!
		//    - We can see that. Why must it be done at the latest point in this
		//      method?
		if ( invocation )
		{
			[invocation retainArguments];
			[NSObject performInvocation:invocation onThread:originalThread];
			
			DT_LOG(@"BACKGROUND_EXECUTION", @"OriginalThread==MainThread: %d", 
										originalThread==[NSThread mainThread]);
		}
	}
	@finally
	{
		[self->terminationCondition unlock];
	}
}

// MARK: 
// MARK: Determining the Command's Result

- (id)cachedResult
{
	return nil;
}

- (void)invalidateCachedResult
{
}

- (id)processReceivedData:(NSData *)data
{
	if ( !data || self.error )
		return nil;
		
	return [[data retain] autorelease];
}

- (NSData *)receivedData
{
	return [[self->receivedData copy] autorelease];
}

-(BOOL)isHTTPError
{
	switch (self.URLResponse.statusCode) {
		case 200:		// OK
			return NO;
			break;
		case 201:		// Created
			return NO;
			break;
		case 202:		// Accepted
			return NO;
			break;
		case 308:		// Permanent Redirect
			return NO;
			break;
		default:
			break;
	}
	return YES;
}

- (void)checkReceivedStringObjectForError:(NSString *)receivedDataAsString
{
	if ([self isHTTPError]) {
		
		NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								   self.URL,
								   NSURLErrorFailingURLStringErrorKey,
								   nil];
		self.error = [DTError 
					  errorWithDomain:DTHTTPErrorDomain 
					  code:[self.URLResponse statusCode]
					  userInfo:userInfo];
	}
}


// MARK: 
// MARK: Offline Handling
- (void) checkIfOffline:(NSError*) error
{
    // Need to be overwritten by Subclass
}

- (void) set2Online
{
    // Need to be overwritten by Subclass
}


// MARK: 
// MARK: Setting Up Credentials

- (BOOL)authenticationRequired
{
	return NO;
}

- (BOOL)setCredentialsOfRequest:(NSMutableURLRequest *)request 
						  error:(NSError **)outError
{	   
	if (self->authenticationHandler && self.authenticationRequired) 
	{
		return [self->authenticationHandler 
		 setCredentialsForRequest:request 
		 withSession:self.session 
		 andError:outError];
	} 
	
	if (self.authenticationRequired && !self->authenticationHandler) 
	{
		// This is a mistake and has to be fixed: 
		// Should never happen, if it does, then its a bug.
#if defined( DEBUG ) && DEBUG == 1
		[NSException
		 raise:NSInvalidArgumentException
		 format:@"No AuthenticationHandler set but authenticationRequired is YES!"];
#endif
	}
	
	return YES;
}

// MARK:  
// MARK: Obtaining the Command's URL Request

-(void)setAdditionalHeadersForRequest:(NSMutableURLRequest *)aRequest
{
	NSString * const userAgent = [NSString userAgentString];
	[aRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	
	[aRequest setValue:@"compress, gzip" forHTTPHeaderField:@"Accept-Encoding"]; 
	[aRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
}

- (NSMutableURLRequest *)URLRequest
{
	NSMutableURLRequest * const requestResult = [[[NSMutableURLRequest alloc] 
			initWithURL:self.URL
			cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
			timeoutInterval:60.0] autorelease];
	
	[requestResult setHTTPMethod:@"GET"];
	
	[self setAdditionalHeadersForRequest:requestResult];
	
	return requestResult;
}

// MARK: 
// MARK: Working With the Command's URL

- (void)setURLWithRoot:(NSString *)root path:(NSString *)path parameters:(NSDictionary *)parameters
{
	[self 
     setURLWithRoot:root 
     path:path
     parameters:parameters
     sequenceOfParameters:nil];
}

- (void)setURLWithRoot:(NSString *)root path:(NSString *)path parameters:(NSDictionary *)parameters
  sequenceOfParameters:(NSArray *)sequence
{
	NSString * const URLAsString = [[self class] 
                                    URLAsStringWithRoot:root
                                    path:path
                                    parameters:parameters
                                    sequenceOfParameters:sequence];
    
	[self->URL release];
	self->URL = [[NSURL URLWithString:URLAsString] retain];
}

- (NSURL *)URL
{
	return [[self->URL retain] autorelease];
}

- (NSString *)URLRestServiceComponentsAsString
{
	NSString * const URLAsString = [[self URL] absoluteString];
	
	if ( 0 == [URLAsString length] )
		return nil;
	
	NSScanner * const scanner = [NSScanner scannerWithString:URLAsString];
    
	//
	// Scan right behind scheme.
	//
	
	if ( ![scanner scanUpToString:@"//" intoString:NULL] )
		return nil;
	
	if ( ![scanner scanString:@"//" intoString:NULL] )
		return nil;
    
	//
	// Scan up to first slash after scheme and return remainder.
	//
	
	if ( ![scanner scanUpToString:@"/" intoString:NULL] )
		return nil;
	
	return [[scanner string] substringFromIndex:[scanner scanLocation]];
}

- (BOOL) useNewCachingStrategy
{
    return NO;
}

- (BOOL) isCacheOutdated
{
    return YES;
}

+ (NSString *)URLAsStringWithRoot:(NSString *)root
							 path:(NSString *)path
					   parameters:(NSDictionary *)parameters
             sequenceOfParameters:(NSArray *)sequence
{
	DT_ASSERT_RETURN_WITH_VALUE(
		[root isKindOfClass:[NSString class]],
		nil,
		@"Expected root parameter (%@) to be kind of class NSString.", root );

	NSMutableString * const URLAsString = [NSMutableString stringWithString:root];
	
	if ( 0 < [path length] )
		[URLAsString appendFormat:@"/%@", path];
	
	NSArray * const parameterNames = sequence 
    ? sequence
    : [parameters allKeys];
	BOOL firstIteration = YES;
	
	for ( NSString * parameterName in parameterNames )
	{
		NSString * const parameterValueAsString = [parameters objectForKey:parameterName];
		NSString * const escapedParameterValueAsString = [parameterValueAsString URLEncode];
		
		if ( firstIteration )
		{
			firstIteration = NO;
			[URLAsString appendString:@"?"];
		}
		else
			[URLAsString appendString:@"&"];
        
		[URLAsString appendFormat:@"%@=%@",
         parameterName,
         escapedParameterValueAsString];
	}
    
	return URLAsString;
}


// MARK: Managing Network Indicator

+ (void)updateNetworkIndicator {

	dispatch_async(dispatch_get_main_queue(), ^{

		if ( [DTRESTCommandExecutedCommands count] ) {
			
			[self enableNetworkIndicator];
		}
		else {

			[self disableNetworkIndicator];
		}
	});
}

+ (void)enableNetworkIndicator {

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+ (void)disableNetworkIndicator {

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


// MARK: Manage Command Queue

+ (void)addExecutedCommand:(DTRESTCommand *)command
{
	DT_ASSERT_RETURN([command isKindOfClass:self],
					 @"Expected %@ to be kind of %@.",
					 DT_STRINGIFY( command ),
					 NSStringFromClass( [DTRESTCommand class] ));

	@synchronized ( self ) {

		[DTRESTCommandExecutedCommands addObject:command];
	}

	// Register command to be continued if the app goes to background
	[[DTBackgroundTaskHandler sharedInstance] registerObjectForBackgroundExecution:command];
	
	[self updateNetworkIndicator];
}

+ (void)addScheduledCommand:(DTRESTCommand *)command
{
	DT_ASSERT_RETURN([command isKindOfClass:self],
					 @"Expected %@ to be kind of %@.",
					 DT_STRINGIFY( command ),
					 NSStringFromClass( [DTRESTCommand class] ));

	@synchronized ( self ) {

		[DTRESTCommandScheduledCommands addObject:command];
	}	
}

+ (void)cancelAllCommands
{
	@synchronized ( self ) {

		NSSet * const scheduledCommandsCopy = [DTRESTCommandScheduledCommands copy];
		NSSet * const executedCommandsCopy = [DTRESTCommandExecutedCommands copy];

		// Cancel all scheduled commands.
		for ( DTRESTCommand *command in scheduledCommandsCopy ) {

			[command cancelAndNotifyDelegate:YES];
		}

		// Cancel all running commands.
		for ( DTRESTCommand *command in executedCommandsCopy ) {

			[command cancelAndNotifyDelegate:YES];
		}

		[scheduledCommandsCopy release];
		[executedCommandsCopy release];
	}
}

+ (void)cancelCommand:(DTRESTCommand *)command
{
	@synchronized ( self ) {

		DT_ASSERT_RETURN([command isKindOfClass:self],
						 @"Expected %@ to be kind of %@.",
						 DT_STRINGIFY( command ),
						 NSStringFromClass( [DTRESTCommand class] ));
		
		[command cancel];
	}
}

+ (void)removeExecutedCommand:(DTRESTCommand *)command
{
	DT_ASSERT_RETURN([command isKindOfClass:self],
					 @"Expected %@ to be kind of %@.",
					 DT_STRINGIFY( command ),
					 NSStringFromClass( [DTRESTCommand class] ));

	@synchronized ( self ) {

//		if ( [DTRESTCommandExecutedCommands containsObject:command] ) {

			// Unregister command form the background handler
			[[DTBackgroundTaskHandler sharedInstance] unregisterObjectForBackgroundExecution:command];
			[DTRESTCommandExecutedCommands removeObject:command];
//		}
	}

	[self updateNetworkIndicator];
}

+ (void)removeScheduledCommand:(DTRESTCommand *)command
{
	DT_ASSERT_RETURN([command isKindOfClass:self],
					 @"Expected %@ to be kind of %@.",
					 DT_STRINGIFY( command ),
					 NSStringFromClass( [DTRESTCommand class] ));

	@synchronized ( self ) {

//		if ( [DTRESTCommandScheduledCommands containsObject:command] ) {

			[DTRESTCommandScheduledCommands removeObject:command];
//		}
	}
}


// MARK: AuthenticationHandler Management.

+ (id <DTAuthenticationHandler>)defaultAuthenticationHandler
{
	id <DTAuthenticationHandler> result = nil;
	
	@synchronized ( self )
	{
		result = [[DTRESTCommandDefaultAuthenticationHandler retain] autorelease];
	}
	
	return result;
}

+ (void)setDefaultAuthenticationHandler:(id <DTAuthenticationHandler>)newDefaultHandler
{
	@synchronized ( self )
	{
		if ( DTRESTCommandDefaultAuthenticationHandler == newDefaultHandler )
			return;
		
		[DTRESTCommandDefaultAuthenticationHandler release];
		DTRESTCommandDefaultAuthenticationHandler = [newDefaultHandler retain];
	}
}

// MARK: 
// MARK: Session Management

+ (id <DTSession>)defaultSession
{
	id <DTSession> result = nil;
	
	@synchronized ( self )
	{
		result = [[DTRESTCommandDefaultSession retain] autorelease];
	}
	
	return result;
}

+ (void)setDefaultSession:(id <DTSession>)newDefaultSession
{
	@synchronized ( self )
	{
		if ( DTRESTCommandDefaultSession == newDefaultSession )
			return;
		
		[DTRESTCommandDefaultSession release];
		DTRESTCommandDefaultSession = [newDefaultSession retain];
	}
}

// MARK: 
// MARK: TRanslating the result from JSON to NSDictionary

/**
 @todo We definitely should handle errors here and return any error using a pointer to a reference as parameter. (stherold - 2012-07-24)
 */

- (NSDictionary*)translateJSONData:(NSData *)jsonData
{	
	// --- don't start do translate json if an error has already been set.
	if( self.error )
		return nil;
	
	//
	// Parse JSON.
	//

	NSString * const receivedDataAsString = [[[NSString alloc] 
                                              initWithData:jsonData 
                                              encoding:DTRestCommandDefaultStringEncoding] autorelease];

	NSError *jsonError = nil;
	NSDictionary * jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
																	options:NSJSONReadingMutableContainers
																	  error:&jsonError];

	// --- in some cases e.g. token not valid, objectFromJSON may be nil
	if ( !jsonDictionary || ![jsonDictionary isKindOfClass:[NSDictionary class]] ) {
		return nil;
	}
	
	if ( jsonError )
	{
		// IMPORTANT HINT
		//
		// Don't set the error to the command's error because this can cause 
		// downward-compatibility problems with the proxy. That means if 
		// they change something in the proxy, older versions of this app 
		// with self.error set can't run properly.	
		
		DT_LOG( 
			   @"BACKEND", 
			   @"Failed with error\n\n%@\n\nwhile parsing\n\n%@\n\nas a result of "
			   "the request\n\n%@.",
			   jsonError, 
			   receivedDataAsString,
			   self );	
	}

	DT_LOG(@"JSON_RESPONSE_DIC", @"Dictionary: %@", jsonDictionary);
	
	return jsonDictionary;
}

- (void) handleAuthorizationError:(NSError*)error
{
    DT_ASSERT(nil, @"Need to be overwritten by sublass");
}

@end