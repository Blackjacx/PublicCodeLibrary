//
//  NSArray+PCLExtensions.m
//  PrivateCodeLibrary
//
//  Created by noskill on 23.05.11.
//  Copyright (c) 2012 Blackjacx. All rights reserved.
//

#import "NSArray+PCLExtensions.h"


@implementation NSArray (PCLExtensions)

- (id)firstObject
{
    if ( [self count] == 0 ) 
    {
        return nil;
    }
    return self[0];
}

- (NSArray*)sortedWithKey:(NSString*)aKey ascending:(BOOL)sortAscending
{
    NSSortDescriptor * const aSortDescriptor = [[NSSortDescriptor alloc]
                                                    initWithKey:aKey 
                                                    ascending:sortAscending];
    
    NSArray * const sortDescriptorList = [[NSArray alloc] 
                                          initWithObjects:aSortDescriptor, nil];
    
    NSArray * const result = [self sortedArrayUsingDescriptors:sortDescriptorList];
    
    
    return result;
}

@end
