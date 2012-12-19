//
//  NSOperationQueue+DTDependencies.h
//  IphoneEPG
//
//  Created by Pierre Bongen on 15.02.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSOperationQueue ( DTDependencies ) 

// MARK: 
// MARK:  Adding Operations

- (void)addOperationAndDependencies:(NSOperation *)operation;

@end
