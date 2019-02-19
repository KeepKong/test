//
//  SZAudioPlayerTool.h
//  SZAudioTool
//
//  Created by KnowChat01 on 2019/2/15.
//  Copyright © 2019年 KeepKong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Sington.h"

@interface SZAudioPlayerTool : NSObject
singtonInterface

/**
 播放指定路径下的音频文件

 @param audioPath 音频文件路径
 @return 播放器对象
 */
- (AVAudioPlayer *)playAudioWithPath:(NSString *)audioPath;

/**
 暂停播放
 */
- (void)pausePlay;

/**
 恢复播放
 */
- (void)resumePlay;

/**
 停止播放
 */
- (void)stopPlay;

/**
 设置音量

 @param volume 音量
 */
- (void)setupVolume:(float)volume;

/**
 获取播放进度

 @return 播放进度
 */
- (CGFloat)fetchProgress;
@end


