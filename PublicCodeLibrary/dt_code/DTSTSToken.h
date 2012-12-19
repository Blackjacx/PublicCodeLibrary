//
//  STSToken.h
//  IphoneEPG
//
//  Created by Stefan Herold on 8/10/10.
//  Copyright 2010 DTAG. All rights reserved.
//

#import <Foundation/Foundation.h>

// DTLibrary.
#import "DTAbstractModel.h"

/*!
 \name Keys used in dictionary for class' initialisers.
 @{
 */

DT_DECLARE_STRING(DTSTSTokenPropKeyPathToken)
DT_DECLARE_STRING(DTSTSTokenPropKeyPathTokenFormat)
DT_DECLARE_STRING(DTSTSTokenPropKeyPathTokenEncoding)
DT_DECLARE_STRING(DTSTSTokenPropKeyPathTokenExpirationDate)
DT_DECLARE_STRING(DTSTSTokenPropKeyPathTokenCreationDate)

//!@}

/*!
 \brief		Declaration of an DLSi model entity.
 \details	This entity holds information about the token obtained during the 
 login process. It is available to determine the expirationstate of the token.
 */

@interface DTSTSToken : DTAbstractModel {
	NSString *tokenString;
	NSString *tokenFormat;
	NSString *tokenEncoding;
	NSDate *tokenExpirationDate;
	NSDate *tokenCreationDate;
	NSTimeInterval timeCorrectionInterval;
}
@property(copy) NSString *tokenString;
@property(copy) NSString *tokenFormat;
@property(copy) NSString *tokenEncoding;
@property(retain) NSDate *tokenExpirationDate;
@property(retain) NSDate *tokenCreationDate;
@property(assign) NSTimeInterval timeCorrectionInterval;

// MARK: -
// MARK: Expiration request

- (BOOL)isExpired;

@end
