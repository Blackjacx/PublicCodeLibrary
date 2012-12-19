//
//  DTProgressCircle.m
//  Assistent
//
//  Created by Stefan Herold on 14.06.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "DTProgressbarView.h"

#define DT_CLAMP(value, min, max) (value > max ? max : (value < min ? min : value))

@interface DTProgressbarView ()
@property(nonatomic, retain)UISlider * progressView;
@end

@implementation DTProgressbarView
@synthesize progressView = _progressView;

- (id)initWithFrame:(CGRect)frame {

	if ((self = [super initWithFrame:frame])) {

		self.progress = 0.0f;

		UIImage * thumbImage = [[[UIImage alloc] init] autorelease];
		_progressView = [[UISlider alloc] initWithFrame:CGRectZero];
		_progressView.continuous = NO;
		_progressView.minimumValue = 0.0f;
		_progressView.maximumValue = 1.0f;
		_progressView.userInteractionEnabled = NO;
		[_progressView setThumbImage:thumbImage forState:UIControlStateNormal];
		[self addSubview:_progressView];
	}
	return self;
}

- (void)dealloc {
	[_progressView release]; _progressView = nil;
	[super dealloc];
}

- (void)layoutSubviews {
	
	CGRect bounds = self.bounds;
	CGFloat trackRectMarginX = 2;
	CGRect progressFrame = CGRectMake(-trackRectMarginX,
									  0,
									  bounds.size.width + 2*trackRectMarginX,
									  bounds.size.height);
	_progressView.frame = progressFrame;
}

- (CGFloat)progress {
	return _progressView.value;
}

- (void)setProgress:(CGFloat)aProgress {
	CGFloat clampedValue = DT_CLAMP(
			aProgress, 
			_progressView.minimumValue,
			_progressView.maximumValue);

	[_progressView setValue:clampedValue animated:NO];
}

- (UIImage*)foregroundStretchableImage {
	return [_progressView maximumTrackImageForState:UIControlStateNormal];
}

- (void)setForegroundStretchableImage:(UIImage *)anImage {
	[_progressView setMinimumTrackImage:anImage forState:UIControlStateNormal];
}

- (UIImage*)backgroundStretchableImage {
	return [_progressView maximumTrackImageForState:UIControlStateNormal];
}

- (void)setBackgroundStretchableImage:(UIImage *)anImage {
	[_progressView setMaximumTrackImage:anImage forState:UIControlStateNormal];
}

- (CGFloat)trackHeight {

	CGFloat maxTrackImgHeight = [self.progressView maximumTrackImageForState:UIControlStateNormal].size.height;
	CGFloat minTrackImgHeight = [self.progressView minimumTrackImageForState:UIControlStateNormal].size.height;

	return MAX(maxTrackImgHeight, minTrackImgHeight);
}

@end
