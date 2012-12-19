//
//  NSObject+DTExtensions.m
//  DTLibrary
//
//  Created by Stefan Herold on 10.10.12.
//
//

#import "NSObject+DTExtensions.h"

@implementation NSObject (DTExtensions)

- (BOOL)isNSURLOfTypeFile {

	return [self isKindOfClass:[NSURL class]] && [(NSURL*)self isFileURL];
}

- (BOOL)isNSData {

	return [self isKindOfClass:[NSData class]];
}

- (BOOL)isUIImage {

	return [self isKindOfClass:[UIImage class]];
}


@end
