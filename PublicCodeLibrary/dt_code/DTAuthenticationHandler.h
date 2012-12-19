/*!
 \file		
 \brief		Interace for Authenticationhandlers by manipulating NSURLRequests
 \details  Implement to support various types of authentications.
 \attention Copyright 2010 Deutsche Telekom AG. All rights reserved.
 \author	Said El Mallouki
 \date		2010-11-26
 */#import <UIKit/UIKit.h>
#import "DTSession.h"
/*!
	\brief Interface to handle authentication by setting additional headerfields,
		parameters or whatever is required on the given URLRequest object.
	\details This interface can be implemented to support any kind of authentication
		required for a specific application. (Basic-Auth, STSToken Auth, OAuth..) 
*/
@protocol DTAuthenticationHandler<NSObject>

/*!
	\brief Takes the given request and sets header values, cookies or parameters
		to enable authenticated communication with a server.
	\details The given session object should contain all required information
		to authenticate the request. 
	\param request The request to prepare for authenticated communication with a backend.
	\param session The session containing required authentication information like
		sessionID, cookie values etc.
	\param error If sth does not work as expected the error object will be initialized
		with an appropriate errorId and message. 
	\returns YES if the authentication was successfull NO otherwise
*/
-(BOOL)setCredentialsForRequest:(NSMutableURLRequest *)request 
					withSession:(id<DTSession>)session
					   andError:(NSError**)error;

@end

