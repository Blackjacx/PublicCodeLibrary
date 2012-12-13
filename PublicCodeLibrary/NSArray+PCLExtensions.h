//
//  NSArray+PCLExtensions.h
//  PrivateCodeLibrary
//
//  Created by noskill on 23.05.11.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (PCLExtensions)

- (id)firstObject;
- (NSArray*)sortedWithKey:(NSString*)aKey ascending:(BOOL)sortAscending;

@end
