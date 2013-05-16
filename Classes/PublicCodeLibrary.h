/*!
 @file		PublicCodeLibrary.h
 @brief		The global header containing all sub headers.
 @details	This header file can be imported in the PCH of projects that make
 use of this library with the effect to have all the useful stuff
 at hand ... everywhere.
 @author	Stefan Herold
 @date		2011-10-24
 @copyright	Copyright (c) 2012 Stefan Herold. All rights reserved.
 */

// MARK: Core
#import "PCLDebugging.h"
#import "PCLStrings.h"
#import "PCLTypeDefs.h"

// MARK: Foundation Additions
#import "NSArray+PCLExtensions.h"
#import "NSData+PCLExtensions.h"
#import "NSDate+PCLExtensions.h"
#import "NSError+PCLExtensions.h"
#import "NSNotificationCenter+PCLExtensions.h"
#import "NSObject+PCLExtensions.h"
#import "NSString+PCLExtensions.h"
#import "NSURL+PCLExtensions.h"
#import "NSURLRequest+PCLExtensions.h"
#import "PCLBackgroundTaskHandler.h"

// MARK: UIKit Extensions
#import "UIApplication+PCLExtensions.h"
#import "UIColor+PCLExtensions.h"
#import "UIDevice+PCLExtensions.h"
#import "UIImage+PCLExtensions.h"
#import "UIView+PCLExtensions.h"
#import "UIViewConroller+PCLExtensions.h"

// MARK: Backend
#import "PCLRestCommand.h"