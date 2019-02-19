//
//  SZAudioTool.m
//  SZAudioTool
//
//  Created by KeepKong on 2019/2/14.
//  Copyright © 2019 KeepKong. All rights reserved.
//

#import "SZAudioTool.h"


@interface SZAudioTool()<AVAudioRecorderDelegate>
//------------录音
@property(nonatomic , strong)AVAudioRecorder *audioRecorder;

//------------

@end


@implementation SZAudioTool

singtonImplement(SZAudioTool)

#pragma mark -LazyLoad
- (AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder)
    {
        NSError *error = nil;
        //0.设置音频会话
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (error)
        {
            NSLog(@"Category设置失败");
            return nil;
        }
        [[AVAudioSession sharedInstance] setActive:true error:&error];
        if (error)
        {
            NSLog(@"会话激活失败");
            return nil;
        }
        //1.获取录音存放的位置
        NSURL *outputUrl = [NSURL fileURLWithPath:_recordPath];
        
        //2.设置录音的参数
        NSMutableDictionary *paramsMuDict = [NSMutableDictionary dictionary];
        //设置编码格式
        [paramsMuDict setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];//kAudioFormatLinearPCM对应格式为caf
        //采样率
        [paramsMuDict setValue:[NSNumber numberWithFloat:22050.0] forKey:AVSampleRateKey];//11025.0
        //通道数
        [paramsMuDict setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        //音频质量
        [paramsMuDict setValue:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
        
        //3.创建录音对象
//        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputUrl format:<#(nonnull AVAudioFormat *)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>];
        NSError *audioError = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputUrl settings:paramsMuDict error:&audioError];
        if (audioError || !_audioRecorder)
        {
            NSLog(@"初始化Recorder失败");
            return nil;
        }
        _audioRecorder.meteringEnabled = true;
        _audioRecorder.delegate = self;
        [_audioRecorder prepareToRecord];

    }
    return _audioRecorder;
}
#pragma mark -录音相关
/**
 开始录音

 @param path 录音保存的位置
 @param complete 完成之后的回调
 */
- (void)beginRecordAudioToPath:(NSString *)path completeBlock:(CompleteBlock)complete
{
    _recordPath = path;
    _completeBlock = complete;
    if (self.audioRecorder)
    {
        [self.audioRecorder record];
    }
}

/**
 结束录音
 */
- (void)endRecord
{
    [self.audioRecorder stop];
}
/**
 暂停录音
 */
- (void)pauseRecord
{
    [self.audioRecorder pause];
}
/**
 从暂停恢复录音
 */
- (void)resumeRecord
{
    [self.audioRecorder record];
}
/**
 重新录音
 */
- (void)reRecord
{
    self.audioRecorder.delegate = nil;
    self.audioRecorder = nil;
    [self beginRecordAudioToPath:_recordPath completeBlock:_completeBlock];
}
/**
 删除Recorder中对应文件目录下的录音
 */
- (void)deleteRecord
{
    [self.audioRecorder stop];
    BOOL isSuccess = false;
    isSuccess = [self.audioRecorder deleteRecording];
    if (isSuccess)
    {
        NSLog(@"删除成功");
    }
    else
    {
        NSLog(@"删除失败");
    }
}
#pragma mark -AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"录音结束");
    if (flag && self.completeBlock)
    {
        self.completeBlock(_recordPath);
    }
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    NSLog(@"EncodeError = %@" , error);
}

#pragma mark - 拼接、剪切音频文件

/**
 拼接两个音频文件，fromPath拼接到toPath的音频中

 @param fromPath 原音频路径
 @param toPath 目标音频路径
 @param outputPath 拼接后的音频路径
 */
+ (void)addAudio:(NSString *)fromPath toAudio:(NSString *)toPath outputPath:(NSString *)outputPath
{
    NSURL *fromUrl = [NSURL fileURLWithPath:fromPath];
    NSURL *toUrl = [NSURL fileURLWithPath:toPath];
    NSURL *outputUrl = [NSURL fileURLWithPath:outputPath];
    if (!fromUrl || !toUrl || !outputUrl)
    {
        NSLog(@"音频路径错误！！");
        return;
    }
    
    //1.获取两个音频源
    AVURLAsset *fromAsset = [AVURLAsset assetWithURL:fromUrl];
    AVURLAsset *toAsset = [AVURLAsset assetWithURL:toUrl];
    
    //2.分别获取两个音频源的音频轨道素材
    AVAssetTrack *fromAssetTrack = [[fromAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *toAssetTrack = [[toAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
//    NSLog(@"fromAssetTrack = %@" , fromAssetTrack);
    
    //3.创建合成器，用于生成一个可编辑音频轨道，合成两个音频轨道
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    
    //4.向轨道合成器中添加音频轨道素材
    NSError *error = nil;
    [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, toAsset.duration) ofTrack:toAssetTrack atTime:kCMTimeZero error:&error];
    if (error)
    {
        NSLog(@"添加音频轨道1失败");
        return;
    }
    [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, fromAsset.duration) ofTrack:fromAssetTrack atTime:toAsset.duration error:&error];
    if (error)
    {
        NSLog(@"添加音频轨道2失败");
        return;
    }
    
    //5.导出音频结果
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.outputURL = outputUrl;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status)
        {
            case AVAssetExportSessionStatusExporting:
                NSLog(@"导出中....");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"导出完成");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"导出失败");
                break;
            default:
                NSLog(@"导出失败！！！");
                break;
        }
    }];
}

/**
 通过指定起始时间和终止时间来剪切一个音频文件

 @param audioPath 音频文件路径
 @param fromTime 起始时间
 @param toTime 终止时间
 @param outputPath 剪切后的音频文件
 */
+ (void)cutAudio:(NSString *)audioPath fromTime:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime outputPath:(NSString *)outputPath
{
    NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
    NSURL *outputUrl = [NSURL fileURLWithPath:outputPath];
    if (!audioUrl || !outputUrl)
    {
        NSLog(@"文件路径错误");
        return;
    }
    
    //1.获取音频资源
    AVAsset *asset = [AVAsset assetWithURL:audioUrl];
    
    //2.创建一个会话，进行相关配置
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.outputURL = outputUrl;
    CMTime startTime = CMTimeMake(fromTime, 1);
    CMTime endTime = CMTimeMake(toTime, 1);
    
//    CMTime startTime1 = CMTimeMakeWithSeconds(fromTime, 1);//这个方法有问题
//    CMTime endTime = CMTimeMakeWithSeconds(toTime, 1);
    exportSession.timeRange = CMTimeRangeFromTimeToTime(startTime, endTime);
    
    //3.导出音频
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status)
        {
            case AVAssetExportSessionStatusExporting:
                NSLog(@"导出中....");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"导出成功");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"导出失败");
                break;
            default:
                NSLog(@"导出失败！！！");
                break;
        }
    }];
}
@end
