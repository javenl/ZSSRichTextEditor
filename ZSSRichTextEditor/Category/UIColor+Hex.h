//
//  UIColor+Hex.h
//  ZSSRichTextEditor
//
//  Created by liu on 15-6-17.
//  Copyright (c) 2015年 Zed Said Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)color;

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
