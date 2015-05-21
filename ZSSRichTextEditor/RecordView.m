//
//  RecordView.m
//  ZSSRichTextEditor
//
//  Created by liu on 15-5-20.
//  Copyright (c) 2015年 Zed Said Studio. All rights reserved.
//

#import "RecordView.h"
#import "UIAlertView+Blocks.h"
#import "MP3Converter.h"
#import "MaskView.h"

#define kScreenWidth [[UIScreen mainScreen] applicationFrame].size.width

@interface RecordView ()

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *recordBtn;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *useBtn;

//@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVAudioRecorder *recorder;

@property (strong, nonatomic) CADisplayLink *dispplayLink;

@property (strong, nonatomic) NSString *recordFilePath;
@property (strong, nonatomic) NSString *mp3FilePath;

@end

@implementation RecordView

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
//        UIView *recordBg = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.window.frame) - 200, CGRectGetWidth(self.view.window.frame), 200)];
//        recordBg.backgroundColor = [UIColor whiteColor];
//        [maskView addSubview:recordBg];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 150, 20)];
        self.timeLabel.center = CGPointMake(kScreenWidth/2, 20);
        self.timeLabel.text = @"00:00";
        self.timeLabel.textColor = [UIColor blackColor];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.timeLabel];
        
        self.recordBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        self.recordBtn.center = CGPointMake(self.center.x, 40*2);
        self.recordBtn.backgroundColor = [UIColor greenColor];
        self.recordBtn.layer.cornerRadius = 35;
        [self.recordBtn addTarget:self action:@selector(didTapRecord:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.recordBtn];
        
        self.cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 200-40, kScreenWidth/2, 40)];
        [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.cancelBtn.layer.borderWidth = 1;
        self.cancelBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.cancelBtn.backgroundColor = [UIColor whiteColor];
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(didTapCancel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelBtn];
        
        self.useBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.useBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2, 200-40, kScreenWidth/2, 40)];
        [self.useBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.useBtn.layer.borderWidth = 1;
        self.useBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.useBtn.backgroundColor = [UIColor whiteColor];
        [self.useBtn setTitle:@"使用" forState:UIControlStateNormal];
        [self.useBtn addTarget:self action:@selector(didTapUse) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.useBtn];
        
        AVAudioSession *avSession = [AVAudioSession sharedInstance];
        if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [avSession requestRecordPermission:^(BOOL available) {
                if (available) {
                    //completionHandler
                } else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:@"无法使用麦克风" message:@"你关闭了使用麦克风权限，请在“[设置]->[隐私]->[麦克风]”选项中允许访问你的麦克风，以正常使用此功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                    });
                }
            }];
        }
    }
    return self;
}

#pragma mark - Event

- (void)didTapRecord:(UIButton *)sender {
    if (!sender.isSelected) {
        sender.selected = YES;
        [self startRecord];
    } else {
        [self pauseRecord];
    }
}

- (void)didTapCancel {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.recordFilePath]) {
        [self cleanTmpFile];
        [self dismiss];
        if (self.cancelBlock) {
            self.cancelBlock();
        }
//        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [UIAlertView showWithTitle:@"" message:@"退出录音将被清空，确定要退出吗？" cancelButtonTitle:@"不了" otherButtonTitles:@[@"退出"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (_recorder) {
                    [self.recorder stop];
                }
//                if (_player) {
//                    [self.player stop];
//                }
                [self cleanTmpFile];
                [self dismiss];
//                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

- (void)didTapUse {
    if ([self convertFile]) {
        if (self.finishBlock) {
            self.finishBlock(self.mp3FilePath);
        }
        [self cleanTmpFile];
        [self dismiss];
//        NSArray *parts = [self.mp3FilePath componentsSeparatedByString:@"/"];
//        [self uploadFile:self.mp3FilePath bucket:kQiniuSoundBuket key:[parts lastObject]];
    } else {
        if (self.cancelBlock) {
            self.cancelBlock();
        }
        [self dismiss];
//        [self.hudView showFailtureAndText:@"格式转换失败"];
    }
}

- (void)didRecorderDisplayFire:(id)sender {
    NSInteger min = self.recorder.currentTime / 60;
    NSInteger sec = (NSInteger)self.recorder.currentTime % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (NSInteger)min, (NSInteger)sec];
}

#pragma mark - Method

- (void)addToViewWithAnimate:(UIView *)view {
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetHeight(view.bounds), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetHeight(view.bounds)-CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    } completion:^(BOOL finished) {

    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMaxY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)startRecord {
    //开麦克风
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryRecord error:&sessionError];
    if (!sessionError) {
        [session setActive:YES error:nil];
    } else {
        
    }
    [self.recorder record];
    self.dispplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(didRecorderDisplayFire:)];
    [self.dispplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.dispplayLink.frameInterval = 5;
}

- (void)pauseRecord {
    [self.recorder pause];
    [self.dispplayLink invalidate];
    self.dispplayLink = nil;
}

- (void)cleanTmpFile {
    if (self.mp3FilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.mp3FilePath error:nil];
    }
    if (self.recordFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.recordFilePath error:nil];
    }
}

//caf转换成mp3
- (BOOL)convertFile {
//    NIDPRINT(@"start");
    @try {
        NSString *path = [NSString stringWithFormat:@"record_tmp_%f.%@", [[NSDate date] timeIntervalSince1970], @"mp3"];
        self.mp3FilePath = [NSTemporaryDirectory() stringByAppendingString:path];
        [MP3Converter compressWith:self.recordFilePath inSampleRate:11025.0 * 4 andOutputAt:self.mp3FilePath];
        return YES;
//        NIDPRINT(@"convert finish");
    }
    @catch (NSException *exception) {
//        NIDPRINT(@"%@", [exception description]);
        return NO;
    }
}

#pragma mark - AVAudioRecoder Delegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [self.dispplayLink invalidate];
    self.dispplayLink = nil;
}

#pragma mark - AVAudioPlay Delegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    /*
    [self.playBtn setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
    [self.recordBgImageView.layer removeAllAnimations];
    [self refreshTimeLabel:2];
    [self.dispplayLink invalidate];
    self.dispplayLink = nil;
    */
}

#pragma mark - Property
/*
- (NSString *)mp3FilePath {
    if (!_mp3FilePath) {
//        MUUser *user = [AuthenticationManager authenticatedUser];
        NSString *path = [NSString stringWithFormat:@"record_tmp_%f.%@", [[NSDate date] timeIntervalSince1970], @"mp3"];
        _mp3FilePath = [NSTemporaryDirectory() stringByAppendingString:path];
    }
    return _mp3FilePath;
}
*/
/*
- (NSString *)recordFilePath {
    if (!_recordFilePath) {
        _recordFilePath = [NSTemporaryDirectory() stringByAppendingFormat:@"record_tmp.caf"];
    }
    return _recordFilePath;
}
*/
/*
- (AVAudioPlayer *)player {
    if (!_player) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.recordFilePath] error:nil];
        _player.delegate = self;
        [_player prepareToPlay];
    }
    return _player;
}
*/
- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:11025.0 * 4], AVSampleRateKey,
                                  [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                  [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                  [NSNumber numberWithInt:AVAudioQualityMedium], AVEncoderAudioQualityKey,
                                  nil];
        self.recordFilePath = [NSTemporaryDirectory() stringByAppendingFormat:@"record_tmp.caf"];
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.recordFilePath] settings:settings error:nil];
        _recorder.delegate = self;
    }
    return _recorder;
}

#pragma mark - static Method

+ (RecordView *)showInView:(UIView *)view finish:(FinishBlock)finishBlock {
    RecordView *recordView = [RecordView new];
    
    __weak RecordView *weakRecordView = recordView;
    MaskView *maskView = [MaskView showInView:view dissmissBlock:^{
        [weakRecordView dismiss];
    }];
    
    [recordView addToViewWithAnimate:maskView];
    
    [recordView setFinishBlock:finishBlock];
    [recordView setCancelBlock:^() {
        [maskView removeViewWithAnimate:YES];
    }];
    
    return recordView;
}


@end
