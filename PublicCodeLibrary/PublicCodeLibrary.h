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
#import <PublicCodeLibrary/PCLDebugging.h>
#import <PublicCodeLibrary/PCLStrings.h>
#import <PublicCodeLibrary/PCLTypeDefs.h>

// MARK: Foundation Additions
#import <PublicCodeLibrary/NSArray+PCLExtensions.h>
#import <PublicCodeLibrary/NSData+PCLExtensions.h>
#import <PublicCodeLibrary/NSDate+PCLExtensions.h>
#import <PublicCodeLibrary/NSError+PCLExtensions.h>
#import <PublicCodeLibrary/NSNotificationCenter+PCLExtensions.h>
#import <PublicCodeLibrary/NSObject+PCLExtensions.h>
#import <PublicCodeLibrary/NSString+PCLExtensions.h>
#import <PublicCodeLibrary/NSURL+PCLExtensions.h>
#import <PublicCodeLibrary/NSURLRequest+PCLExtensions.h>
#import <PublicCodeLibrary/PCLBackgroundTaskHandler.h>

// MARK: UIKit Extensions
#import <PublicCodeLibrary/UIApplication+PCLExtensions.h>
#import <PublicCodeLibrary/UIColor+PCLExtensions.h>
#import <PublicCodeLibrary/UIDevice+PCLExtensions.h>
#import <PublicCodeLibrary/UIImage+PCLExtensions.h>
#import <PublicCodeLibrary/UIView+PCLExtensions.h>
#import <PublicCodeLibrary/UIViewConroller+PCLExtensions.h>

// MARK: Backend
#import <PublicCodeLibrary/PCLRestCommand.h>