//
//  FMEncryptDatabaseQueue.m
//  SQLCipherDemo
//
//  Created by 欧杜书 on 30/03/2017.
//  Copyright © 2017 欧杜书. All rights reserved.
//

#import "FMEncryptDatabaseQueue.h"
#import "FMEncryptDatabase.h"

@implementation FMEncryptDatabaseQueue

#pragma mark - 重载父类方法
+ (Class)databaseClass {
    return [FMEncryptDatabase class];
}

@end
