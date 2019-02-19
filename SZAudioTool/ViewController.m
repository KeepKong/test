//
//  ViewController.m
//  SZAudioTool
//
//  Created by KeepKong on 2019/2/14.
//  Copyright © 2019 KeepKong. All rights reserved.
//

#import "ViewController.h"
#import "SZAudioTool.h"
#import "SZAudioPlayerTool.h"
//#import "SZAudioTool/Transcode/LameTool.h"
//#import "LameTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [SZAudioTool addAudio:[self fetchFilePathWithName:@"test.m4a"] toAudio:[self fetchFilePathWithName:@"test1.m4a"] outputPath:[self fetchFilePathWithName:@"result.m4a"]];
//    [SZAudioTool cutAudio:[self fetchFilePathWithName:@"result.m4a"] fromTime:0 toTime:5 outputPath:[self fetchFilePathWithName:@"cut.m4a"]];//
    
    
    //使用lame将m4a格式压缩并转成mp3格式
//    [LameTool audioToMP3:[self fetchFilePathWithName:@"test1.caf"] isDeleteSourchFile:false];
}

#pragma mark - 获取文件存放的目录
- (NSString *)fetchFilePathWithName:(NSString *)name
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) firstObject];
    path = [path stringByAppendingPathComponent:name];
    
    return path;
}

#pragma mark - Action

- (IBAction)startRecordAction:(UIButton *)sender {
    NSString *filePath = [self fetchFilePathWithName:@"test1.caf"];
//    NSLog(@"filePath = %@" , filePath);
    [[SZAudioTool shareInstance] beginRecordAudioToPath:filePath completeBlock:^(NSString *path) {
        NSLog(@"path = %@" , path);
    }];
}
- (IBAction)endRecordAction:(UIButton *)sender {
    [[SZAudioTool shareInstance] endRecord];
}
- (IBAction)pauseRecord:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        [sender setTitle:@"继续录音" forState:UIControlStateNormal];
        [[SZAudioTool shareInstance] pauseRecord];
    }
    else
    {
        [sender setTitle:@"暂停录音" forState:UIControlStateNormal];
        [[SZAudioTool shareInstance] resumeRecord];
    }
}
- (IBAction)reRecord:(UIButton *)sender {
    [[SZAudioTool shareInstance] reRecord];
}
- (IBAction)deleteRecording:(UIButton *)sender {
    [[SZAudioTool shareInstance] deleteRecord];
}
- (IBAction)playRecord:(UIButton *)sender {
//    NSLog(@"player = %@" , [SZAudioPlayerTool shareInstance]);
    [self endRecordAction:nil];
    [[SZAudioPlayerTool shareInstance] playAudioWithPath:[self fetchFilePathWithName:@"test.m4a"]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
