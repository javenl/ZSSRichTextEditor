//
// MP3Converter
//
// Created by nick on 13-1-7.
// Copyright (c) 2012年 ToraySoft. All rights reserved.
// 

#import "MP3Converter.h"
#import "lame.h"

@implementation MP3Converter

+ (void)compressWith:(NSString *)inputFilePath andOutputAt:(NSString *)outputFilePath {
    int read, write;

    FILE *pcm = fopen([inputFilePath cStringUsingEncoding:1], "rb");    //source
    fseek(pcm, 4 * 1024, SEEK_CUR);                                     //skip file header
    FILE *mp3 = fopen([outputFilePath cStringUsingEncoding:1], "wb");   //output

    const int PCM_SIZE = 8192;
    const int MP3_SIZE = 8192;
    short int pcm_buffer[PCM_SIZE * 2];
    unsigned char mp3_buffer[MP3_SIZE];

    lame_t lame = lame_init();
    lame_set_num_channels(lame, 1);
    lame_set_in_samplerate(lame, 2 * 11025);
    lame_set_out_samplerate(lame, 2 * 11025);
    lame_set_brate(lame, 128);
    lame_set_quality(lame, 5);
    lame_set_mode(lame, STEREO);
    lame_set_VBR(lame, vbr_default);
    lame_init_params(lame);

    do {
        read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
        if (read == 0)
            write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        else
            write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
        fwrite(mp3_buffer, write, 1, mp3);
    } while (read != 0);

    lame_close(lame);
    fclose(mp3);
    fclose(pcm);
}

+ (void)compressWith:(NSString *)inputFilePath inSampleRate:(NSUInteger)sampleRate andOutputAt:(NSString *)outputFilePath{
    int read, write;
    
    FILE *pcm = fopen([inputFilePath cStringUsingEncoding:1], "rb");    //source
    fseek(pcm, 4 * 1024, SEEK_CUR);                                     //skip file header
    FILE *mp3 = fopen([outputFilePath cStringUsingEncoding:1], "wb");   //output
    
    const int PCM_SIZE = 8192;
    const int MP3_SIZE = 8192;
    short int pcm_buffer[PCM_SIZE * 2];
    unsigned char mp3_buffer[MP3_SIZE];
    
    lame_t lame = lame_init();
    lame_set_num_channels(lame, 1);
    lame_set_in_samplerate(lame, sampleRate);
    lame_set_out_samplerate(lame, 2 * 11025);
    lame_set_brate(lame, 128);
    lame_set_quality(lame, 5);
    lame_set_mode(lame, STEREO);
    lame_set_VBR(lame, vbr_default);
    lame_init_params(lame);
    
    do {
        read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
        if (read == 0)
            write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        else
            write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
        fwrite(mp3_buffer, write, 1, mp3);
    } while (read != 0);
    
    lame_close(lame);
    fclose(mp3);
    fclose(pcm);
}

@end