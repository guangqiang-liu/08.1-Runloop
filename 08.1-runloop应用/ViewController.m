//
//  ViewController.m
//  08.1-runloop应用
//
//  Created by 刘光强 on 2020/2/10.
//  Copyright © 2020 guangqiang.liu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

void test1() {
    static int num = 0;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
         NSLog(@"---%d", num ++);
     }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

void test2() {
    static int num = 0;
     NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
         NSLog(@"---%d", num ++);
     }];
     
     [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    test1();
//    test2();
}
@end
