/*!
 @file		NSStringExtensionTests.m
 @brief		This class is responsible for testing the NSString class extension.
 @author	Stefan Herold
 @date		2015-07-30
 @copyright	Copyright © 2015 Stefan Herold. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <PublicCodeLibrary/PublicCodeLibrary.h>

@interface NSStringExtensionTests : XCTestCase

@end

@implementation NSStringExtensionTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testEmptyString
{
    XCTAssert([NSString pcl_isStringEmpty:@""], @"Must result in true for an empty string.");
    XCTAssertFalse([NSString pcl_isStringEmpty:@"   "], @"Must result in false for a string containing only whitespaces.");
    XCTAssertFalse([NSString pcl_isStringEmpty:@"\n"], @"Must result in false for a string containing only the newline character.");
    XCTAssertFalse([NSString pcl_isStringEmpty:@"Hello World!"], @"Must result in false for a string thats not empty.");
}

@end
