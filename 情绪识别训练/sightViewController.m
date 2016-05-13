//
//  sightViewController.m
//  情绪识别训练
//
//  Created by lpx on 16/3/16.
//  Copyright (c) 2016年 lpx. All rights reserved.
//

#import "sightViewController.h"

@interface sightViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imaView;
@property(nonatomic, strong) NSData *fileData;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;


@end

@implementation sightViewController

int count = 0; //计数

//返回菜单
- (IBAction)backBtnClick:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark - 修改状态栏样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    // 把statusBar的样式修改为白色
    return UIStatusBarStyleLightContent;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //换行
    _showLabel.lineBreakMode = UILineBreakModeWordWrap;
    _showLabel.numberOfLines = 0;
    
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Bg-02.png"]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:@"selfPhoto.jpg"];
    NSLog(@"imageFile->>%@",imageFilePath);
    UIImage *selfPhoto = [UIImage imageWithContentsOfFile:imageFilePath];//
    self.imaView.image = selfPhoto;
    [self.imaView.layer setCornerRadius:CGRectGetHeight([self.imaView bounds]) / 10];//修改半径
    self.imaView.layer.masksToBounds = YES;
    _showLabel.text = @"请拍一张高兴的人脸照片";
    count=0;//防止再次载入的时候 点击正确按钮无反应
    
}

- (IBAction)btnClik:(UIButton *)sender {
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择文件来源"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"照相机",@"本地相簿",nil];
    [actionSheet showInView:self.view];
}
- (IBAction)xiugai:(UIButton *)sender {
    
    
    [self.imaView setHidden:YES];
 

}

- (IBAction)zhengque:(UIButton *)sender {
       count =count+1;
    switch (count) {
        case 1:
       _showLabel.text=@"请拍一张高兴的照片1";
            break;
        case 2:
           _showLabel.text=@"请拍一张悲伤的照片2";
            break;
        case 3:
       _showLabel.text=@"请拍一张悲伤的照片3";
            break;
        case 4:
        _showLabel.text=@"请拍一张悲伤的照片4";
            break;
        case 5:
            _showLabel.text=@"请拍一张悲伤的照片5";
            break;
        case 6:
          _showLabel.text=@"请拍一张悲伤的照片6";
            break;
        case 7:
         _showLabel.text=@"请拍一张悲伤的照片7";
            break;
        default:
            _showLabel.text=@"跟爸爸或妈妈合照一张，结束今天的训练！";

            break;
    }
    
}
#pragma mark -
#pragma UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // NSLog(@"buttonIndex = [%d]",buttonIndex);
    switch (buttonIndex) {
        case 0://照相机
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //            [self presentModalViewController:imagePicker animated:YES];
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        case 1://本地相簿
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //            [self presentModalViewController:imagePicker animated:YES];
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        [self performSelector:@selector(saveImage:)  withObject:img afterDelay:0.5];
    }
    else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(__bridge NSString *)kUTTypeMovie]) {
        NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        self.fileData = [NSData dataWithContentsOfFile:videoPath];
    }
    //    [picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)saveImage:(UIImage *)image {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:@"selfPhoto.jpg"];
    NSLog(@"imageFile->>%@",imageFilePath);
    success = [fileManager fileExistsAtPath:imageFilePath];
    if(success) {
        success = [fileManager removeItemAtPath:imageFilePath error:&error];
    }
    //    UIImage *smallImage=[self scaleFromImage:image toSize:CGSizeMake(80.0f, 80.0f)];//将图片尺寸改为80*80
    UIImage *smallImage = [self thumbnailWithImageWithoutScale:image size:CGSizeMake(300, 300)];
    [UIImageJPEGRepresentation(smallImage, 1.0f) writeToFile:imageFilePath atomically:YES];//写入文件
    UIImage *selfPhoto = [UIImage imageWithContentsOfFile:imageFilePath];//读取图片文件
    self.imaView.image = selfPhoto;
}





- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //    [picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


//2.保持原来的长宽比，生成一个缩略图
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
          [self.imaView setHidden:NO];  //点击修改button的时候imgview不可见  在这里回复可见
    
    return newimage;
 
    
    
    
}


@end
