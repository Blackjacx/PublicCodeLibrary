//
//  DTGeometry.h
//  DTLibrary
//
//  Created by Pierre Bongen on 28.10.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <UIKit/UIKit.h>



/*!
	\name Working with Rectangles
	
	@{
*/

/*!
	\brief Computes the scaled version of a rectangle framed by a container
		rectangle preserving its aspect ratio.
	\param rect The rectangle whose scaled version is to be computed.
	\param containerRect The rectangle of the container by which \c rect should
		be framed.
	\param shrinkOnly If \c YES \c rect is not upscaled if it is smaller than
		\c containerRect.
	\return The scaled frame. If \c rect has a zero width or height 
		\c CGRectZero is returned. If \c rect fits into \c containerRect the
		returned rect is \c rect centred witin \c containerRect.
*/
CGRect DTRectFramedInContainerRect( 
	CGRect const rect, 
	CGRect const containerRect,
	BOOL const shrinkOnly );

/*!
	\brief This function places \c rect centred into \c containerRect, 
		downscaling if necessary keeping the aspect ratio of \c rect, filling
		\c containerRect entirely.
*/
CGRect DTRectFittedInContainerRect( CGRect const rect, CGRect const containerRect,
	BOOL const shrinkOnly );

//!@}