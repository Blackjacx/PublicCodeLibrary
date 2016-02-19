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

- (void)testLoremIpsumMaxLength {
    NSString* maxLength0 = [NSString pcl_loremIpsumWithMaxLength:0];
    NSString* maxLength1 = [NSString pcl_loremIpsumWithMaxLength:1];
    NSString* maxLength20 = [NSString pcl_loremIpsumWithMaxLength:20];
    XCTAssertLessThanOrEqual(maxLength0.length, 0);
    XCTAssertLessThanOrEqual(maxLength1.length, 1);
    XCTAssertLessThanOrEqual(maxLength20.length, 20);
}

- (void)testLoremIpsumLength {
    NSString* length0 = [NSString pcl_loremIpsumWithLength:0];
    NSString* length1 = [NSString pcl_loremIpsumWithLength:1];
    NSString* length20 = [NSString pcl_loremIpsumWithLength:20];
    XCTAssertEqual(length0.length, 0);
    XCTAssertEqual(length1.length, 1);
    XCTAssertEqual(length20.length, 20);
}

- (void)testLoremIpsumMaxWords {
    NSString* maxWords0 = [NSString pcl_loremIpsumWithMaxWords:0];
    NSString* maxWords1 = [NSString pcl_loremIpsumWithMaxWords:1];
    NSString* maxWords20 = [NSString pcl_loremIpsumWithMaxWords:20];
    XCTAssertLessThanOrEqual(maxWords0.length, 0);
    XCTAssertLessThanOrEqual([maxWords1 componentsSeparatedByString:@" "].count, 1);
    XCTAssertLessThanOrEqual([maxWords20 componentsSeparatedByString:@" "].count, 20);
}

- (void)testLoremIpsumWords {
    NSString* words0 = [NSString pcl_loremIpsumWithWords:0];
    NSString* words1 = [NSString pcl_loremIpsumWithWords:1];
    NSString* words20 = [NSString pcl_loremIpsumWithWords:20];
    XCTAssertEqual(words0.length, 0);
    XCTAssertEqual([words1 componentsSeparatedByString:@" "].count, 1);
    XCTAssertEqual([words20 componentsSeparatedByString:@" "].count, 20);
}

@end
