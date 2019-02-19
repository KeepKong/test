//
//  Sington.h
//  SZAudioTool
//
//  Created by KnowChat01 on 2019/2/15.
//  Copyright © 2019年 KeepKong. All rights reserved.
//

#ifndef Sington_h
#define Sington_h

#define singtonInterface + (instancetype)shareInstance;

#define singtonImplement(class)\
\
+ (instancetype)shareInstance\
{\
    static class *shareInstance;\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        shareInstance = [[class alloc] init];\
    });\
    return shareInstance;\
}

#endif /* Sington_h */
