//
//  MqttManager.h
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/27.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MQTTClient/MQTTClient.h>
#import "MQTTUserInfo.h"
#import "MqttMessageBody.pbobjc.h"

typedef NS_ENUM(NSInteger, MQTTConnectionCode) {
    MQTTConnectionCodeDidConnection
};

@protocol AVAMqttManagerDelegate <NSObject>

/**
 @method sendMessageCallBackWithBool:message:
 @abstrac 发送回调
 @discussion 回调结果是否发送成功了
 @param flag 发送结果
 @param body 发送的信息
 */
- (void)sendMessageCallBackWithBool:(BOOL)flag message:(MqttMessageBody *)body;

/**
 @method newMessageArrival:
 @abstrac 收到新的信息
 @discussion 收到信息的回调
 @param message 发送的信息
 */
- (void)newMessageArrival:(MqttMessageBody *)message;

@end

@interface MqttManager : NSObject

// 登陆信息
@property (nonatomic, strong, readonly) MQTTUserInfo * userinfo;

// 终端连接回调
@property (nonatomic, copy, readonly) BOOL (^interruptblock)(MQTTConnectionCode code, NSString *msg);

/**
 @method shareManager
 @abstrac 获取一个管理者单例对象
 @discussion 用来管理MQTT的绑定，订阅，链接，中断，接收，发送
 @result MqttManager / NULL (instancetype 仅返回值，告诉编译器不报异常)
 */
+ (instancetype)shareManager;

/**
 @method loginWithMQTTUserInfo:
 @abstrac 用户登陆MQTT服务器
 @discussion 必须登陆以后才可以登陆
 @param userinfo block
 */
- (void)loginWithMQTTUserInfo:(MQTTUserInfo *)userinfo complete:(BOOL(^)(MQTTConnectionCode code, NSString *msg))block;

/**
 @method addSubscriptionWithTheme:
 @abstrac 订阅主题
 @discussion 默认为@"$SYS/IM"
 @param theme NSString *
 */
- (BOOL)addSubscriptionWithTheme:(NSString *)theme;

/**
 @method disConnection
 @abstrac 中断链接
 */
- (void)disConnection;

/**
 @method sendMessageWithData:
 @abstrac 发送消息
 @param data NSString
 */
- (void)sendMessageWithData:(NSData *)data;

/**
 @method isSendWithMessageBody:
 @abstrac 判断是不是发送者
 @discussion 传入一个消息对象
 @param body MqttMessageBody*
 @result BOOL (NO 接收者/YES 发送者)
 */
- (BOOL)isSendWithMessageBody:(MqttMessageBody *)body;


/**
 @method addDelegatesWithObject:
 @abstrac 添加一个代理对象
 @discussion 传入一个代理对象
 @param delegate id<AVAMqttManagerDelegate> 代理对象
 */
- (void)addDelegatesWithObject:(id<AVAMqttManagerDelegate>)delegate;

/**
 @method removeDelegateObject:
 @abstrac 删除一个代理对象
 @discussion 传入一个代理对象
 @param delegate id<AVAMqttManagerDelegate> 代理对象
 */
- (void)removeDelegateObject:(id<AVAMqttManagerDelegate>)delegate;

@end
