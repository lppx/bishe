//
//  ViewController.m
//  情绪识别训练
//
//  Created by lpx on 16/3/16.
//  Copyright (c) 2016年 lpx. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
#pragma mark - 修改状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    // 把statusBar的样式修改为白色
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"home-00.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
