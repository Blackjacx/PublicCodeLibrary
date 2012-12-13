//
//  NSURL+PCLExtensions.h
//  PrivateCodeLibrary
//
//  Created by *** *** on 9/20/11.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (PCLExtensions)

// MARK: 
// MARK URL Creation

+ (NSURL *)URLWithRoot:(NSString *)root
		path:(NSString *)path 
		getParameters:(NSDictionary *)getParameters;
		
@end
