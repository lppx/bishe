//
//  BasicViewController.m
//  情绪识别训练
//
//  Created by lpx on 16/3/16.
//  Copyright (c) 2016年 lpx. All rights reserved.
//

#import "BasicViewController.h"
#import "MUModel.h"
#import <AVFoundation/AVFoundation.h>

// 定义 答案区域按钮的宽高
#define kButtonWidht 30

// 定义 答案区域按钮之间的间距
#define kMargin 10

// 屏幕的size
#define kScreenSize ([UIScreen mainScreen].bounds.size)

@interface BasicViewController ()

@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *imagebutton;
@property (weak, nonatomic) IBOutlet UIView *answerview;
@property (weak, nonatomic) IBOutlet UIView *optionView;
@property (weak, nonatomic) IBOutlet UIButton *tipButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet UIButton *coinButton;

@property (nonatomic, strong) NSArray *dataArray;

// 表示第几题
@property (nonatomic, assign) NSInteger index;

@end


@implementation BasicViewController


//返回菜单
- (IBAction)backBtnClick:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - 修改状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    // 把statusBar的样式修改为白色
    return UIStatusBarStyleLightContent;
}

#pragma mark - 懒加载数据
- (NSArray *)dataArray {
    if (nil == _dataArray) {
        
        // 1. 读取文件路径
        NSString *path = [[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil];
        
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


#pragma mark - 页面加载
- (void)viewDidLoad {
    [super viewDidLoad];//界面入口
    
    // 初始化index = 1
    _index = 1;
    
    [self setupUI];
//    _nextButton.enabled = NO;
    
}

#pragma mark - 设置UI界面
- (void)setupUI {
    
    // 给控件设置数据
    // 取出_index - 1 在 数组中对应的数据
    MUModel *guessModel = self.dataArray[_index - 1];
    
    // 索引label
    _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",_index, self.dataArray.count];
    
    // titleLabel
    _titleLabel.text = guessModel.title;
    
    
    //换行
    _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    _titleLabel.numberOfLines = 0;
    // 设置 imageButton
    // 取出图片名称
    NSString *imageName = guessModel.icon;
    // 实例化一个image对象
    UIImage *image = [UIImage imageNamed:imageName];
    
    [_imagebutton setImage:image forState:UIControlStateNormal];
    
   // _imagebutton.enabled = NO;
    
    /**
     答案区域中, button的个数是跟答案的长度有关
     根据每道题的答案个数来决定按钮的个数
     
     初始设置
     [self setupAnswerView];
     
     答案的个数是不同的, 需要根据每一题的答案长度来确定
     接收的参数: 答案的长度
     修改后:
     [self setupAnswerViewWithLenght:length];
     */
    
    // 获取答案
    NSString *answer = guessModel.answer;
    
    // 答案长度
    NSInteger length = answer.length;
    
    [self setupAnswerViewWithLenght:length];
    
    
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
}

#pragma mark - 答案区域设置 修改后
- (void)setupAnswerViewWithLenght:(NSInteger)count {
    // 表示答案的长度, button的个数
    //    int count = 5;
    // (屏幕的宽度 - button的总宽度 - margin的总宽度)/ 2;
    CGFloat startX = (kScreenSize.width - count * kButtonWidht - (count - 1) * kMargin)/2;
    
    // 添加本题的按钮的时候, 要把上一题的按钮给移除掉
    //    for (UIView *view in _answerView.subviews) {
    //        [view removeFromSuperview];
    //    }
    /**
     让数组中所有的元素都执行 removeFromSuperview
     */
    [_answerview.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i = 0; i < count; i++) {
        // 计算button的x值
        CGFloat buttonX = i * kButtonWidht + i * kMargin + startX;
        
        // 实例化button
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, 0, kButtonWidht, kButtonWidht)];
        // 设置button的背景图片
        [button setBackgroundImage:[UIImage imageNamed:@"Btn-option45"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        // 设置文本颜色
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        // 添加点击事件
        [button addTarget:self
                   action:@selector(didClickAnswerButton:)
         forControlEvents:UIControlEventTouchUpInside];
        // 添加到 answerView上
        [_answerview addSubview:button];
    }
}


#pragma mark -

#pragma mark -  选项区域 修改后
- (void)setupOptionViewWithOptions:(NSArray *)options {
    int column = 7;    // 确定列数
    NSInteger count = options.count;     // 21个按钮
    // 计算margin
    CGFloat margin = (kScreenSize.width - column * kButtonWidht) / (column + 1);
    // 把button给移除掉
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
        [button setBackgroundImage:[UIImage imageNamed:@"Btn-option45"] forState:UIControlStateNormal];
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


#pragma mark -  点击答案区域的按钮
- (void)didClickAnswerButton:(UIButton *)answerButton {
    // 0. 对文本长度做判断
    if (answerButton.currentTitle.length == 0) {
        return;
    }
    /**
     0. 如果被点击按钮没有文本, 就直接返回, 不必再执行后面的代码
     1. 取出被点击按钮的文本
     2. 清空被点击按钮的文本
     3. 在选项区域中 对应到文本的按钮 显示出来
     4. 如果用户输入错误导致字体变红, 当用户点击答案区域的按钮的时候, 就表示用户还没有输入完成
     5. 打开选项区域的用户交互功能(如果用户完成输入, 会把选项区域给禁用)
     */
    
    // 1. 取出文本
    NSString *title = answerButton.currentTitle;
    
    // 2.清空被点击按钮的文本
    [answerButton setTitle:@"" forState:UIControlStateNormal];
    
    // 3. 在选项区域中, 对应到文本的按钮, 显示出来
    [_optionView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *optionButton = obj;
        
        // 取出button文本和 title进行比较, 如果相同, 就显示出来
        if ([optionButton.currentTitle isEqualToString:title]) {
            optionButton.hidden = NO;
            
            *stop = YES;
        }
    }];
    
    // 4. 把按钮的红色改为黑色
    [_answerview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *answerButton = obj;
        
        [answerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }];
    
    // 5. 打开选项区域的用户交互
    _optionView.userInteractionEnabled = YES;
}

#pragma mark -
#pragma mark -  点击选项区域的按钮
- (void)didClickOptionButton:(UIButton *)optionButton {
    /**
     取button的title 一定要分状态
     [optionButton titleForState:UIControlStateNormal];
     
     optionButton.currentTitle
     
     1. 把被点击按钮的文字取出来
     2. 隐藏被点击按钮
     3. 被点击按钮的文字出现在 答案区域的按钮上
     4. 判断用户是否输入完成
     5. 判断用户是否输入正确
     */
    
    // 1. 取出文字
    NSString *title = optionButton.currentTitle;
    
    // 2. 隐藏被点击按钮
    optionButton.hidden = YES;
    
    // 3. 被点击按钮的文字 显示到 答案区域
    // obj -->  数组中的对象
    // idx -->  下标
    // *stop --> 如果设置为 yes 的化,会立即跳出遍历
    [_answerview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        UIButton *answerButton = obj;
        if(answerButton.currentTitle.length==0)
        {
            [answerButton setTitle:title forState:UIControlStateNormal];
        *stop = YES;
           }
    }];
    // 4. 判断用户是否输入完成
    // isComplete = YES 表示, 用户输入完成
    __block BOOL isComplete = YES;
    [_answerview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // 类型转换
        UIButton *answerButton = obj;
        if (answerButton.currentTitle.length == 0) {
            // 该按钮还没有被设置文本
            isComplete = NO;
            *stop = YES;
        }
    }];
    if (isComplete) { // 表示用户输入完成
        // 用户不能再点击 选项区域中的按钮
        // userInteractionEnabled = NO  禁止任何用户交互, 如果是父view设置了这个属性为NO, 那么它的子view也将不会接受用户交互
        _optionView.userInteractionEnabled = NO;
        /**
         5. 判断用户是否输入正确
         5.1 取出用户输入的答案
         5.2 取出当前题目的正确答案
         5.3 进行比较
         */
        
        // 5.1 取出用户输入的答案
        
        // 定义一个可变字符串
        NSMutableString *userAnswer = [NSMutableString string];
        [_answerview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIButton *answerButton = obj;
            // 拼接每一个button上的文本
            [userAnswer appendString:answerButton.currentTitle];
        }];
        
        // 5.2 取出当前题目的正确答案
        MUModel *guessModel = self.dataArray[_index - 1];
        NSString *rightAnswer = guessModel.answer;
        
        // 5.3.2.1 取出当前的金币数量
        NSInteger currentCoin = _coinButton.currentTitle.integerValue;
        // 5.3 进行比较
        if ([userAnswer isEqualToString:rightAnswer]) {
            /**
             用户输入正确

             1. 自动的跳入下一题
             2. 增加100 金币
             */
            /********  答案正确播放音效  ********/
            //1.获取音效文件
            NSString *path = [[NSBundle mainBundle]pathForResource:@"你真棒.mp3" ofType:nil];
            NSURL *url = [NSURL fileURLWithPath:path];
            SystemSoundID soundID = 0;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
            AudioServicesPlaySystemSound(soundID);
            //播放提示
            
            // 1. 实例化UIAlertController , ios7 UIAlertView
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"答对了！" message:@"你真厉害(ง •̀_•́)ง" preferredStyle:UIAlertControllerStyleAlert];
            
                              // 3. 展示alert
                    [self presentViewController:alertController animated:YES completion:nil];
             [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(creatAlert:) userInfo:alertController repeats:NO];
            
            
            
            // 5.3.1 自动跳入下一题
            [self performSelector:@selector(didClickNextButton:) withObject:nil afterDelay:1];
            
            /**
             5.3.2 增加100金币
             1. 取出当前的金币数量
             2. 更新(加/减)
             3. 赋值回去
             */
            // 5.3.2.1 增加100金币
            currentCoin += 1000;
            
        } else {
            /**
             用户输入不正确
             
             1. 答案区域文本的字体变红
             2. 减少1000金币
             */
            
            // 5.3.1 当用户输入错误, 答案区域的文字变为红色
            [_answerview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIButton *answerButton = obj;
                
                [answerButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                
            }];
            

            // 5.3.2.2 减少1000金币
            currentCoin -= 1000;
        }
        
        // 5.3.2.3 把修改过的金币数量赋值给  _coinButotn
        NSString *coinString = [NSString stringWithFormat:@"%ld",currentCoin];
        
        [_coinButton setTitle:coinString forState:UIControlStateNormal];
    }
}

-(void)creatAlert:(NSTimer * )timer{
    UIAlertController *alertController = [timer userInfo];
    [alertController dismissViewControllerAnimated:YES completion:nil];
    alertController = nil;
}


#pragma mark - 点击提示按钮
- (IBAction)didClickTipButton:(id)sender {
    
    /**
     1. 减去1000金币
     2. 取出正确答案的第一个字
     3. 在答案区域的第一个button上显示 第一个字, 其他按钮文本清空
     4. 选项区域中, 只有第一字对应的button隐藏, 其他的显示出来
     5. 答案区域的文本要变为黑色
     6. 允许选项区域用户交互
     7. 对用户的金币数量做判断, 如果不够减就提示用户
     */
    
    // 1. 减去1000金币
    // 1.1 取出当前的金币数量
    NSInteger currentCoin = _coinButton.currentTitle.integerValue;
    
    // 1.2 减去1000
    currentCoin -= 100;
    
    // 7. 判断金币数量
//    if (currentCoin < 0) {
//        // 1. 实例化UIAlertController , ios7 UIAlertView
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"亲,你的钱不够了" preferredStyle:UIAlertControllerStyleAlert];
//        
//        // 2. 添加按钮
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//        
//        // 2.1 添加action 到 alertController
//        [alertController addAction:cancelAction];
//        
//        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"爹去了" style:UIAlertActionStyleDefault handler:nil];
//        
//        [alertController addAction:sureAction];
//        
//        
//        // 3. 展示alert
//        [self presentViewController:alertController animated:YES completion:nil];
//        
//        return;
//    }
    
    // 1.3 赋值回去
    NSString *coinString = [NSString stringWithFormat:@"%ld", currentCoin];
    [_coinButton setTitle:coinString forState:UIControlStateNormal];
    
    // 2. 取出正确答案的第一个字
    // 2.1 先取出正确答案
    MUModel *guessModel = self.dataArray[_index - 1];
    NSString *rightAnswer = guessModel.answer;
    
    // 2.2 取第一个字
    NSString *firstString = [rightAnswer substringToIndex:1];
    
    // 3. 答案区域第一个按钮显示 firstString , 其他按钮的文本清空掉
    [_answerview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *answerButton = obj;
        
        if (idx == 0) { // 第一个button , 设置正确答案的第一个字
            [answerButton setTitle:firstString forState:UIControlStateNormal];
        } else { // 如果不是第一个按钮, 就直接清空文本
            [answerButton setTitle:@"" forState:UIControlStateNormal];
        }
        
    }];
    
    // 4. 选项区域中和第一个字对应的button隐藏, 其他的全部显示
    [_optionView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *optionButton = obj;
        
        if ([optionButton.currentTitle isEqualToString:firstString]) {
            // 如果字符串相等, 就把button隐藏
            optionButton.hidden = YES;
        } else {
            // 不等的话就显示出来
            optionButton.hidden = NO;
        }
    }];
    
    // 5. 修改答案区域文本颜色为黑色
    [_answerview.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *answerButton = obj;
        
        [answerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }];
    
    // 6. 允许选项区域的用户交互
    _optionView.userInteractionEnabled = YES;
}
#pragma mark -
#pragma mark -  点击"下一题"按钮
- (IBAction)didClickNextButton:(id)sender {
    
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
    _optionView.userInteractionEnabled = YES;
    
}
@end
