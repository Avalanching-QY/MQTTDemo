//
//  MessageFactory.m
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/28.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import "MessageFactory.h"

static MessageFactory *factory = nil;

@interface MessageFactory ()

@property (nonatomic, strong) MqttMessageBody_UserInfoBody *from;

@property (nonatomic, strong) MqttMessageBody_UserInfoBody *to;

@end

@implementation MessageFactory

+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factory = [[MessageFactory alloc] init];
    });
    return factory;
}

- (void)addLogin:(MqttMessageBody_UserInfoBody *)login {
    self.from = login;
}

- (void)contactsObject:(MqttMessageBody_UserInfoBody *)to {
    self.to = to;
}

- (MqttMessageBody *)getMessageWithContent:(NSString *)content {
    MqttMessageBody *message = [[MqttMessageBody alloc] init];
    message.content = content;
    message.num = (int32_t) content.length;
    message.fromid = self.from.userid;
    message.toid = self.to.userid;
    
    message.from = self.from;
    message.to = self.to;
    return message;
}

- (MqttMessageBody *)analysisMessageWithData:(NSData *)data {
    NSError *error = nil;
    MqttMessageBody *body = [[MqttMessageBody alloc] initWithData:data error:&error];
    if (!error) {
        NSLog(@"解析出来的对象: %@", body);
    } else {
        NSLog(@"解析失败了:%@", error);
    }
    return  body;
}
@end
