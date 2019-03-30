//
//  MQTTUserInfo.h
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/27.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MQTTUserInfo : NSObject

@property (nonatomic, strong, readonly) NSString *username;

@property (nonatomic, strong, readonly) NSString *password;

@property (nonatomic, strong, readonly) NSString *clientId;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
