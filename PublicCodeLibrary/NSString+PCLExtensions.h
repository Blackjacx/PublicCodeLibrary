/*!
 @brief		NSString category based extensions
 @author	*** ***
 @date		2011-10-24
 @copyright	Copyright (c) 2012 Blackjacx & Co. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NSStringLoremIpsumType) {
	NSStringLoremIpsumTypeLength,
	NSStringLoremIpsumTypeMaxLength,
	NSStringLoremIpsumTypeWords,
	NSStringLoremIpsumTypeMaxWords
	
};

@interface NSString (PCLExtensions)

// MARK: 
// MARK: Lorem Ipsum Generation

+ (NSString*) loremIpsumWithValue:(NSUInteger)aValue type:(NSStringLoremIpsumType)aType;
+ (NSString*) loremIpsumWithLength:(NSUInteger)aLength;
+ (NSString*) loremIpsumWithMaxLength:(NSUInteger)aLength;
+ (NSString*) loremIpsumWithWords:(NSUInteger)aCount;
+ (NSString*) loremIpsumWithMaxWords:(NSUInteger)aCount;

// MARK: 
// MARK: Repeating Strings

- (NSString*)repeat:(NSUInteger)times;

// MARK: 
// MARK: URL Encoding

- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

// MARK: 
// MARK: UUID Generation

+ (NSString*)uniqueID;

// MARK: 
// MARK: Comparison

- (BOOL)isNotEqualToString:(NSString*)aString;
- (BOOL)isLowerToString:(NSString*)aString;
- (BOOL)isLowerEqualToString:(NSString*)aString;

// MARK: 
// MARK: Truncation

- (NSString*)trim;
- (NSString*)truncatedToWidth:(CGFloat)aWidth withFont:(UIFont*)aFont;

// MARK: 
// MARK: Strings Length Related

- (BOOL)empty;

// MARK: 
// MARK: File Paths

- (NSString*)concatWithDocumentsDirectoryPath;
- (NSString*)concatWithTemporaryDirectoryPath;

// MARK: 
// MARK: Regular Expression Checking

- (BOOL)matchesRegularExpression:(NSString*)regexPattern;


@end
