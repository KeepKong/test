//
//  SZAudioPlayerTool.m
//  SZAudioTool
//
//  Created by KnowChat01 on 2019/2/15.
//  Copyright © 2019年 KeepKong. All rights reserved.
//

#import "SZAudioPlayerTool.h"

@interface SZAudioPlayerTool ()

@property (nonatomic , strong)AVAudioPlayer *audioPlayer;

@end

@implementation SZAudioPlayerTool
singtonImplement(SZAudioPlayerTool)

- (AVAudioPlayer *)playAudioWithPath:(NSString *)audioPath
{
    NSURL *url = [NSURL fileURLWithPath:audioPath];
    if (!url)
    {
        NSLog(@"音频文件路径错误！");
        return nil;
    }
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error)
    {
        NSLog(@"初始化Player失败");
        return nil;
    }
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    return self.audioPlayer;
}

- (void)pausePlay
{
    if (self.audioPlayer)
    {
        [self.audioPlayer pause];
    }
}
- (void)resumePlay
{
    if (self.audioPlayer)
    {
        [self.audioPlayer play];
    }
}
- (void)stopPlay
{
    if (self.audioPlayer)
    {
        [self.audioPlayer stop];
    }
}
- (void)setupVolume:(float)volume
{
    if (self.audioPlayer)
    {
        [self.audioPlayer setVolume:volume];
    }
}
- (CGFloat)fetchProgress
{
    if (self.audioPlayer)
    {
        return self.audioPlayer.currentTime / self.audioPlayer.duration;
    }
    else
    {
        return 0.0;
    }
}
@end
