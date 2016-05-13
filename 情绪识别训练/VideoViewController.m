//
//  VideoViewController.m
//  情绪识别训练
//
//  Created by lpx on 16/4/11.
//  Copyright (c) 2016年 lpx. All rights reserved.
//

#import "VideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MUModel.h"
#import <AVFoundation/AVFoundation.h>

// 屏幕的size
#define kScreenSize ([UIScreen mainScreen].bounds.size)
// 定义 答案区域按钮的宽高
#define kButtonWidht 60

// 定义 答案区域按钮之间的间距
#define kMargin 10

@interface VideoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *imagebutton;
@property (weak, nonatomic) IBOutlet UIView *optionView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousBtn;

@property (nonatomic, strong) MPMoviePlayerController  *vc;
@property (nonatomic, strong) NSArray *dataArray;
// 表示第几题
@property (nonatomic, assign) NSInteger index;

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bg-02.png"]];

    
    // 初始化index = 1
    _index = 1;
    
    [self setupUI];
    

  
}

- (IBAction)returnBtn:(id)sender {
    [self dismissModalViewControllerAnimated:YES];

}

#pragma mark - 懒加载数据
- (NSArray *)dataArray {
    if (nil == _dataArray) {
        
        // 1. 读取文件路径
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MovieQuestion.plist" ofType:nil];
        
        // 2. 读取内容到临时数组
        NSArray *tempArray = [NSArray arrayWithContentsOfFile:path];
        
        // 3. 创建一个可变数组
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        // 4. 遍历临时数组中的字典转为模型 , 存放到可变数组
        for (NSDictionary *dict in tempArray) {
            MUModel *guessModel = [MUModel guessModelDict:dict];
            
            [mutableArray addObject:guessModel];
        }
        
        // 5. 把可变数组赋值给 _dataArray
        _dataArray = mutableArray;
        
    }
    return _dataArray;
}

#pragma mark - 设置UI界面
- (void)setupUI {
    
    // 给控件设置数据
    // 取出_index - 1 在 数组中对应的数据
    MUModel *guessModel = self.dataArray[_index - 1];
    
        // 索引label
        _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)_index, (unsigned long)self.dataArray.count];
    
        // titleLabel
        _titleLabel.text = guessModel.title;
    
    //设置 imageButton
    // 取出图片名称
      NSString *imageName = guessModel.icon;
    //    // 实例化一个image对象
       UIImage *image = [UIImage imageNamed:imageName];
    //
       [_imagebutton setImage:image forState:UIControlStateNormal];
    //
    
    //换行
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.numberOfLines = 0;
    
    /**
     选项区域 3行 7 列 , 21 个按钮
     按钮的个数不会发生变化, 变化的知识按钮上的文字
     
     初始设置:
     [self setupOptionView];
     
     修改:
     选项区域中的button上需要设置文本
     传递参数: model中 options 数组, 存放button上需要的文字
     */
    [self setupOptionViewWithOptions:guessModel.options];
    
      _optionView.userInteractionEnabled = NO;
}


#pragma mark -  选项区域 修改后
- (void)setupOptionViewWithOptions:(NSArray *)options {
    // 确定列数
    int column = 4;

    NSInteger count = options.count;
    
    // 计算margin
    CGFloat margin = (kScreenSize.width - column * kButtonWidht) / (column + 1);
    
    // 把button给移除掉
#warning 需不需要每次都把选项区域的button给移除掉?
    
    [_optionView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 循环添加button
    for (int i = 0; i < count; i++) {
        // 得到行索引和列索引
        NSInteger rowIndex = i / column;
        NSInteger columnIndex = i % column;
        
        // 计算x, y
        CGFloat buttonX = (columnIndex + 1) * margin + columnIndex * kButtonWidht;
        CGFloat buttonY = rowIndex * margin + rowIndex * kButtonWidht;
        
        // 实例化按钮
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, kButtonWidht, kButtonWidht)];
        
        // 设置背景图片
        [button setBackgroundImage:[UIImage imageNamed:@"Btn-answer57"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
        
        // 设置按钮的文字
        [button setTitle:options[i] forState:UIControlStateNormal];
        
        // 修改文本的颜色
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        // 添加按钮的点击事件
        [button addTarget:self
                   action:@selector(didClickOptionButton:)
         forControlEvents:UIControlEventTouchUpInside];
        
        // 添加按钮到optionView
        [_optionView addSubview:button];
    }
}


#pragma mark -  点击选项区域的按钮
- (void)didClickOptionButton:(UIButton *)optionButton {
    
    // 1. 取出文字
    NSString *title = optionButton.currentTitle;
    // 5.2 取出当前题目的正确答案
    MUModel *guessModel = self.dataArray[_index - 1];
    
    NSString *rightAnswer = guessModel.answer;
    
    
    //如果回答正确
    if (title==rightAnswer) {
        
        NSString *path = [[NSBundle mainBundle]pathForResource:@"你真棒.mp3" ofType:nil];
        NSURL *url = [NSURL fileURLWithPath:path];
        SystemSoundID soundID = 0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
        AudioServicesPlaySystemSound(soundID);
        
        
        //播放提示
        
        // 1. 实例化UIAlertController , ios7 UIAlertView
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"答对了！" message:@"你真厉害(ง •̀_•́)ง" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(creatAlert:) userInfo:alertController repeats:NO];
        
        
        
        // 5.3.1 自动跳入下一题
        [self performSelector:@selector(nextBtn:) withObject:nil afterDelay:1];
       
    }
}

//计时器
-(void)creatAlert:(NSTimer * )timer{
    UIAlertController *alertController = [timer userInfo];
    [alertController dismissViewControllerAnimated:YES completion:nil];
    alertController = nil;
}


- (IBAction)play:(id)sender {
    MUModel *guessModel = self.dataArray[_index - 1];
    NSString *movieName = guessModel.moviename;
    //创建播放器
    NSString *path = [[NSBundle mainBundle]pathForResource:movieName ofType:nil];
    MPMoviePlayerController  *vc = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL fileURLWithPath:path]];
    vc.view.frame = self.view.bounds;
    [self.view addSubview:vc.view];
    self.vc = vc;
    //播放
    [self.vc play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}
//播放完成后销毁视频控制器
-(void)myMovieFinishedCallback:(NSNotification*)notify
{
    //视频播放对象
    MPMoviePlayerController* vc = [notify object];
    //销毁播放通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:vc];
    [vc.view removeFromSuperview];
    
      _optionView.userInteractionEnabled = YES;
    
}

- (IBAction)nextBtn:(id)sender {
    
    _previousBtn.enabled=YES;
    // 0. 是否是最后一道题进行判断
    if (_index == self.dataArray.count) {
        
        
        return;
    }
    
    /**
     0. 先进行判断是否是最后一道题, 如果是, 就直接返回 (防止最后一道题回答正确之后,导致的崩溃)
     1. 让index + 1
     2. 切换界面数据
     3. 到最后一题的时候, 按钮禁用
     4. 如果用户输入完成, optionView的用户交互功能会被禁用, 在这里要打开
     */
    
    // 1. 让index + 1
    _index++;
    
    // 2. 切换数据
    [self setupUI];
    
    // 3. 到最后一题的时候禁用按钮
    // 按钮被禁用将不再响应任何用户交互(点击按钮之后不会再调用相应的方法)
    _nextButton.enabled = (_index != self.dataArray.count);
    
    // 4. 开启optionView的用户交互功能
 
}

- (IBAction)previousBtn:(id)sender {
    _nextButton.enabled=YES;
    if (_index<0) {
        return;
    }
    
        _index=_index-2;
    
    
    if (_index ==1 ) {
        _previousBtn.enabled=NO;
    }
    
       [self setupUI];

}



@end
