//
//  DTActivityView.h
//  MedienCenter
//
//  Created by Said El Mallouki on 20.12.10.
//  Copyright 2010 mallouki.de. All rights reserved.
//

#import "DTViewBackground.h"

/*!
 \brief Displays an activity indicator with an information text.
 */
@interface DTActivityView : UIView 
{
@private
	//
	// Configuration.
	//
	
	NSString * infoText;
	
	//
	// Views.
	//
	
	UIActivityIndicatorView * activityIndicator;
	UILabel * infoTextLabel;
	DTViewBackground * viewBackground;

	//
	// Parent view reference.
	//
	
	__weak UIView * parentView;
}

// MARK: 
// MARK: Initialisation

/*!
 \brief Creates an instance using the default text with or without setting 
	the custom background as specified by the background parameter.
 \param aParentView The view into which this view will be added
 \param aBackgroundFlag If \c YES the DTViewBackground is used as background
	for this view hiding the views below.
*/
-(id)initWithParentView:(UIView*)aParentView opaque:(BOOL)aBackgroundFlag;

/*!
 \brief Creates an instance using the given custom text with or without setting 
 the custom background as specified by the background parameter.
 \param aParentView The view into which this view will be added
 \param aCustomText the custom Text to show
 \param aBackgroundFlag If the DTViewBackground should be used. 
 */
-(id)initWithParentView:(UIView *)aParentView 
			 customText:(NSString *)aCustomText 
	  opaque:(BOOL)aBackgroundFlag;

// MARK: 
// MARK: Configuring the Activity View

@property ( nonatomic, copy ) NSString *infoText;

-(void)setOpaque:(BOOL)aFlag;

// MARK: 
// MARK: Setting and Getting the Parent View

/*!
	\name Setting and Getting the Parent View
	
	The parent view will be hidden and visually replaced by the activity view.
	
	@{
*/

@property ( nonatomic, assign ) UIView *parentView;

//!@}

// MARK: 
// MARK: Showing and Hiding

/*!
 \brief Adds this view to the given ParentView and centers it.
 */
-(void)show;

/*!
 \brief Removes this view from the given ParentView.
 \remarks The view can be used again, unless released by the user.
 */
-(void)hide;

@end
