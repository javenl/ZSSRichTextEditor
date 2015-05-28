//
//  JsonSerialization.m
//  music
//
//  Created by liu on 15-2-11.
//  Copyright (c) 2015年 toraysoft. All rights reserved.
//

#import "JsonSerialization.h"

@implementation NSString (JsonSerialization)

-(id) toMutableJsonObject {
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return nil;
    } else {
        return result;
    }
}

-(id) toJsonObject {
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        return nil;
    } else {
        return result;
    }
}

- (NSArray *) toJsonArray {
    id result = [self toJsonObject];
    if ([result isKindOfClass:[NSArray class]]) {
        return result;
    } else {
        return nil;
    }
}

- (NSDictionary *) toJsonDictionary {
    id result = [self toJsonObject];
    if ([result isKindOfClass:[NSDictionary class]]) {
        return result;
    } else {
        return nil;
    }
}

@end

@implementation NSDictionary (JsonSerialization)

- (NSString *) toJsonString {
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return nil;
    } else {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

@end

@implementation NSArray (JsonSerialization)

- (NSString *) toJsonString {
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return nil;
    } else {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

@end
