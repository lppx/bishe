//
//  MUModel.h
//  视频播放
//
//  Created by lpx on 16/4/10.
//  Copyright (c) 2016年 lpx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUModel : NSObject


@property (nonatomic, copy) NSString *answer;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *moviename;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) NSArray *options;

@property (nonatomic, strong) NSNumber *frames;

@property (nonatomic, strong) NSString *imageFormat;

// 对象方法
- (instancetype)initWithDict:(NSDictionary *)dict;

// 类方法
+ (instancetype)guessModelDict:(NSDictionary *)dict;
// 类方法
+ (instancetype)dataModelDict:(NSDictionary *)dict;

@end
