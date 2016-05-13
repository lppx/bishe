//
//  highViewController.h
//  情绪识别训练
//
//  Created by lpx on 16/3/16.
//  Copyright (c) 2016年 lpx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface highViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *emotionView;
- (IBAction)animationBtnClick:(UIButton *)sender;

@end
