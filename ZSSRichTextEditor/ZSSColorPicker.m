//
//  ZSSColorPicker.m
//  ZSSRichTextEditor
//
//  Created by liu on 15-6-17.
//  Copyright (c) 2015年 Zed Said Studio. All rights reserved.
//

#import "ZSSColorPicker.h"
#import "HRColorPickerView.h"
#import "HRColorMapView.h"
#import "HRBrightnessSlider.h"


@interface ZSSColorPicker ()

@property (strong, nonatomic) HRColorPickerView *colorPickerView;
@property (strong, nonatomic) HRColorMapView *colorMapView;
@property (weak, nonatomic) HRBrightnessSlider *colorSilder;
@property (strong, nonatomic, readwrite) UIColor *currentColor;
@property (strong, nonatomic) UIColor *originColor;

@end

@implementation ZSSColorPicker

- (id)initWithColor:(UIColor *)color {
    self = [super init];
    if (self) {
        self.originColor = color;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"颜色选择";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(didTapCancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(didTapFinish)];
    
    self.colorPickerView = [[HRColorPickerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-64)];
    [self.colorPickerView addTarget:self action:@selector(didColorChange:) forControlEvents:UIControlEventValueChanged];
//    self.colorPickerView.color = self.originColor ? self.originColor : [UIColor colorWithRed:1/255.0 green:1/255.0 blue:1/255.0 alpha:1.0];
    self.colorPickerView.color = self.originColor ? self.originColor : [UIColor whiteColor];
    
    self.colorMapView = (HRColorMapView *) self.colorPickerView.colorMapView;
    
    self.colorSilder = (HRBrightnessSlider *) self.colorPickerView.brightnessSlider;
    self.colorSilder.brightnessLowerLimit = @(0);
    
    [self.view addSubview:self.colorPickerView];
    
    self.colorMapView.tileSize = @(1);
}

#pragma mark - Event

- (void)didColorChange:(HRColorPickerView *)colorPickerView {
    UIColor *color = colorPickerView.color;
//    NSLog(@"%@", color);
    self.currentColor = color;
}

- (void)didTapCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapFinish {
    [self.delegate colorPicker:self didPickerColor:self.currentColor];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
