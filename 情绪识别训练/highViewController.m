//
//  highViewController.m
//  情绪识别训练
//
//  Created by lpx on 16/3/16.
//  Copyright (c) 2016年 lpx. All rights reserved.
//

#import "highViewController.h"
#import <AudioToolbox/AudioToolbox.h>

typedef enum
{
    kHappy = 0,     // 高兴
    kPain,          // 悲伤
    kAngry,         // 生气
    kFear,          // 害怕
    kSurprise,      // 惊讶
    kDetest,        // 厌恶
    kNormal,        // 中性
 
} kAnimationType;


@interface highViewController ()
{
     //表情数据字典
       NSMutableDictionary *_emotionDict;
    
    
    // 音效的数据字典
    NSMutableDictionary *_soundDict;
}
@end


@implementation highViewController
//返回菜单
- (IBAction)backBtnClick:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - 修改状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    // 把statusBar的样式修改为白色
    return UIStatusBarStyleLightContent;
}

/**
 用数据字典来实现音效的管理
 */
- (SystemSoundID)loadSoundId:(NSString *)soundFile
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:soundFile ofType:nil]];
    
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundId);
    
    return soundId;
}


   //初始化界面入口
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置背景图片
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bg-02.png"]];

    
    // 数据初始化工作，加载数据字典成员变量
    
    // 1. 需要指定路径
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Emotion" ofType:@"plist"];
    
    // 2. 加载数据字典
    _emotionDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];

    // 3. 初始化音效字典
    _soundDict = [NSMutableDictionary dictionary];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)animationBtnClick:(UIButton *)sender {
    if ([_emotionView isAnimating]) {
        return;
    }
    NSDictionary *dict;
    switch (sender.tag) {
        case kHappy:
            dict = _emotionDict[@"happy"];
            break;
        case kPain:
            dict = _emotionDict[@"pain"];
            break;
        case kAngry:
            dict = _emotionDict[@"angry"];
            break;
        case kFear:
            dict = _emotionDict[@"fear"];
            break;
        case kSurprise:
            dict = _emotionDict[@"surprise"];
            break;
        case kDetest:
            dict = _emotionDict[@"detest"];
            break;
        case kNormal:
            dict = _emotionDict[@"normal"];
            break;
        default:
            break;
    }

    NSMutableArray *imageList = [NSMutableArray array];
    for (NSInteger i = 0; i < [dict[@"frames"]integerValue]; i++) {
        NSString *imageFile = [NSString stringWithFormat:dict[@"imageFormat"], i];
        UIImage *image = [UIImage imageNamed:imageFile];
        [imageList addObject:image];
    }
    
    NSArray *array = dict[@"soundFiles"];
    // 2) 判断数组中是否有数据，如果有数据做进一步处理
    SystemSoundID soundId = 0;
    if (array.count > 0) {
        // 3) 我们根据数组中得文件名，判断音频字典中是否有对应的记录，如果没有，建立新的音频数据字典
        for (NSString *fileName in array) {
            SystemSoundID playSoundId = [_soundDict[fileName]unsignedLongValue];
            
            // 如果在字典中没有定义音频代号，初始化音频Id，并且加入字典
            if (playSoundId <= 0) {
                playSoundId = [self loadSoundId:fileName];
                // 将playSoundId加入到数据字典，向字典中增加数值，不是用add
                // 向NSDict NSArray中添加数值需要“包装”
                // @() 会把一个NSInteger的数字，变成NSNumber的对象
                [_soundDict setValue:@(playSoundId) forKey:fileName];
            }
        }
        
        // 每一个动画的声音可以是多个，采用随机数的方式播放音效
        NSInteger seed = arc4random_uniform(array.count);
        NSString *fileName = array[seed];
        
        soundId = [_soundDict[fileName]unsignedLongValue];

    }
    
    
    // 设置图像的动画属性
    [_emotionView setAnimationImages:imageList];
    [_emotionView setAnimationDuration:[dict[@"frames"]integerValue] / 10.0];
    [_emotionView setAnimationRepeatCount:1];
    [_emotionView startAnimating];

    // 播放声音
    if (soundId > 0) {
        
    AudioServicesPlaySystemSound(soundId);
        
    }
    
}
@end
