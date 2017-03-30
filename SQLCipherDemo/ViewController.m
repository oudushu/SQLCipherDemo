//
//  ViewController.m
//  SQLCipherDemo
//
//  Created by 欧杜书 on 30/03/2017.
//  Copyright © 2017 欧杜书. All rights reserved.
//

#import "ViewController.h"
#import "DSDatabaseEncryptManager.h"
#import "FMEncryptDatabase.h"
#import "FMEncryptDatabaseQueue.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *normalDbPath;
@property (nonatomic, strong) NSString *encryptDbPath;
@property (nonatomic, strong) FMEncryptDatabaseQueue *encryptQueue;
@property (nonatomic, strong) FMDatabaseQueue *normalQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    self.normalDbPath = [directory stringByAppendingPathComponent:@"DB.db"];
    self.encryptDbPath = [directory stringByAppendingPathComponent:@"ENCRYPTDB.db"];
    
    self.normalQueue = [FMDatabaseQueue databaseQueueWithPath:self.normalDbPath];
    self.encryptQueue = [FMEncryptDatabaseQueue databaseQueueWithPath:self.encryptDbPath];
}

#pragma mark -
- (IBAction)createNormalDbTable {
    NSLog(@"Create normal db");
    self.normalQueue = [FMDatabaseQueue databaseQueueWithPath:self.normalDbPath];
    [self creatTableWithEncryptDb:NO];
}

- (IBAction)createEncryptDbTable {
    NSLog(@"Create encrypt db");
    self.encryptQueue = [FMEncryptDatabaseQueue databaseQueueWithPath:self.encryptDbPath];
    [self creatTableWithEncryptDb:YES];
}

- (IBAction)insertDataToNormalDbTable {
    NSLog(@"insert normal db");
    [self insertDataWithEncryptDb:NO];
}

- (IBAction)insertDataToEncryptDbTable {
    NSLog(@"insert encrypt db");
    [self insertDataWithEncryptDb:YES];
}

- (IBAction)encryptNormalDb {
    NSLog(@"Encrypt normal db");
    CGFloat before = [[NSDate date] timeIntervalSince1970];
    [DSDatabaseEncryptManager encryptDatabase:self.normalDbPath];
    NSLog(@"encrypt after %f", [[NSDate date] timeIntervalSince1970] - before);
    
    // 加密后需要改用继承过的FMEncryptDatabaseQueue的实例，不然不能读写数据
    self.normalQueue = [FMEncryptDatabaseQueue databaseQueueWithPath:self.normalDbPath];
}

- (IBAction)unencryptEncryptedDb {
    NSLog(@"Unencrypt encrypted db");
    CGFloat before = [[NSDate date] timeIntervalSince1970];
    [DSDatabaseEncryptManager unencryptDatabase:self.encryptDbPath];
    NSLog(@"unencrypt after %f", [[NSDate date] timeIntervalSince1970] - before);
    
    // 解密后需要用普通的FMDatabaseQueue的实例，不然不能读写数据
    self.encryptQueue = [FMDatabaseQueue databaseQueueWithPath:self.encryptDbPath];
}

- (IBAction)selectFromEncrypedDb {
    __block id result;
    [self.normalQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT COUNT(*) FROM Student" withArgumentsInArray:nil];
        if ([rs next]) {
            result = rs[0];
        } else {
            result = nil;
        }
        [rs close];
    }];
    
    NSLog(@"encryped count  %ld", [result integerValue]);
}

- (IBAction)selectFromUnencrypedDb {
    __block id result;
    [self.encryptQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT COUNT(*) FROM Student" withArgumentsInArray:nil];
        if ([rs next]) {
            result = rs[0];
        } else {
            result = nil;
        }
        [rs close];
    }];
    
    NSLog(@"encryped count  %ld", [result integerValue]);
}

- (IBAction)dbPath {
    NSLog(@"normalDbPath: %@\n encryptDbPath: %@", self.normalDbPath, self.encryptDbPath);
}

- (IBAction)removeDb {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:self.normalDbPath error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:self.encryptDbPath error:&error];
}

#pragma mark -
- (void)creatTableWithEncryptDb:(BOOL)isEncrypt {
    NSString *sql = @"CREATE TABLE if not exists Student (id INTEGER PRIMARY KEY AUTOINCREMENT, name1 TEXT, p1 TEXT, p2 BLOB, p3 REAL, p4 REAL, p5 TEXT, p6 INTEGER, p7 INTEGER)";
    if (isEncrypt) {
        [self.encryptQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:sql];
        }];
    } else {
        [self.normalQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:sql];
        }];
    }
}

- (void)insertDataWithEncryptDb:(BOOL)isEncrypt {
    NSString *sql = @"insert into Student (name1, p1, p2, p3, p4, p5, p6, p7) values(?,?,?,?,?,?,?,?)";
    
    CGFloat before = [[NSDate date] timeIntervalSince1970];
    NSArray *param = nil;
    if (isEncrypt) {
        param = @[@"encrypt", @"大明", @10, @(111.11), @(123), @(123), [NSDate date], @NO];
    } else {
        param = @[@"unencrypt", @"小明", @10, @(111.11), @(123), @(123), [NSDate date], @NO];
    }
    if (isEncrypt) {
        [self.encryptQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (int i = 0; i < 50000; i++) {
                [db executeUpdate:sql withArgumentsInArray:param];
            }
        }];
    } else {
        [self.normalQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (int i = 0; i < 50000; i++) {
                [db executeUpdate:sql withArgumentsInArray:param];
            }
        }];
    }

    NSLog(@"insert after %f", [[NSDate date] timeIntervalSince1970] - before);
}

@end
