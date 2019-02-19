//
//  SZAudioTool.h
//  SZAudioTool
//
//  Created by KeepKong on 2019/2/14.
//  Copyright © 2019 KeepKong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Sington.h"

typedef void(^CompleteBlock)(NSString *path);

@interface SZAudioTool : NSObject

@property(nonatomic , copy)NSString *recordPath;
@property (nonatomic , copy)CompleteBlock completeBlock;

singtonInterface;

/**
 开始录音
 
 @param path 录音保存的位置
 @param complete 完成之后的回调
 */
- (void)beginRecordAudioToPath:(NSString *)path completeBlock:(CompleteBlock)complete;
/**
 结束录音
 */
- (void)endRecord;
/**
 暂停录音
 */
- (void)pauseRecord;
/**
 从暂停恢复录音
 */
- (void)resumeRecord;
/**
 重新录音
 */
- (void)reRecord;
/**
 删除录音
 */
- (void)deleteRecord;

#pragma mark - 拼接、剪切音频文件
/**
 拼接两个音频文件，fromPath拼接到toPath的音频中
 
 @param fromPath 原音频路径
 @param toPath 目标音频路径
 @param outputPath 拼接后的音频路径
 */
+ (void)addAudio:(NSString *)fromPath toAudio:(NSString *)toPath outputPath:(NSString *)outputPath;
/**
 通过指定起始时间和终止时间来剪切一个音频文件
 
 @param audioPath 音频文件路径
 @param fromTime 起始时间
 @param toTime 终止时间
 @param outputPath 剪切后的音频文件
 */
+ (void)cutAudio:(NSString *)audioPath fromTime:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime outputPath:(NSString *)outputPath;
@end
