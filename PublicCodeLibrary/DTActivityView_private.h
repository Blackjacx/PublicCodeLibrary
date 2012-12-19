//
//  DTActivityView_private.h
//  DTLibrary
//
//  Created by Pierre Bongen on 23.12.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "DTActivityView.h"



@interface DTActivityView( DTPrivate )

- (void)initComponents;
- (void)setParentControllerScrollingToDisabled:(BOOL)disabled;
- (void)toggleBackgroundViewTo:(BOOL)used;

@end
