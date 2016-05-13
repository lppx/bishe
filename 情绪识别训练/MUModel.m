//
//  MUModel.m
//  视频播放
//
//  Created by lpx on 16/4/10.
//  Copyright (c) 2016年 lpx. All rights reserved.
//

#import "MUModel.h"

@implementation MUModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        //        self.answer = dict[@"answer"];
        // kvc
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)guessModelDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

+ (instancetype)dataModelDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

@end
