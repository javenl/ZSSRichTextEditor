//
//  RecordView.h
//  ZSSRichTextEditor
//
//  Created by liu on 15-5-20.
//  Copyright (c) 2015年 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^CancelBlock)();
typedef void(^FinishBlock)(NSString *path);

@interface RecordView : UIView <AVAudioRecorderDelegate>

@property (strong, nonatomic) FinishBlock finishBlock;
@property (strong, nonatomic) CancelBlock cancelBlock;

+ (RecordView *)showInView:(UIView *)view finish:(FinishBlock)finishBlock;

@end
