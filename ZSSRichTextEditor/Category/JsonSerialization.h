//
//  JsonSerialization.h
//  music
//
//  Created by liu on 15-2-11.
//  Copyright (c) 2015年 toraysoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JsonSerialization)

- (id)toMutableJsonObject;
- (id)toJsonObject;
- (NSArray *)toJsonArray;
- (NSDictionary *)toJsonDictionary;

@end

@interface NSDictionary(JsonSerialization)

- (NSString *)toJsonString;

@end

@interface NSArray(JsonSerialization)

- (NSString *)toJsonString;

@end