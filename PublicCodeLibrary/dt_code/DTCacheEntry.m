//
//  MECacheEntry.m
//  IphoneEPG
//
//  Created by said.el-mallouki on 18.02.09.
//  Copyright 2009 Deutsche Telekom AG. All rights reserved.
//

#import "DTCacheEntry.h"
#import "DTDebugging.h"

#if !defined( DTCACHE_USES_PREDICATES ) || DTCACHE_USES_PREDICATES == 0

#import "DTFileCache_private.h"



@implementation DTCacheEntry

@synthesize persistent = persistent;
@synthesize dirty = dirty;

@synthesize createDate = createDate;
@synthesize dateOfLastAccess = dateOfLastAccess;
@synthesize expirationDate = expirationDate;

@synthesize localFilename = localFilename;
@synthesize primaryKey = primaryKey;
@synthesize key = key;

#pragma mark -
#pragma mark NSObject: Creating, Copying, and Deallocating Objects

- (void)dealloc 
{
	// Read-only properties.
	[self->primaryKey release];
	self->primaryKey = nil;
	
	// Read-write properties.
    self.localFilename = nil;
	
	[self->key release];
    self->key = nil;
	
    self.createDate = nil;
	self.dateOfLastAccess = nil;
	self.expirationDate = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Initialisation

+ (DTCacheEntry *)cacheEntryWithKey:(NSString *)key fileCache:(DTFileCache *)fileCache
{
	return [[[[self class] alloc] 
		initWithKey:key 
		fileCache:fileCache] autorelease];
}

- (id)initWithKey:(NSString *)aKey fileCache:(DTFileCache *)aFileCache 
{
	@try
	{
		if ( 0 == [aKey length] )
			[NSException
				raise:NSInvalidArgumentException
				format:@"key must not be empty."];
		
		if ( !aFileCache )
			[NSException
				raise:NSInvalidArgumentException
				format:@"fileCache must not be nil."];

		if ( self = [super init] ) 
		{
			self->fileCache = aFileCache;
			self->key = [aKey copy];

			// Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
			sqlite3_stmt * const entry_exists_statement = [aFileCache entryExistsStatement];
			NSAssert( entry_exists_statement, @"Failed to obtain entry_exists_statement." );
			
			sqlite3_bind_text(
				entry_exists_statement,
				1,
				[self.key UTF8String],
				-1,
				SQLITE_TRANSIENT );
				
			if ( sqlite3_step( entry_exists_statement ) == SQLITE_ROW ) 
			{
				self->primaryKey = [[NSNumber numberWithLongLong:sqlite3_column_int64(entry_exists_statement, 0)] retain];
				self.localFilename = [NSString stringWithUTF8String:(char *)sqlite3_column_text(entry_exists_statement, 1)];
				self.createDate = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(entry_exists_statement, 2)];
				self.dateOfLastAccess = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(entry_exists_statement, 3)];

				if ( sqlite3_column_type( entry_exists_statement, 4 ) != SQLITE_NULL )
					self.expirationDate = [NSDate dateWithTimeIntervalSince1970:
						sqlite3_column_double(entry_exists_statement, 4) ];

				self->persistent = YES;
			} 
			else 
			{
				//
				// Assign UUID as local filename.
				//
				
				CFUUIDRef UUID = NULL;
				CFStringRef UUIDAsString = NULL;
				
				@try
				{
					UUID = CFUUIDCreate( NULL );
					UUIDAsString = CFUUIDCreateString( NULL, UUID );
					self.localFilename = [(NSString *)UUIDAsString copy];
				}
				@finally 
				{
					if ( UUID )
						CFRelease( UUID );
					
					if ( UUIDAsString )
						CFRelease( UUIDAsString );
				}

				//
				// Set up dates.
				//
				
				self.createDate = [NSDate dateWithTimeIntervalSinceNow:0];
				self.dateOfLastAccess = [NSDate dateWithTimeIntervalSinceNow:0];

				self->persistent = NO;
			}
			
			// Reset the statement for future reuse.
			sqlite3_reset(entry_exists_statement);
			self.dirty = NO;
		}
	}
	@catch ( NSException *e ) 
	{
		[self release];
		self = nil;
		@throw;
	}
	
    return self;
}

#pragma mark -
#pragma mark Modifying the Database

- (void)insertIntoDatabase
{
	sqlite3_stmt * const insert_entry_statement = [self->fileCache insertEntryStatement];
	NSAssert( insert_entry_statement, @"Failed to obtain insert_entry_statement." );

    sqlite3_bind_text(insert_entry_statement, 1, [self.localFilename UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_entry_statement, 2, [self.key UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_double(insert_entry_statement, 3, [self.createDate timeIntervalSince1970]);
	sqlite3_bind_double(insert_entry_statement, 4, [self.dateOfLastAccess timeIntervalSince1970]);
	
	if ( self.expirationDate )
		sqlite3_bind_double( insert_entry_statement, 5, [self.expirationDate timeIntervalSince1970] );
	else
		sqlite3_bind_null( insert_entry_statement, 5 );

	int const success = sqlite3_step(insert_entry_statement);
    NSAssert1( 
		SQLITE_ERROR != success, 
		@"Error: failed to insert into the database with message '%s'.", 
		sqlite3_errmsg( [self->fileCache database] ));

	/**
	 @todo Check against expected result not against unexpected results. (stherold - 2012-07-24)
	 */

	if ( SQLITE_ERROR == success )
		return;

	// Checken, obs den key schon in der DB gibt!?
    sqlite3_reset(insert_entry_statement);

	DT_LOG(@"DT_FILE_CACHE", 
		@"-[%@ %@]: key = %@, localFilename = %@.", 
		NSStringFromClass( [self class] ),
		NSStringFromSelector( _cmd ),
		self.key,
		self.localFilename );
 

	self.dirty = NO;
}

- (void)updateInDatabase 
{
	sqlite3_stmt * const update_entry_statement = [self->fileCache updateEntryStatement];

    sqlite3_bind_double(update_entry_statement, 1, [self.dateOfLastAccess timeIntervalSince1970] );
	
	if ( self.expirationDate )
		sqlite3_bind_double( update_entry_statement, 2, [self.expirationDate timeIntervalSince1970] );
	else
		sqlite3_bind_null( update_entry_statement, 2 );
		
	sqlite3_bind_int64(update_entry_statement, 3, [self.primaryKey longValue]);

	int const success = sqlite3_step(update_entry_statement);
	NSAssert1(
		SQLITE_ERROR != success, 
		@"Error: failed to insert into the database with message '%s'.", 
		sqlite3_errmsg( [self->fileCache database] ));

	/**
	 @todo Check against expected result not against unexpected results. (stherold - 2012-07-24)
	 */

	if ( SQLITE_ERROR == success )
		return;

	// Checken, obs den key schon in der DB gibt!?
    sqlite3_reset(update_entry_statement);

	DT_LOG(@"DT_FILE_CACHE", 
		@"-[%@ %@]: key = %@, localFilename = %@.", 
		NSStringFromClass( [self class] ),
		NSStringFromSelector( _cmd ),
		self.key,
		self.localFilename );
	self.dirty = NO;
}

- (void)deleteFromDatabase
{
	sqlite3_stmt * delete_entry_statement = [self->fileCache deleteEntryStatement];
	
    // Bind the primary key variable.
    sqlite3_bind_int64(delete_entry_statement, 1, [self.primaryKey integerValue] );

    // Execute the query.
    int const success = sqlite3_step(delete_entry_statement);

    // Reset the statement for future use.
    sqlite3_reset(delete_entry_statement);
    // Handle errors.
	
	NSAssert1( 
		success == SQLITE_DONE, 
		@"Error: failed to delete from database with message '%s'.", 
		sqlite3_errmsg( [self->fileCache database] ) );

	/**
	 @todo Check against expected result not against unexpected results. (stherold - 2012-07-24)
	 */
	if ( SQLITE_ERROR == success )
		return;

	DT_LOG(@"DT_FILE_CACHE", 
		   @"-[%@ %@]: key = %@, localFilename = %@.", 
		   NSStringFromClass( [self class] ),
		   NSStringFromSelector( _cmd ),
		   self.key,
		   self.localFilename );
}

- (void)writeToDatabase
{
	if ( !self.dirty )
		return;

	if ( self.persistent )
		[self updateInDatabase];
	else 
		[self insertIntoDatabase]; 
		
	self.dirty = NO;
}

#pragma mark -
#pragma mark Accessing Local Data Files

- (NSString *)localFilename 
{
	NSString * volatile result = nil;
	
	@synchronized ( self )
	{
		result = [[self->localFilename retain] autorelease];
	}
	
	return result;
}

#pragma mark -
#pragma mark Accessing Local Data Files

-(void)setLocalFilename:(NSString *)aLocalFilename 
{
	@synchronized ( self )
	{
		if (
			(!self->localFilename && !aLocalFilename) 
			|| (self->localFilename && aLocalFilename && [self->localFilename isEqualToString:aLocalFilename])
		) 
			return;
			
		self.dirty = YES;
		[self->localFilename autorelease];
		self->localFilename = [aLocalFilename copy];
	}
}

#pragma mark -
#pragma mark Controlling Validity

- (void)setCreateDate:(NSDate *)aDate 
{
	@synchronized ( self )
	{
		if ( aDate && [self->createDate isEqualToDate:aDate] ) 
			return;

		[self->createDate autorelease];
		self->createDate = [aDate retain];

		self.dirty = YES;
	}
}

- (void)setDateOfLastAccess:(NSDate *)aDate 
{
	if ( aDate && [self->dateOfLastAccess isEqualToDate:aDate] ) 
		return;

	[aDate retain];
	[self->dateOfLastAccess release];
	self->dateOfLastAccess = aDate;

	self.dirty = YES;
}

- (void)setExpirationDate:(NSDate *)newDate
{
	if ( newDate && [self.expirationDate isEqualToDate:newDate] )
		return;
	
	[newDate retain];
	[self->expirationDate release];
	self->expirationDate = newDate;

	self.dirty = YES;	
}

@end

#endif // !defined( DTCACHE_USES_PREDICATES ) || DTCACHE_USES_PREDICATES == 0
