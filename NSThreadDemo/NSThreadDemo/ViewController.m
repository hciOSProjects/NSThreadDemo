//
//  ViewController.m
//  NSThreadDemo
//
//  Created by hechao on 16/4/19.
//  Copyright © 2016年 hechao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSUInteger _totalTickets;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 监听线程退出通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadExitNotice) name:NSThreadWillExitNotification object:nil];
    
    // 设置演唱会门票
    _totalTickets = 10;
    
    // 新建两个子线程
//    NSThread *window1 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTickets) object:nil];
//    window1.name = @"北京售票";
//    [window1 start];
//    
//    NSThread *window2 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTickets) object:nil];
//    window2.name = @"深圳售票";
//    [window2 start];
    
    
    // 新建两个子线程 + runLoop, 同时给线程分配任务
    NSThread *window1 = [[NSThread alloc] initWithTarget:self selector:@selector(thread1) object:nil];
    window1.name = @"北京售票";
    [window1 start];
    
    NSThread *window2 = [[NSThread alloc] initWithTarget:self selector:@selector(thread2) object:nil];
    window2.name = @"北京售票";
    [window2 start];
    
    [self performSelector:@selector(saleTickets) onThread:window1 withObject:nil waitUntilDone:NO];
    [self performSelector:@selector(saleTickets) onThread:window2 withObject:nil waitUntilDone:NO];

}

- (void)thread1
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop runUntilDate:[NSDate date]];
}

- (void)thread2
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];
}

// 不加同步锁
//- (void)saleTickets
//{
//    
//    while (1) {
//        
//        if (_totalTickets > 0) {
//            
//            _totalTickets--;
//            NSLog(@"%@",[NSString stringWithFormat:@"剩余票数:%ld,窗口:%@",_totalTickets,[NSThread currentThread].name]);
//            [NSThread sleepForTimeInterval:0.2];
//            
//        }else{  // 如果已售完关闭窗口
//            break;
//        }
//    
//    }
//    
//}

// 同步锁
//- (void)saleTickets
//{
//   
//    while (1) {
//        @synchronized (self) {
//            
//            if (_totalTickets > 0) {
//                
//                _totalTickets--;
//                NSLog(@"%@",[NSString stringWithFormat:@"剩余票数:%ld,窗口:%@",_totalTickets,[NSThread currentThread].name]);
//                [NSThread sleepForTimeInterval:0.2];
//                
//            }else{  // 如果已售完关闭窗口
//                break;
//            }
//        }
//    }
//    
//}

- (void)saleTickets
{
    
    while (1) {
        @synchronized (self) {
            
            if (_totalTickets > 0) {
                
                _totalTickets--;
                NSLog(@"%@",[NSString stringWithFormat:@"剩余票数:%ld,窗口:%@",_totalTickets,[NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
                
            }else{  // 如果已售完关闭窗口
                
                if ([NSThread currentThread].isCancelled) {
                    break;
                }else{
                    NSLog(@"售票完毕");
                    // 给当前线程标记为取消
                    [[NSThread currentThread] cancel];
                    
                    CFRunLoopStop(CFRunLoopGetCurrent());
                }
            }
        }
    }
    
}





- (void)threadExitNotice
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
