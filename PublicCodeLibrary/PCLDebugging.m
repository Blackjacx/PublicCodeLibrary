//
//  DTDebugging.m
//  DTLibrary
//
//  Created by Pierre Bongen on 06.10.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import "DTDebugging.h"
#import "DTStrings.h"

DT_DEFINE_STRING( DTDebuggingEnvironmentVariableLogTopics, "DT_LOG_TOPICS" );

static NSSet *DTDebuggingLogTopics = nil;

void _DTShowAlert( NSString * msg )
{
	[[[[UIAlertView alloc] initWithTitle:@"Info <DEBUG>"
								 message:msg
								delegate:nil
					   cancelButtonTitle:@"OK"
					   otherButtonTitles:nil] autorelease] show];
}

void _DTDebugExecuteBlock( DTDebugBlock block ) {

	block();
}

void _DTLog( id const logger, SEL const selector, NSString * const topic, NSString * const message )
{
	//
	// Initialise, if not done yet, the set of topics to log.
	//
	
	if ( !DTDebuggingLogTopics )
	{
		// --- Obtain environment variables.
		
		NSDictionary * const environment = [[NSProcessInfo processInfo] environment];
		NSString * const logTopicsAsString = [environment objectForKey:
			DTDebuggingEnvironmentVariableLogTopics];
		
		if ( 
			![logTopicsAsString isKindOfClass:[NSString class]]
			|| ![logTopicsAsString length] )
		{
			DTDebuggingLogTopics = [NSSet new];
			return;
		}
		
		// --- Determine log topics.
		
		NSArray * const logTopics = 
			[logTopicsAsString componentsSeparatedByString:@","];

		NSMutableSet * mutableLogTopicsAsSet = [NSMutableSet set];

		NSCharacterSet * const whitespaceCharacterSet = 
			[NSCharacterSet whitespaceCharacterSet];
		
		for ( NSString *logTopic in logTopics )
		{
			[mutableLogTopicsAsSet addObject:[logTopic 
				stringByTrimmingCharactersInSet:whitespaceCharacterSet]];
		}
		
		DTDebuggingLogTopics = [mutableLogTopicsAsSet copy];
	}
	
	//
	// Log if topic is log topic.
	//

	BOOL topicFound = NO;
	BOOL displaySignature = YES;
	NSString *topicWithMinus = [topic stringByAppendingString:@"-"];

	if ( 
		[DTDebuggingLogTopics containsObject:@"*-"] 
		|| [DTDebuggingLogTopics containsObject:topicWithMinus] )
	{
		topicFound = YES;
		displaySignature = NO;
	}
	else if ( 
		[DTDebuggingLogTopics containsObject:@"*"] 
		|| [DTDebuggingLogTopics containsObject:topic] )
	{ 
		topicFound = YES;
	}
	
	if ( topicFound )
	{
		if ( displaySignature )
		{
			NSLog( @"<%@> [%@ %@]: %@\n\n", 
				topic,
				NSStringFromClass( [logger class] ),
				NSStringFromSelector( selector ),
				message );
		}
		else 
		{
			NSLog( @"<%@> %@\n\n", 
				topic,
				message );
		}
	}
}
