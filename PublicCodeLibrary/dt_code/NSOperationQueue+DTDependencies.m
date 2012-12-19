//
//  NSOperationQueue+DTDependencies.m
//  IphoneEPG
//
//  Created by Pierre Bongen on 15.02.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "NSOperationQueue+DTDependencies.h"



@implementation NSOperationQueue ( DTDependencies )

// MARK: 
// MARK:  Adding Operations

- (void)addOperationAndDependencies:(NSOperation *)operation
{
	NSArray * const dependencies = [operation dependencies];
	
	for ( NSOperation * dependency in dependencies )
	{
		[self addOperationAndDependencies:dependency];
	}
	
	[self addOperation:operation];
}

@end
