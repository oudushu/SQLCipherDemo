//
//  FMEncryptDatabase.m
//  SQLCipherDemo
//
//  Created by 欧杜书 on 30/03/2017.
//  Copyright © 2017 欧杜书. All rights reserved.
//

#import "FMEncryptDatabase.h"
#import "DSDatabaseEncryptManager.h"

@implementation FMEncryptDatabase

#pragma mark - 重载父类方法
#pragma mark Open and close database

- (BOOL)open {
    if (_db) {
        return YES;
    }
    
    int err = sqlite3_open([self sqlitePath], &_db );
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return NO;
    } else {
        // 设置密钥
        [self setKey:kDatabaseEncryptKey];
    }
    
    if (_maxBusyRetryTimeInterval > 0.0) {
        // set the handler
        [self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
    }
    
    
    return YES;
}

#if SQLITE_VERSION_NUMBER >= 3005000
- (BOOL)openWithFlags:(int)flags {
    if (_db) {
        return YES;
    }
    
    int err = sqlite3_open_v2([self sqlitePath], &_db, flags, NULL /* Name of VFS module to use */);
    if(err != SQLITE_OK) {
        NSLog(@"error opening!: %d", err);
        return NO;
    } else {
        // 设置密钥
        [self setKey:kDatabaseEncryptKey];
    }
    
    if (_maxBusyRetryTimeInterval > 0.0) {
        // set the handler
        [self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
    }
    
    return YES;
}
#endif

- (const char*)sqlitePath {
    
    if (!_databasePath) {
        return ":memory:";
    }
    
    if ([_databasePath length] == 0) {
        return ""; // this creates a temporary database (it's an sqlite thing).
    }
    
    return [_databasePath fileSystemRepresentation];
    
}

@end
