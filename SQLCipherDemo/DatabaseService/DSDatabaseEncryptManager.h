//
//  DSDatabaseEncryptManager.h
//  SQLCipherDemo
//
//  Created by 欧杜书 on 30/03/2017.
//  Copyright © 2017 欧杜书. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kDatabaseEncryptKey = @"kDatabaseEncryptKey";

@interface DSDatabaseEncryptManager : NSObject

/**
 加密数据库（删除原有数据库）
 
 @param dbPath 数据库文件全路径
 */
+ (BOOL)encryptDatabase:(NSString *)dbPath;

/**
 解密数据库（删除原有数据库）
 
 @param dbPath 数据库文件全路径
 */
+ (BOOL)unencryptDatabase:(NSString *)dbPath;

/**
 加密数据库（保留原有数据库）
 
 @param origPath 原数据库全路径
 @param toPath 加密后数据库保存路径
 */
+ (BOOL)encryptDatabase:(NSString *)origPath toPath:(NSString *)toPath;

/**
 解密数据库（保留原有数据库）
 
 @param origPath 原数据库全路径
 @param toPath 解密后数据库保存路径
 */
+ (BOOL)unencryptDatabase:(NSString *)origPath toPath:(NSString *)toPath;

/**
 修改已加密数据库密钥

 @param dbPath 数据库全路径
 @param origKey 原密钥
 @param newKey 新密钥
 */
+ (BOOL)changeSecretKeyForDatabase:(NSString *)dbPath
                           origKey:(NSString *)origKey
                            newKey:(NSString *)newKey;

@end
