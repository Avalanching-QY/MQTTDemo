//
//  MQTTUserInfo.m
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/27.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import "MQTTUserInfo.h"


@interface MQTTUserInfo ()

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *clientId;

@end

@implementation MQTTUserInfo

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    MQTTUserInfo *userinfo = [[MQTTUserInfo alloc] init];
    @try {
        [userinfo setValuesForKeysWithDictionary:dict];
    } @catch (NSException *exception) {
        NSLog(@"set value is faliure");
    } @finally {
        return userinfo;
    }
}

@end
