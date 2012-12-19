//
//  DTGeometry.m
//  DTLibrary
//
//  Created by Pierre Bongen on 28.10.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "DTGeometry.h"

// DTLibrary - Utilities.
#import "DTDebugging.h"



CGRect DTRectFramedInContainerRect( CGRect const rect, CGRect const containerRect, 
	BOOL const shrinkOnly )
{
	CGRect result = CGRectZero;

	//
	// Check parameters.
	//
	
	if ( 
		0.0 >= rect.size.width
		|| 0.0 >= rect.size.height )
	{
		return result;
	}

	//
	// Scale rect if necessary.
	//
	
	CGFloat widthOfRect = rect.size.width;
	CGFloat heightOfRect = rect.size.height;

	if ( 
		widthOfRect > containerRect.size.width
		|| heightOfRect > containerRect.size.height
		|| !shrinkOnly )
	{
		CGFloat const horizontalRatio = containerRect.size.width / widthOfRect;
		CGFloat const verticalRatio = containerRect.size.height / heightOfRect;
		
		if ( horizontalRatio < verticalRatio )
		{
			widthOfRect = containerRect.size.width;
			heightOfRect *= horizontalRatio;
		}
		else
		{
			widthOfRect *= verticalRatio;
			heightOfRect = containerRect.size.height;
		}
	}

	//
	// Compute base frame.
	//
	//		The base frame is centred within the view's bounds if it is smaller.
	//
	
	result = CGRectMake(
		containerRect.origin.x + 0.5 * ( containerRect.size.width - widthOfRect), 
		containerRect.origin.y + 0.5 * ( containerRect.size.height - heightOfRect ),
		widthOfRect, 
		heightOfRect );
	
	return result;
}

CGRect DTRectFittedInContainerRect( CGRect const rect, CGRect const containerRect,
	BOOL const shrinkOnly )
{
	CGRect result = CGRectZero;

	//
	// Check parameters.
	//
	
	if ( 
		0.0 >= rect.size.width
		|| 0.0 >= rect.size.height )
	{
		return result;
	}

	//
	// Scale rect if necessary.
	//
	
	CGFloat widthOfRect = rect.size.width;
	CGFloat heightOfRect = rect.size.height;

	if ( 
		widthOfRect > containerRect.size.width
		|| heightOfRect > containerRect.size.height
		|| !shrinkOnly )
	{
		CGFloat const horizontalRatio = containerRect.size.width / widthOfRect;
		CGFloat const verticalRatio = containerRect.size.height / heightOfRect;
		
		if ( horizontalRatio > verticalRatio )
		{
			widthOfRect = containerRect.size.width;
			heightOfRect *= horizontalRatio;
		}
		else
		{
			widthOfRect *= verticalRatio;
			heightOfRect = containerRect.size.height;
		}
	}

	//
	// Compute base frame.
	//
	
	result = CGRectMake(
		containerRect.origin.x + 0.5 * ( containerRect.size.width - widthOfRect), 
		containerRect.origin.y + 0.5 * ( containerRect.size.height - heightOfRect ),
		widthOfRect, 
		heightOfRect );
	
	return result;
}