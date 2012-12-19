//
//  NSArray+PCLExtensions.h
//  PublicCodeLibrary
//
//  Created by noskill on 23.05.11.
//  Copyright (c) 2012 Stefan Herold. All rights reserved.
//

@interface NSArray (PCLExtensions)

- (id)pcl_firstObject;
- (NSArray*)pcl_sortedWithKey:(NSString*)aKey ascending:(BOOL)sortAscending;

@end
