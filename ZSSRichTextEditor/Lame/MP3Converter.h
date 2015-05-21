//
// MP3Converter
//
// Created by nick on 13-1-7.
// Copyright (c) 2012年 ToraySoft. All rights reserved.
// 



#import <Foundation/Foundation.h>


@interface MP3Converter : NSObject

+ (void)compressWith:(NSString *)inputFilePath andOutputAt:(NSString *)outputFilePath;

+ (void)compressWith:(NSString *)inputFilePath inSampleRate:(NSUInteger)sampleRate andOutputAt:(NSString *)outputFilePath;

@end