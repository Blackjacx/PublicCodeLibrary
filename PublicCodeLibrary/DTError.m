//
//  DTError.m
//  DTFoundation
//
//  Created by Stefan Herold on 2010-11-24.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "DTError.h"

// DTFoundation - Cocoa Foundation Additions.
//#import "NSString+DTFormatting.h"

// DTFoundation - Utilities.
#import "DTDebugging.h"
#import "DTStrings.h"

DT_DEFINE_STRING( DLSErrorDomain, "de.telekom.dls.errors" );

int const DTErrorErrorCodeForUnknownError = 999999;

static NSMutableDictionary * DTErrorBundleForErrorDomainDictionary = nil;

@implementation DTError


// Bundle Registration

+ (void)initialize {

	DTErrorBundleForErrorDomainDictionary = [[NSMutableDictionary alloc] init];
}

+ (void)registerBundle:(NSBundle *)bundle forErrorDomain:(NSString *)errorDomain {

	// Register Bundle if it not already regsitered under incoming domain
	if( ![DTErrorBundleForErrorDomainDictionary objectForKey:errorDomain] ) {

		[DTErrorBundleForErrorDomainDictionary setObject:bundle forKey:errorDomain];
	}
}


// MARK: Init

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)userInfo {

	return [[[self alloc] initWithDomain:domain code:code userInfo:userInfo] autorelease];
}

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code {

	return [[[self alloc] initWithDomain:domain code:code] autorelease];
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)userInfo {

	NSMutableDictionary * const mutableUserInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
	NSBundle * stringTableBundle = [DTErrorBundleForErrorDomainDictionary objectForKey:domain];

	DT_ASSERT(stringTableBundle, @"Unknown error domain (%@)! Please register with [DTError registerBundle:forErrorDomain:]!", domain);

	if( !stringTableBundle ) {

		stringTableBundle = [NSBundle mainBundle];
	}

	// --- Localised description.

	if ( ![mutableUserInfo objectForKey:NSLocalizedDescriptionKey] )
	{
		NSString * const errorDescription = [[self class] localizedDescriptionForDomain:domain
																				   code:code
																				 bundle:stringTableBundle];

		[mutableUserInfo setObject:errorDescription forKey:NSLocalizedDescriptionKey];
	}

	// --- Localised failure reason.

	if ( ![mutableUserInfo objectForKey:NSLocalizedFailureReasonErrorKey] ) {

		NSString * const failureReason = [[self class] localizedFailureReasonForDomain:domain
																				  code:code
																				bundle:stringTableBundle];

		// Failure reason is optional.
		if ( [failureReason length] ) {

			[mutableUserInfo setObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
		}
	}

	// Actual Initialization of self
	
	self = [super initWithDomain:domain code:code userInfo:[[mutableUserInfo copy] autorelease]];

	if( self ) {

	}
	return self;
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code {

	return [self initWithDomain:domain code:code userInfo:nil];
}


// MARK: Getting Format Strings

+ (NSString *)localizedDescriptionForDomain:(NSString*)domain code:(NSInteger)code bundle:(NSBundle*)bundle {

	NSString * localizedFailureReason = [self localizedStringForDomain:domain prefix:@"F" code:code bundle:bundle];
	return localizedFailureReason;
}

+ (NSString *)localizedFailureReasonForDomain:(NSString*)domain code:(NSInteger)code bundle:(NSBundle*)bundle {

	NSString * localizedDescription = [self localizedStringForDomain:domain prefix:@"D" code:code bundle:bundle];
	return localizedDescription;
}

+ (NSString *)localizedStringForDomain:(NSString *)domain prefix:(NSString *)prefix code:(NSInteger)code bundle:(NSBundle*)bundle
{
	NSString * result = [NSString stringWithFormat:@"<+[%@.%d]: internal error>", domain, code];

	//
	// Check parameters.
	//
	
	DT_ASSERT_RETURN_WITH_VALUE(
		domain && [domain isKindOfClass:[NSString class]] && [domain length],
		result,
		@"Expected %@ to be kind of class NSString and non-empty.",
		DT_STRINGIFY( domain ) );
	
	DT_ASSERT_RETURN_WITH_VALUE(
		!prefix || [prefix isKindOfClass:[NSString class]],
		result,
		@"Expected %@ to either nil or kind of class NSString.",
		DT_STRINGIFY( prefix ) );
		
	//
	// Load string from string table.
	//

	NSString * const key = [prefix length] ?
	[NSString stringWithFormat:@"%@%ld", prefix, (long)code]
	: [NSString stringWithFormat:@"%ld", (long)code];

	// Key for general unknown errors
	NSString * const unknownErrorKey = [prefix length]
	? [NSString stringWithFormat:@"%@%d", prefix, DTErrorErrorCodeForUnknownError]
	: [NSString stringWithFormat:@"%d", DTErrorErrorCodeForUnknownError];

	NSString * unknownErrorKeyPlain = [NSString stringWithFormat: @"%d", DTErrorErrorCodeForUnknownError];

	// localized string message of unknown errors
	NSString * unknownErrorMessage = [bundle localizedStringForKey:unknownErrorKey
															 value:nil
															 table:domain];

	NSString * alternativeResult = [NSString stringWithFormat:@"%@.%d", domain, code];

	// Check if a unknwonErrorMessage exists - If 'yes', use it as alternative result
	if ([unknownErrorMessage rangeOfString:unknownErrorKeyPlain].location == NSNotFound) {

		alternativeResult = unknownErrorMessage;
	}

	// Get the localized string for the domain - if nothing can be found use the alternativeResult
	result = [bundle localizedStringForKey:key
									 value:alternativeResult
									 table:domain];
	
	return result;
}

@end
