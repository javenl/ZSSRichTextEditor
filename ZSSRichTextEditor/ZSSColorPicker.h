//
//  ZSSColorPicker.h
//  ZSSRichTextEditor
//
//  Created by liu on 15-6-17.
//  Copyright (c) 2015年 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSSColorPicker;

@protocol ZSSColorPickerDelegate <NSObject>

- (void)colorPicker:(ZSSColorPicker *)colorPicker didPickerColor:(UIColor *)color;

@end

@interface ZSSColorPicker : UIViewController

@property (weak, nonatomic) id <ZSSColorPickerDelegate> delegate;
@property (strong, nonatomic, readonly) UIColor *currentColor;

- (id)initWithColor:(UIColor *)color;

@end
