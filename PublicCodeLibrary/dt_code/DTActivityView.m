//
//  DTActivityView.m
//  DTLibary
//
//  Created by Said El Mallouki on 20.12.10.
//  Copyright 2010 mallouki.de. All rights reserved.
//

#import "DTActivityView.h"
#import "DTActivityView_private.h"

// DTLibrary - Utilities.
#import "DTDebugging.h"
#import "DTStrings.h"

@implementation DTActivityView

// MARK: 
// MARK: NSObject: Creating, Copying, and Deallocating Objects

- (void)dealloc 
{
	[self->infoText release], self->infoText = nil;
	[self->infoTextLabel release], self->infoTextLabel = nil;
	[self->viewBackground release], self->viewBackground = nil;

    [super dealloc];
}

// MARK: 
// MARK: Initializers

- (id)initWithParentView:(UIScrollView*)aParentView opaque:(BOOL)aBackgroundFlag
{
	return [self 
		initWithParentView:aParentView
		customText:nil
		opaque:aBackgroundFlag];
}

- (id)initWithParentView:(UIScrollView *)aParentView 
			 customText:(NSString *)aCustomText 
	  opaque:(BOOL)aBackgroundFlag
{
	if ( (self = [super initWithFrame:aParentView.bounds]) )
	{
		self.opaque = aBackgroundFlag;
		self->parentView = aParentView;
		self->infoText = [aCustomText copy];
		
		[self initComponents];
	}
	return self;
}

// MARK: 
// MARK: Setting and Getting the Parent View

- (UIView *)parentView
{
	return self->parentView;
}

- (void)setParentView:(UIView *)newParentView
{
	//
	// Check parameter.
	//
	
	DT_ASSERT_RETURN( 
		!newParentView || [newParentView isKindOfClass:[UIScrollView class]],
		@"Expected %@ parameter to be kind of class UIScrollView.",
		DT_STRINGIFY( newParentView ) );
	
	//
	// Check state.
	//

	if ( newParentView == self->parentView )
	{
		return;
	}

	//
	// Set new parentView.
	//
	
	// --- Hide self if shown.
	
	BOOL const wasShown = self.superview ? YES : NO;
	
	if ( wasShown )
	{
		[self hide];
	}
	
	self->parentView = newParentView;
	
	if ( wasShown && self->parentView )
	{
		[self show];
	}
}

// MARK: 
// MARK: Configuring the Activity View

- (void)setInfoText:(NSString *)anInfoText
{
	if ( anInfoText == self->infoText )
	{
		return;
	}
	
	[self->infoText release];
	self->infoText = [anInfoText copy];
	
	self->infoTextLabel.text = self.infoText;
}

- (NSString *)infoText
{
	return self->infoText;
}

- (void)setOpaque:(BOOL)aFlag
{
	[super setOpaque:aFlag];
	
	[self toggleBackgroundViewTo:aFlag];
}

// MARK: -
// MARK: Showing and hiding the view.

-(void)show
{
	//
	// Check state.
	//
	
	[self setNeedsLayout];

	if ( 
		self.superview && 
		NSNotFound != [self.superview.subviews indexOfObjectIdenticalTo:self->parentView] )
	{
		return;
	}

	//
	// Show activity view.
	//

	[self setParentControllerScrollingToDisabled:YES];
	[self->activityIndicator startAnimating];
	self->parentView.hidden = YES;
	[[self->parentView superview] addSubview:self];
}

- (void)hide
{
	//
	// Hide activity view.
	//

	[self->activityIndicator stopAnimating];

	NSUInteger const indexOfParentView = [[[self superview] subviews] 
		indexOfObjectIdenticalTo:self->parentView];

	if ( NSNotFound != indexOfParentView )
	{
		self->parentView.hidden = NO;
		[self setParentControllerScrollingToDisabled:NO];
	}

	[self removeFromSuperview];
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	CGFloat const infoLabelHeight = 20.0;
	
	[self->activityIndicator setCenter:CGPointMake(
												   ceilf(0.5f * self->parentView.bounds.size.width), 
												   ceilf(infoLabelHeight 
														 + 0.5f * self->activityIndicator.frame.size.height) )];
	
	// Always show above the full frame of the parent view
	self.frame = self->parentView.frame;
	// Always show in the center of the parent view.
	self->viewBackground.frame = self.bounds;
	// Set the activity indicator right above the center
	self->activityIndicator.center = self.center;
	// set the label below the activity indicator and size it to the full width of the view.
	
	self->infoTextLabel.frame = CGRectMake(
										   0.0f,
										   ceilf(self->parentView.bounds.size.height/2.0f + infoLabelHeight/2.0f),
										   ceilf(self->parentView.bounds.size.width),
										   ceilf(infoLabelHeight));
}

@end



// MARK: 
// MARK: -
// MARK: 

@implementation DTActivityView ( DTPrivate )

-(void)setParentControllerScrollingToDisabled:(BOOL)disabled
{
	if ([self->parentView isKindOfClass:[UITableView class]]) 
	{
		((UITableView *)self->parentView).scrollEnabled = !disabled;
	}	
}

-(void)toggleBackgroundViewTo:(BOOL)used
{
	if (used && ![self.subviews containsObject:self->viewBackground])  
	{
		[self addSubview:self->viewBackground];
		[self sendSubviewToBack:self->viewBackground];
	}
	else if (!used && [self.subviews containsObject:self->viewBackground])
	{
		[self->viewBackground removeFromSuperview];
	}
}

-(void)initComponents
{
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth
	| UIViewAutoresizingFlexibleHeight
	| UIViewAutoresizingFlexibleTopMargin
	| UIViewAutoresizingFlexibleRightMargin
	| UIViewAutoresizingFlexibleBottomMargin
	| UIViewAutoresizingFlexibleLeftMargin;
	
	self->infoTextLabel = [[UILabel alloc] init];
	self->infoTextLabel.text = self->infoText;
	self->infoTextLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
	| UIViewAutoresizingFlexibleRightMargin
	| UIViewAutoresizingFlexibleBottomMargin
	| UIViewAutoresizingFlexibleLeftMargin;
	self->infoTextLabel.textAlignment = NSTextAlignmentCenter;
	self->infoTextLabel.textColor = [UIColor whiteColor];
	self->infoTextLabel.backgroundColor = [UIColor clearColor];
	self->infoTextLabel.font = [UIFont systemFontOfSize:12];
	
	self->activityIndicator = [[UIActivityIndicatorView alloc] 
		initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	self->activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
	| UIViewAutoresizingFlexibleRightMargin
	| UIViewAutoresizingFlexibleBottomMargin
	| UIViewAutoresizingFlexibleLeftMargin;

	self->viewBackground = [[DTViewBackground alloc] init];
	
	[self toggleBackgroundViewTo:self.opaque];
	
	[self addSubview:self->activityIndicator];
	[self addSubview:self->infoTextLabel];
}

@end

// MARK: 