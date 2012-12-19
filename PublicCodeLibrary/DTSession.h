//
//  DTSession.h
//  IphoneEPG
//
//  Created by Pierre Bongen on 02.02.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "DTSTSToken.h"

/*!
	\brief Declares the methods a session object must implement at a minimum.
	
	Other classes working with session objects expect the methods declared by
	this protocol to be implemented in concrete subclasses.
*/
@protocol DTSession < NSObject >
@required
// MARK: -
// MARK: Obtaining Endpointsl
/*!
	\brief Returns the URL of the endpoint to be used to access to
		the service either to get further discovery information, or to authenticate.
	\details Further endpoints might be needed and have to be provided by the 
		specific Session implementation.
	\return The URL of the initial endpoint or \c nil if there is no such
		endpoint.
	\note The implementation of this method is expected to be thread safe.
*/
+(NSURL *)URLForInitialServiceEndpoint;


// MARK: -
// MARK: Session Data

/*!
	\brief Returns the sessionId associated with the user.
	\details The sessionid can be of any type. It can also be a token of any kind. 
		Whatever identifier is applicable for the specific app implementing this protocol.
	\return The sessionid associated to the session.
*/
- (id)sessionID;
- (void)setSessionID:(id)aSessionID;


@optional
/*!
	\brief Returns the username if the session is associated to a user.
	\return The username or \c nil if the session is currently not associated
		to a particular user which may be the case for anonymous sessions.
*/
- (NSString *)username;
-(void)setUsername:(NSString *)aUsername;

@end