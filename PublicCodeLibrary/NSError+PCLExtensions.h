//
//  NSError+PCLExtensions.h
//  PrivateCodeLibrary
//
//  Created by *** *** on 10/24/11.
//  Copyright (c) 2011 Blackjacx & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PCLErrorCode) {
	/*! 
		@brief Unknwon Error code
		@details Can occur in every situation.
	 */
	PCLErrorCodeUnknown = 999999
};

@interface NSError (PCLExtensions)

/*! 
	@brief Creates an NSError object based simply on domain and code.
	@details The creation algorithm is based on available, localized string 
				tables in the main project. They provide the localizable 
				messages contained in this error object. @see { 
				@c NSLocalizedFailureReasonErrorKey
				@c NSLocalizedDescriptionKey }
*/
+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code;

@end
