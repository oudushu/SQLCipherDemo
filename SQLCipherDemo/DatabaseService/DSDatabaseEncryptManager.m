//
//  DSDatabaseEncryptManager.m
//  SQLCipherDemo
//
//  Created by 欧杜书 on 30/03/2017.
//  Copyright © 2017 欧杜书. All rights reserved.
//

#import "DSDatabaseEncryptManager.h"
#import "sqlite3.h"

@implementation DSDatabaseEncryptManager

/**
 加密数据库（删除原有数据库）
 */
+ (BOOL)encryptDatabase:(NSString *)dbPath {
    NSString *fromPath = dbPath;
    NSString *toPath = [NSString stringWithFormat:@"%@.bk", dbPath];
    
    if ([self encryptDatabase:fromPath toPath:toPath]) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        [fm removeItemAtPath:fromPath error:nil];
        [fm moveItemAtPath:toPath toPath:fromPath error:nil];
        return YES;
    } else {
        return NO;
    }
}

/**
 解密数据库（删除原有数据库）
 */
+ (BOOL)unencryptDatabase:(NSString *)dbPath {
    NSString *fromPath = dbPath;
    NSString *toPath = [NSString stringWithFormat:@"%@.bk", dbPath];
    
    if ([self unencryptDatabase:fromPath toPath:toPath]) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        [fm removeItemAtPath:fromPath error:nil];
        [fm moveItemAtPath:toPath toPath:fromPath error:nil];
        return YES;
    } else {
        return NO;
    }
}

/**
 加密数据库（保留原有数据库）
 */
+ (BOOL)encryptDatabase:(NSString *)origPath toPath:(NSString *)toPath {
    const char *sql = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';", toPath, kDatabaseEncryptKey] UTF8String];
    sqlite3 *db;
    if (sqlite3_open([origPath UTF8String], &db) == SQLITE_OK) {
        char *errmsg = NULL;
        sqlite3_exec(db, sql, NULL, NULL, &errmsg);
        sqlite3_exec(db, "SELECT sqlcipher_export('encrypted');", NULL, NULL, &errmsg);
        sqlite3_exec(db, "DETACH DATABASE encrypted;", NULL, NULL, &errmsg);
        sqlite3_close(db);
        
        return errmsg ? NO : YES;
    } else {
        sqlite3_close(db);
        NSLog(@"Open db failed:%s", sqlite3_errmsg(db));
        return NO;
    }
}

/**
 解密数据库（保留原有数据库）
 */
+ (BOOL)unencryptDatabase:(NSString *)origPath toPath:(NSString *)toPath {
    const char *sql = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS plaintext KEY '';", toPath] UTF8String];
    
    sqlite3 *db;
    if (sqlite3_open([origPath UTF8String], &db) == SQLITE_OK) {
        char *errmsg = NULL;
        sqlite3_exec(db, [[NSString stringWithFormat:@"PRAGMA key = '%@';", kDatabaseEncryptKey] UTF8String], NULL, NULL, &errmsg);
        sqlite3_exec(db, sql, NULL, NULL, NULL);
        sqlite3_exec(db, "SELECT sqlcipher_export('plaintext');", NULL, NULL, &errmsg);
        sqlite3_exec(db, "DETACH DATABASE plaintext;", NULL, NULL, &errmsg);
        sqlite3_close(db);
        
        return errmsg ? NO : YES;
    } else {
        sqlite3_close(db);
        NSLog(@"Open db failed:%s", sqlite3_errmsg(db));
        return NO;
    }
}

/**
 修改已加密数据库密钥
 */
+ (BOOL)changeSecretKeyForDatabase:(NSString *)dbPath
                           origKey:(NSString *)origKey
                            newKey:(NSString *)newKey {
    sqlite3 *db;
    if (sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        sqlite3_exec(db, [[NSString stringWithFormat:@"PRAGMA key = '%@';", origKey] UTF8String], NULL, NULL, NULL);
        sqlite3_exec(db, [[NSString stringWithFormat:@"PRAGMA rekey = '%@';", newKey] UTF8String], NULL, NULL, NULL);
        sqlite3_close(db);
        return YES;
    } else {
        sqlite3_close(db);
        NSLog(@"Open db failed:%s", sqlite3_errmsg(db));
        return NO;
    }
}

@end
