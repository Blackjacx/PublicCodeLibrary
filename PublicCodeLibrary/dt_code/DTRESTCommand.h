//
//  DTRestCommand.h
//  DTLibrary
//
//  Created by stefan herold on 11.07.09.
//  Copyright 2009 Deutsche Telekom AG. All rights reserved.
//

#import "DTSession.h"
#import "DTStrings.h"
#import "DTAuthenticationHandler.h"

/*!
	@name Global Public Contants
	{
*/
		
// MARK: 
// MARK: Global Public Contants

extern NSStringEncoding const DTRestCommandDefaultStringEncoding;

//! }


@protocol DTRESTCommandProgressDelegate;
@protocol DTRESTCommandDelegate;


/*!
	\name Error Domains
	
	@{
*/

// MARK: 
// MARK: Error Domains

DT_DECLARE_KEY( DTHTTPErrorDomain );

//!@}



// MARK: 
// MARK: Errors

/*!
	\name Errors
	
	@{
*/

typedef enum _DTRESTCommandErrorCode {
	DTRESTCommandErrorCodeNoError 								= 0,
	DTRESTCommandErrorCodeDidFailToCreateURLRequest				= 900000,
	DTRESTCommandErrorCodeTechnicalUserTokenMissing				= 900001,
	DTRESTCommandErrorCodeUserTokenMissing						= 900002,
	DTRESTCommandErrorCodeUserTokenNotAnNSString				= 900003
} DTRESTCommandErrorCode;

//!@}



// MARK: 
// MARK: -
// MARK: 

/*!
	\brief Superclass of concrete REST commands.
	\see DTSession
	
	\section DTRESTCommand_Overview Overview
	
	This class implements the basic logic needed to communicate with a service 
	addressable using an URL. DTBasicRestCommand was developed with using REST
	services in mind but may be used for any kind of services (SOAP, custom, 
	non-HTTP etc.).
	
	Under the hood the <em>URL Loading System</em> is used. If desired, the
	NSURLConnection is added to a run-loop of a thread of its own.
	
	If a command finishes an arbitrary object can optionally be notified using
	the <em>Target-Action</em> pattern. The notified object may then use the
	#result and #error properties to determine the command's outcome.
	
	\section DTRESTCommand_Sessions Sessions
	
	The command is bound to a session object conforming to the DTSession 
	protocol from which it may obtain necessary tokens and endpoint URLs. A 
	default session object can be set using the #setDefaultSession: class 
	method. The default session is then used if no explicit session is given on
	initialisation.
	
	\section DTRESTCommand_GeneralSubclassingNotes General Subclassing Notes
	
	If you subclass DTBasicRestCommand you will likely override the following 
	methods:

	- #processReceivedData:

	It may make sense in some situations not to override #processReceivedData:
	for instance when the desired effect is achieved by simply sending the
	request to the service endpoint. This behaviour should be rare, though.
	
	Besides the necessity of overriding the methods mentioned above you must
	invoke #setURLWithRoot:path:parameters: at least once before the command is
	executed in order for the command object to function properly.

	\section DTRESTCommand_CachingSupport Caching Support
	
	Communicating using the network may be a time and energy consuming process
	for mobile devices like the iPhone. The DTBasicRestCommand supports caching
	of formerly received results.
	
	For caching to work properly, you need to override the following methods:
	
	- #cachedResult
	
	You should override the following methods, too:
	
	- #invalidateCachedResult
	
	The command object can be set up to behave differently if there is a cache 
	hit or miss during its execution. See the #finishesOnCacheHit and
	#cancelsOnCacheMiss properties.
*/

@interface DTRESTCommand : NSObject 

//! @brief Defines the percentage of uploaded bytes
@property(nonatomic, assign)CGFloat percentageLoaded;
@property(nonatomic, assign)BOOL cancelling;
@property(nonatomic, assign)id <DTAuthenticationHandler> authenticationHandler;
@property(nonatomic, retain)NSCondition * terminationCondition;

@property (retain, readonly)NSHTTPURLResponse *URLResponse;

@property (assign)id<DTRESTCommandDelegate> delegate;
@property (assign)id<DTRESTCommandProgressDelegate> progressDelegate;

//! @see authenticationRequired()
@property ( nonatomic, assign, readonly ) BOOL authenticationRequired;

@property ( nonatomic, retain ) id <DTSession> session;
@property ( nonatomic, copy, readonly ) NSString *identifier;
@property ( retain, readonly ) NSThread * callingThread;

@property ( nonatomic, copy, readonly ) NSURL *URL;
@property ( nonatomic, retain, readonly ) NSURLConnection * URLConnection;

@property ( nonatomic, readonly) NSMutableData * receivedData;

/**
 @todo Put this into the .m file to make it invisible. Therefore processReceivedData must be adapted! (stherold - 2012-07-24)
 */

@property(nonatomic, readonly) NSString * receivedDataAsString;

/*!
	\brief Set to an NSError object if an error occurred during the execution of
		the command.
*/
@property ( nonatomic, retain ) NSError *error;

/*!
	\brief Holds the result after execution.
*/
@property ( nonatomic, retain ) id result;

@property ( assign, readonly, getter=isCanceled ) BOOL canceled;
@property ( assign, readonly, getter=isExecuting ) BOOL executing;
@property ( assign, readonly, getter=isFinished ) BOOL finished;
@property ( assign, readonly, getter=isFailed ) BOOL failed;

/*!
	\brief If set to \c YES and the cache has been hit the command stops 
		its execution and finishes.

	The default is \c NO.
*/
@property ( assign ) BOOL finishesOnCacheHit;

/*!
	\brief If set to \c YES and the cache has been missed the command is 
		cancelled.
	
	If set to \c YES the command's client has the chance to soley use the 
	command to access any results residing in the command's cache without 
	triggering an asynchronous execution if the cache is empty for this command.
	
	The default value of this property is \c NO.
*/
@property ( assign ) BOOL cancelsOnCacheMiss;

@property ( assign, readonly ) BOOL hitCache;
@property ( assign, readonly, getter=isScheduledForExecution ) BOOL scheduledForExecution;

@property ( assign ) BOOL task; // Task Command send DTtaskNotifications

// MARK: 
// MARK: Initialisation

/*!
	\name Initialisation
	
	@{
*/

/*!
	\brief Designated initializer.
	\param aSession A session in whose context the command is to  be executed.
		If \c nil the default session is used. If no default session is set then
		an exception is thrown.
    \param anAuthenticationHandler An authentication handler which modifies
        the command's request before it is performed.
	\param aDelegate The class implementing the DTRESTCommandDelegate protocol to receive
		callbacks from this command.
*/
- (id)initWithSession:(id <DTSession>)aSession 
authenticationHandler:(id<DTAuthenticationHandler>)anAuthenticationHandler 
		  delegate:(id<DTRESTCommandDelegate>)aDelegate;

//!@}

// MARK: 
// MARK: Executing the Command

/*!
	\name Executing the Command
	
	Commands may be executed on the current thread using the #execute method or 
	on a thread of their own using #executeInBackground.
	
	Commands that have once been executed may be re-used using the #reset 
	and #reexecute methods.
	
	@{
*/

/*!
	\brief Executes the receiver asynchronously.

	If not called on the main thread, the target's action method is guaranteed 
	to be called on the main thread.
*/ 
- (void)execute;

/*!
 \brief Re-executes the command.
 
 This is a convenience method which calls #reset and #executeInBackground.
 */
- (void)reexecuteInBackground;

/*!
	\brief Executes the receiver in a thread of its own.
	
	Commands executed in the background will not be marked finished when 
	returning from this method, even on a cache hit. Commands executed this way
	are truly asynchronous and the target's action-method will be called. The
	#finishesOnCacheHit property has no effect.
	
	The target's action method is guaranteed to be called on the main thread.
*/
- (void)executeInBackground;

/*!
	\brief Re-executes the command.
	
	This is a convenience method which calls #reset and #execute.
*/
- (void)reexecute;

/*!
	\brief Resets the command.

	Sets the #canceled and #finished properties to \c NO and the #result and
	#error properties to \c nil so that the command can basically be re-used.
	
	Subclasses may want to override this method in a fashion that suits them to
	provide a perfect reset. If they do so they must call super's 
	implementation.
*/
- (void)reset;

//!@}

// MARK: 
// MARK: Handling Network Activity

/*!
	\name Handling Network Activity
	
	@{
*/

+ (void)updateNetworkIndicator;
+ (void)disableNetworkIndicator;
+ (void)enableNetworkIndicator;

//!@}

// MARK: 
// MARK: Finishing the Command

/*!
	\name Finishing the Command
	
	@{
*/

/*!
	\brief Cancels the comand.
*/ 
- (void)cancel;

/*!
	\brief Cancels the comand with the option to notify the delegate.
*/ 
- (void)cancelAndNotifyDelegate:(BOOL)notifyDelegate;

/*!
	\brief Finishes the command sometimes later.
	\remarks This method is used in situations when the command should actually
		be regarded as finished (i.e. due to a cache hit) but should behave as
		if it is still being executed so that the delegate methods still get 
        called. This prevents possibly redundant implementations of code that 
        handles the command's result.
*/
- (void)deferredFinish;

/*!
	\brief Marks the command as finished.
	
	A possibly open URL connection is closed and the target if set is notified
	through a call of the action method with the receiver as the only parameter.
*/
- (void)finish;

//!@}

// MARK: 
// MARK: Determining the Command's Result

/*!
	\name Determining the Command's Result
	
	@{
*/

/*!
	\brief Checks a possibly used cache for a result for this call.
	\return The cached result or \c nil if there is none. The returned object
		is of the same kind as returned by #processReceivedData:.
*/
- (id)cachedResult;

/*!
	\brief Invalidates possibly existing cache entries affected by the receiver.
	
	Subclasses should override this method in case the support the caching of
	their results.
*/
- (void)invalidateCachedResult;

/*!
	\brief Processes the received data and returns the result of receiver.
	\return An object as appropriate for the command.
	\remarks Overriden implementations may want to set the #error property if
		\c data's content is unexpected or erronous.
 */ 
- (id)processReceivedData:(NSData *)data;

- (NSData *)receivedData;

/*!
 \brief Determines if the received HTTPStatusCode is considered to be an error.
 \return NO if the httpStatusCode is 200,201 or 202 otherwise return YES
 \remarks Can be overridden by subclasses to classify statusCodes differntly. 
 \c The base class' implementation only considers 200,201 and 202 a valid response code.
 \c Only statusCodes that return YES here will lead to the invocation of the checkReceivedStringObjectForError method below.
 */ 
-(BOOL)isHTTPError;

/*!
	@brief Sets the commands error object if the comamand failed.
	@remarks Should be overridden by the subclass to set specific errors. The 
 created NSError has to be set to the error property of the class and will be
 used to determine the delegate callback in the command's finish method.
 @param receivedDataAsString The received data converted into a string object.
 */ 
- (void)checkReceivedStringObjectForError:(NSString *)receivedDataAsString;

//!@}

// MARK: 
// MARK: Setting Up Credentials

/*!
	\name Setting Up Credentials
	
	@{
*/

/*!
 \brief Controls if authentication is required or not.
 \return Returns \c NO by default.
 \see #setCredentialsOfRequest:error:
 
 The #setCredentialsOfRequest:error: method uses this method to determine if
 it should set the credentials.
 
 Derived classes should override this method if they need authentication.
 */
- (BOOL)authenticationRequired;

/*!
	\brief Sets the authentication header field of the given request.
	\param request The request whose authentication header field is to be set.
	\param error An optional pointer to a NSError reference. Potentially set on 
		errors.
	\return Returns \c YES on success, \c NO on errors.
	\see DTSession, #authenticationRequired, 
		#technicalUserAuthenticationSuffices, #session.
	
	This method uses the associated DTSession conforming session object to 
	create the value of the authentication header field.
		
	If the required token was not provided by the session object the header 
	fields remain untouched and an error is returned. 
*/
- (BOOL)setCredentialsOfRequest:(NSMutableURLRequest *)request error:(NSError **)error;

//!@}

// MARK: 
// MARK: Obtaining the Command's URL Request

/*!
	\brief Returns the URL request used by the receiver.

	This method uses the currently set URL to create a mutable HTTP URL request 
	object. The following HTTP header fields are set:
	
	- <b><tt>Accept-Encoding</tt></b> is set to \c gzip.
	- <b><tt>User-Agent</tt></b> is set to the value of the \c USER_AGENT
		constant.
	- <b><tt>Accept</tt></b> is set to <tt>application/json</tt>.
	
	The method used by the request is set to \c GET by default.
	
	Derived classes are encouraged to call the implementation of \c super.
*/ 
- (NSMutableURLRequest *)URLRequest;

/*!
 \brief adds required headers.
 \details The Concrete RestCommand class can set additional headers to the request
	by overriding this method. Defautl implementation sets the Accept Header to
	\c application/json. Other implementations might need different headers. 
	E.g. a download request for an image will not use json
 */

-(void)setAdditionalHeadersForRequest:(NSMutableURLRequest *)aRequest;


// MARK: 
// MARK: Working With the Command's URL

- (void)setURLWithRoot:(NSString *)root path:(NSString *)path parameters:(NSDictionary *)parameters;

/*!
	\brief Sets the URL property.
	\param root The root containing a protocol, host and optionally a path (with
		a trailing slash).
	\param path An optional additional path to the REST service.
	\param parameters A dictionary containing URL parameters. The keys are the
		names of the parameters, the values are string representations of the
		parameter values. The string representations of the values will be 
		escaped in order to obtain a valid URL.
	\param sequence An optional array defining the sequence of
		parameters appended to the URL.
*/
- (void)setURLWithRoot:(NSString *)root path:(NSString *)path parameters:(NSDictionary *)parameters sequenceOfParameters:(NSArray *)sequence;

/*!
	\brief Returns the URL used for this call excluding the scheme and domain
		parts.
	\remarks Used for debugging purposes in the wild.
*/
- (NSString *)URLRestServiceComponentsAsString;

/*!
	\brief Composes a URL string.
	\see #setURLWithRoot:path:parameters:sequenceOfParameters:.
*/
+ (NSString *)URLAsStringWithRoot:(NSString *)root path:(NSString *)path parameters:(NSDictionary *)parameters
	sequenceOfParameters:(NSArray *)sequence;

// MARK: 
// MARK: Managing REST Commands

/*!
	\name Managing REST Commands
	
	@{
*/

/*!
	\brief Adds the given command to the list of executed commands.
	\param command The command to be added.
	
	The network activity indicator is set to be visible if the executed command
	has been added to the list of executed commands.
*/
+ (void)addExecutedCommand:(DTRESTCommand *)command;

+ (void)addScheduledCommand:(DTRESTCommand *)command;

/*!
	\brief Cancels the given command.
	\param command The command to be cancelled.
	
	The command's target is not notified.
*/
+ (void)cancelCommand:(DTRESTCommand *)command;

+ (void)cancelAllCommands;

/*!
	\brief Removes the given command from the list of executed commands.
	\param command The command to be removed.
	
	The network activity indicator is hidden if the list of executed command is
	empty after the command has been removed from it.
*/
+ (void)removeExecutedCommand:(DTRESTCommand *)command;

+ (void)removeScheduledCommand:(DTRESTCommand *)command;

//!@}


// MARK: 
// MARK: AuthenticationHandler Management

+ (id <DTAuthenticationHandler>)defaultAuthenticationHandler;
+ (void)setDefaultAuthenticationHandler:(id <DTAuthenticationHandler>)newDefaultHandler;


// MARK: -
// MARK: Session Management

/*!
	\brief Returns the currently set default session.
	\return The currently set default session or \c nil if there is no such
		session.
	\see #setDefaultSession:
	
	This method is thread safe.
*/
+ (id <DTSession>)defaultSession;

/*!
	\brief Sets the default session.
	\param newDefaultSession The new default session for subsequent commands or
		\c nil if there should be no default session.
	\see #defaultSession
	
	This method is thread safe.
*/
+ (void)setDefaultSession:(id <DTSession>)newDefaultSession;

/*!
 @brief Translates the received data from backend to a NSDictionary object.
 @param jsonData Received JSON data from backend.
 @return The translated NSDictionary or \c nil if any error occurrs.
 */
- (NSDictionary*)translateJSONData:(NSData *)jsonData;

@end


@protocol DTRESTCommandProgressDelegate < NSObject>

// MARK: Handling Progress

/*!
 \brief called when a command has uploaded a chunk of data to the server.
 \param command The DTRESTCommand based class that was executed.
 \param percent The transferred percentage of the overall data to transfer to the server.
 \remarks This delegate method should be used to display progress indicators 
 when uploading files
 \note The percent parameters is \b not in the interval 
 <tt>[0.0 .. 100.0]</tt> as implied by its name. In fact, its value is
 in the interval <tt>[0.0 .. 1.0]</tt> with \c 0.0 meaning 
 <em>no progress</em> and \c 1.0 meaning <em>finished</em>.
 */
-(void)restCommand:(DTRESTCommand *)command didUploadPercentage:(float)percent;
/*!
 \brief called when a command has SCHEISS COPY & PASTE MANN! uploaded a chunk of data to the server.
 \param command The DTRESTCommand based class that was executed.
 \param percent The transferred percentage of the overall data to download from the server.
 \remarks This delegate method should be used to display progress indicators 
 when downloading files.  
 \note The percent parameters is \b not in the interval 
 <tt>[0.0 .. 100.0]</tt> as implied by its name. In fact, its value is
 in the interval <tt>[0.0 .. 1.0]</tt> with \c 0.0 meaning 
 <em>no progress</em> and \c 1.0 meaning <em>finished</em>.
 */
-(void)restCommand:(DTRESTCommand *)command didDownloadPercentage:(float)percent;

/*!
 \brief called when a command finished transferring data. Either with or without error.
 \param command The DTRESTCommand based class that was executed.
 \remarks This is used, to indicate the completion of transfer to a progress delegate
 without distinguishing between up- and downloads or error condition. 
 */
-(void)restCommandDidFinishTransfer:(DTRESTCommand *)command;

@end;



@protocol DTRESTCommandDelegate < NSObject>

// MARK: 
// MARK: Command Completion
@optional

/*!
 \brief called when a command finished with the error property set during execution.
 \param command The DTRESTCommand based class that was executed.
 \param error The NSEror object created in one of the errorHandling methods of the DTRESTCommand.
 \remarks NSEror Objects can be created by generic error handlers such as
 the URLConnections   delegate or by the customizable error handler
 - (void)checkReceivedStringObjectForError:(NSString *)receivedDataAsString, which can be overridden to create an application specific error Object.
 */
-(void)restCommandDidFail:(DTRESTCommand *)command withError:(NSError *)error;
/*!
 \brief called when a command finished successfully and the error property was not set during execution.
 \param command The DTRESTCommand based class that was executed.
 \remarks The DTRESTCommands subclass has to deal with the payload returned by the call by 
 \c overriding the didReceiveResponse method. The result will not be passed as a parameter
 \c but has to be retrieved using the subclasses' specific property.
 */
-(void)restCommandDidSucceed:(DTRESTCommand *)command;
/*!
 \brief called when a command was canceled by the user.
 \param command The DTRESTCommand based class that was executed.
 */
-(void)restCommandDidCancel:(DTRESTCommand *)command;

/*!
 \brief 
 \param 
 \param 
 */
-(void)restCommandDidSucceedFromCache:(DTRESTCommand *)command withCacheObject:(id) objectFromCache;

@end