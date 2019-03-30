//
//  MqttManager.m
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/27.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import "MqttManager.h"
#import <objc/message.h>

#define HOST @"192.168.2.9"
#define PORT 1883

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

static MqttManager *single = nil;
static NSString *DefaultsTheme = @"$SYS/IM";

@interface MqttManager()<MQTTSessionDelegate>

// 登陆信息
@property (nonatomic, strong) MQTTUserInfo * userinfo;

// 终端连接回调
@property (nonatomic, copy) BOOL (^interruptblock)(MQTTConnectionCode code, NSString *msg);

@property (nonatomic, strong) MQTTSession *session;

// 处理线程
@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, assign) BOOL isClose;

@property (nonatomic, strong) NSMutableArray<id<AVAMqttManagerDelegate>> *delegates;

@end

@implementation MqttManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        single = [[MqttManager alloc] init];
    });
    
    return single;
}

#pragma mark - public method

- (void)loginWithMQTTUserInfo:(MQTTUserInfo *)userinfo complete:(BOOL(^)(MQTTConnectionCode code, NSString *msg))block {
    self.userinfo = userinfo;
    self.interruptblock = block;
    self.queue = dispatch_queue_create("mqtt_queue", DISPATCH_QUEUE_SERIAL);
    /**
     ClientId:客户机标识符向服务器标识客户机。如果为零，则生成随机的clientID
     userName:用于身份验证的用户名（或ID）的nsstring对象。可能是零。
     password:用户密码的nsstring对象。如果用户名为零，密码也必须为零。
     keepAlive:是以秒为单位的时间间隔。mqttclient确保发送的控制包之间的间隔不超过keep-alive值。在没有发送任何其他控制包的情况下，客户机发送一个pingreq包
     connectMessage:(MQTTMessage *)
     cleanSession:指定服务器是否应放弃以前的会话信息。
     will:will标志设置为yes，则表示当服务器检测到客户机由于任何原因（而非客户机主动断开数据包）断开连接时，服务器必须发布will消息。异常退出
     willTopic:如果上一项will标志设置为yes，will主题是一个字符串，否则为nil。
     willMsg:如果will标志设置为yes，则必须指定will消息，否则为nil。
     willQoS:指定发布will消息时要使用的qos级别。如果will标志设置为no，那么will qos必须设置为0。
     willRetainFlag:指示服务器是否应使用retainFlag发布will消息。如果will标志设置为no，则will retain标志必须设置为no。如果will标志设置为yes:如果will retain设置为no，服务器必须将will消息发布为非保留发布[mqtt-3.1.2-14]。如果will retain设置为yes，服务器必须将will消息发布为保留发布[mqtt-3.1.2-15]。
     protocolLevel:指定要使用的协议。协议版本3.1.1的协议级别字段的值为4。版本3.1的值为3。
     queue:安排流的队列进行排队
     securityPolicy:安全策略用于评估安全连接的服务器信任的安全策略。
     certificates:提供的描述回复需要客户端证书的服务器的身份证书。
     
     self.session = [[MQTTSession alloc] initWithClientId:userinfo.clientId
     userName:self.userinfo.username
     password:self.userinfo.password
     keepAlive:60
     connectMessage:nil
     cleanSession:YES
     will:NO
     willTopic:nil
     willMsg:nil
     willQoS:MQTTQosLevelAtMostOnce
     willRetainFlag:NO
     protocolLevel:3
     queue:self.queue
     securityPolicy:[self customSecurityPolicy]
     certificates:nil];
     */
    
    _isClose = NO;
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = HOST;
    transport.port = PORT;
    self.session = [[MQTTSession alloc] init];
    self.session.transport = transport;
    self.session.delegate = self;
    // 设置超时
    [self.session setDupTimeout:30];
    // 设置账号密码
    [self.session setUserName:userinfo.username];
    [self.session setPassword:userinfo.password];
    [self.session subscribeToTopic:DefaultsTheme atLevel:MQTTQosLevelAtMostOnce];
    
    // 添加监听状态观察者
    [self.session addObserver:self
                   forKeyPath:@"status"
                      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                      context:nil];
    // 链接
    [self.session connect];
}

- (BOOL)addSubscriptionWithTheme:(NSString *)theme {
    if (theme) {
        [self.session subscribeToTopic:theme atLevel:MQTTQosLevelAtMostOnce];
    } else {
        [self.session subscribeToTopic:DefaultsTheme atLevel:MQTTQosLevelAtMostOnce];
    }
    return YES;
}

- (void)disConnection {
    self.isClose = YES;
    [self.session disconnect];
}

- (void)sendMessageWithData:(NSData *)data {
    [self.session publishData:data onTopic:DefaultsTheme retain:YES qos:MQTTQosLevelAtLeastOnce];
}

- (BOOL)isSendWithMessageBody:(MqttMessageBody *)body {
    NSString *fromUsername = body.from.username;
    return [self.userinfo.username isEqualToString:fromUsername];
}

- (void)addDelegatesWithObject:(id<AVAMqttManagerDelegate>)delegate {
    for (id object in self.delegates) {
        if (object == delegate) {
            return;
        }
    }
    [self.delegates addObject:delegate];
}

- (void)removeDelegateObject:(id<AVAMqttManagerDelegate>)delegate {
    for (id object in self.delegates.reverseObjectEnumerator) {
        if (object == delegate) {
            [self.delegates removeObject:delegate];
            return;
        }
    }
}

#pragma mark - private method

- (MQTTSSLSecurityPolicy *)customSecurityPolicy {
    
    MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesCertificateChain = YES;
    securityPolicy.validatesDomainName = NO;
    // 需要证书请设置这个
    //    securityPolicy.pinnedCertificates
    return securityPolicy;
}

- (void)sendMessageToDelegateWithSelector:(SEL)sel paramList:(NSArray *)param {
    
    [self.delegates enumerateObjectsUsingBlock:^(id<AVAMqttManagerDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:sel]) {
            if (param.count > 1) {
                SuppressPerformSelectorLeakWarning(
                [obj performSelector:sel withObject:param.firstObject withObject:param.lastObject]);
            } else {
                SuppressPerformSelectorLeakWarning([obj performSelector:sel withObject:param.firstObject]);
            }
        }
    }];
}

#pragma mark - kvc

// 监听当前连接状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    MQTTSessionStatus eventCode = self.session.status;
    switch (eventCode) {
        case MQTTSessionStatusCreated:
            NSLog(@"%s\n创建链接:%ld", __func__, (long)eventCode);
            break;
        case MQTTSessionStatusConnecting:
            NSLog(@"%s\n链接中:%ld", __func__, (long)eventCode);
            break;
        case MQTTSessionStatusConnected:
            NSLog(@"%s\n已经链接:%ld", __func__, (long)eventCode);
            if (_interruptblock) {
                self.interruptblock(MQTTConnectionCodeDidConnection, @"已经链接了");
            }
            break;
        case MQTTSessionStatusDisconnecting:
            NSLog(@"%s\n正在断开链接:%ld", __func__, (long)eventCode);
            break;
        case MQTTSessionStatusClosed:
            NSLog(@"%s\n关闭链接:%ld", __func__, (long)eventCode);
            if (self.isClose) {
                return;
            } else {
                [self.session connect];
            }
        default:
            NSLog(@"%s\n链接错误:%ld", __func__, (long)eventCode);
            break;
    }
}

#pragma mark - MQTTSessionDelegate

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {
    NSError *error;
    MqttMessageBody *message = [[MqttMessageBody alloc] initWithData:data error:&error];
    if (error) {
        NSLog(@"解析错误!!!%s:\n%@", __func__, error);
        return;
    }
    if ([self.userinfo.username isEqualToString:message.from.username]) {
        NSLog(@"%s:发送成功回执\n%@", __func__, message);
        [self sendMessageToDelegateWithSelector:@selector(sendMessageCallBackWithBool:message:) paramList:@[@(YES), message]];
    } else {
        NSLog(@"%s:收到新消息\n%@", __func__, message);
        [self sendMessageToDelegateWithSelector:@selector(newMessageArrival:) paramList:@[message]];
    }
}

#pragma mark - lazy load

- (NSMutableArray<id<AVAMqttManagerDelegate>> *)delegates {
    if (!_delegates) {
        _delegates = @[].mutableCopy;
    }
    return _delegates;
}

@end
