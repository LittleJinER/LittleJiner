//
//  ViewController.m
//  IT008FMDBQueue
//
//  Created by Mac on 16/7/25.
//  Copyright © 2016年 Macol. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"

@interface ViewController ()
@property (retain,nonatomic)FMDatabase *db;
//在使用FMDatabase的时候需要考虑到线程问题，而是用FMDatabaseQueue则无需我们考虑
@property (nonatomic,retain)FMDatabaseQueue *fmQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.db = [FMDatabase databaseWithPath:[self getPath]];
    
    [self.db open];
    [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS stu (id integer PRIMARY KEY AUTOINCREMENT,name text,age integer)"];
//    [self.db close];
    NSLog(@"%@",[self getPath]);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapG:)];
    [self.view addGestureRecognizer:tap];
    
    self.fmQueue = [FMDatabaseQueue databaseQueueWithPath:[self getPath]];
//    使用该方法无需我们手动打开数据库
    [self.fmQueue inDatabase:^(FMDatabase *db) {
        
//        [db open];
        [db  executeUpdate:@"CREATE TABLE IF NOT EXISTS people (id integer PRIMARY KEY AUTOINCREMENT,name text,age integer)"];
        
    }];
}

- (NSString *)getPath{
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/fmdb.sqlite"];
    return path;
    
}
- (IBAction)buttonClick:(UIButton *)sender {

    switch (sender.tag) {
        case 0:
            [self tapG:nil];
            break;
            case 1:
            [self tapG:nil];
            
        default:
            break;
    }


}

- (void)tapG:(UITapGestureRecognizer *)sender{
//    FMDB 同时只能用一个命令去操作他
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
       
//        @synchronized(self) {
        [self insertToDB];
        //        }
    });
    dispatch_async(queue, ^{
        //        @synchronized(self) {
        [self insertToDB];
        // }
    });
    
       for (NSInteger i = 0; i < 1000; i ++) {
           [self insertToQueue];
       };
    
    
    
    
}

- (void)insertToQueue{
    NSString *name = [NSString stringWithFormat:@"someone%d",arc4random()%100];
    NSNumber *age = @(arc4random()%100);

    [self.fmQueue inDatabase:^(FMDatabase *db) {
        [db executeQuery:@"INSERT INTO people(name,age) VALUES(?,?)",name,age];
    }];

    
}


- (void)insertToDB{
    
    NSString *name = [NSString stringWithFormat:@"someone%d",arc4random()%100];
    NSNumber *age = @(arc4random()%100);
//    [self.db open];
    @synchronized(self) {
        [self.db executeQuery:@"INSERT INTO stu(name,age) VALUES(?,?)",name,age];
   };
    
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
