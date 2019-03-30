//
//  MessageFactory.h
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/28.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MqttMessageBody.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageFactory : NSObject

@property (nonatomic, strong, readonly) MqttMessageBody_UserInfoBody *from;

@property (nonatomic, strong, readonly) MqttMessageBody_UserInfoBody *to;

/**
 @method share
 @abstrac 消息管理的单例
 @result MessageFactory
 */
+ (instancetype)share;

/**
 @method addLogin:
 @abstrac 增加login者，这里仅有两个账号 avalanching1 & avalanching2
 @discussion 连接服务器
 @param login MqttMessageBody_UserInfoBody *
 */
- (void)addLogin:(MqttMessageBody_UserInfoBody *)login;

/**
 @method contactsObject:
 @abstrac 聊天天对话，这里仅有两个账号 avalanching1 & avalanching2 如果avalanching1登陆，则avalanching2为聊天对象
 @discussion 链接对话者
 @param to MqttMessageBody_UserInfoBody *
 */
- (void)contactsObject:(MqttMessageBody_UserInfoBody *)to;


/**
 @method getMessageWithContent:
 @abstrac 传入一个对话，获取一个消息体
 @discussion 获取对话的结构体，用于传输
 @param content NSString *
 @result MqttMessageBody *
 */
- (MqttMessageBody *)getMessageWithContent:(NSString *)content;

/**
 @method analysisMessageWithData:
 @abstrac 传入一个data，用于解析消息体的
 @discussion 获取对话的结构体，用于展示
 @param data NSString *
 @result MqttMessageBody *
 */
- (MqttMessageBody *)analysisMessageWithData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
