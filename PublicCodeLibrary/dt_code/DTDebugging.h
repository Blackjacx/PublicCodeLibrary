//
//  DTDebugging.h
//  DTLibrary
//
//  Created by Pierre Bongen on 06.10.10.
//  Copyright 2010 Deutsche Telekom AG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DTDebugBlock)(void);


#if defined( DEBUG ) && DEBUG == 1 && !defined( NS_BLOCK_ASSERTIONS )

#define DT_LOG( topic, format, ... ) { _DTLog( self, _cmd, topic, [NSString stringWithFormat:format, ##__VA_ARGS__] ); }
#define DTShowDebugAlert( message_fmt, ... ) { _DTShowAlert( [NSString stringWithFormat:message_fmt, ##__VA_ARGS__] ); }
#define DTDebugExecBlock( block ) { _DTDebugExecuteBlock( block ); }
#define DT_ASSERT( condition, format, ... ) { NSAssert( (condition), (@"%@"), ( [NSString stringWithFormat:format, ##__VA_ARGS__] ) ); }
#define DT_ASSERT_RETURN( condition, format, ... ) if ( !( condition ) ) { \
	NSAssert( NO, (@"%@"), ( [NSString stringWithFormat:format, ##__VA_ARGS__] ) ); return; }
#define DT_ASSERT_RETURN_WITH_VALUE( condition, return_value, format, ... ) if ( !( condition ) ) { \
	NSAssert( NO, (@"%@"), ( [NSString stringWithFormat:format, ##__VA_ARGS__] ) ); return return_value; }

#else

#define DT_LOG( topic, format, ... ) {}
#define DTShowDebugAlert( message_fmt, ... ) {}
#define DTDebugExecBlock( block ) {}
#define DT_ASSERT( condition, format, ... ) {}
#define DT_ASSERT_RETURN( condition, format, ... ) if ( !( condition ) ) { return; }
#define DT_ASSERT_RETURN_WITH_VALUE( condition, return_value, format, ... ) if ( !( condition ) ) { return return_value; }

#endif


extern void _DTLog( id const logger, SEL const selector, NSString * const topic,
	NSString * const message );

extern void _DTShowAlert( NSString * msg );

extern void _DTDebugExecuteBlock( DTDebugBlock block );