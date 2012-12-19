//
//  MCErrorHandler.h
//  MedienCenter
//
//  Created by said.el-mallouki on 2009-09-03.
//  Copyright 2009 mallouki.de. All rights reserved.
// 

#import <Foundation/Foundation.h>

// DTFoundation - Errors.
#import "DTError.h"

// DTFoundation - Strings.
#import "DTStrings.h"

/**
 @todo Mask: Sending notifications, calling handleError:delegate: of
 UIApplicationDelegate. (stherold - 2012-07-24)
 */

/*!
	\brief Singleton dedicated to handle errors.
*/
@interface DTErrorHandler : NSObject 
{
} 

#pragma mark
#pragma mark NSObject: Creating, Copying, and Deallocating Objects

/*!
	\brief Allocates the singleton instance.
*/
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;

#pragma mark 
#pragma mark 
#pragma mark NSObject: Managing Reference Counts

- (id)autorelease;
- (void)release;
- (id)retain;
- (NSUInteger)retainCount;

#pragma mark
#pragma mark
#pragma mark Getting the Shared Error Handler

+ (DTErrorHandler *)sharedErrorHandler;

#pragma mark
#pragma mark 
#pragma mark Handling Errors

/*!
	\brief Handles the error, possibly showing an alert view with a title and
		a message based on the information based on the provided error.
	\param error An NSError object describing the error to be handled.
	\param delegate A UIAlertViewDelegate compliant object used as delegate for
		the possibly displayed alert view.
	
	This implementation determines if the application's delegate corresponds
	to the selector <tt>handleError:delegate:</tt> taking the same parameters as
	this method. If so, this method is called with the \c error and \c delegate
	as parameters.
*/
- (void)handleError:(NSError *)error 
			delegate:(id)delegate;

/*!
 \brief Will show an errordialog within the given view.
 \details If an error occurs the Title and Description will be extracted from 
	the Localized Strings file and displayed within a view overlay in the application.
	The Errorhandler will add a view to the viewController and mask the given view
	with an overlay while the dialog is active.
 \param anError The error to handle.
 */
-(void)handleError:(DTError *)anError inView:(UIViewController *)aView;

@end