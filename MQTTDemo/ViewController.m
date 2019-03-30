//
//  ViewController.m
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/26.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import "ViewController.h"
#import "MqttMessageBody.pbobjc.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextView *diaplayView;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIButton *login;
@property (strong, nonatomic) IBOutlet UIButton *send;
@property (strong, nonatomic) IBOutlet UITextView *inputView;
@property (strong, nonatomic) IBOutlet UILabel *status;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MqttMessageBody *message = [[MqttMessageBody alloc] init];
    message.num = 100;
    message.content = @"我在测试一下呀";
    message.fromid = @"123456";
    message.toid = @"654321";

    // 发信者
    MqttMessageBody_UserInfoBody *from = [[MqttMessageBody_UserInfoBody alloc] init];
    from.userid = @"111111";
    from.username = @"猪猪侠";
    from.avatar = @"http://avalanching.cn/skjkgljadkjlgajskdja.png";
    from.mobile = @"18269285645";
    from.num = 12;
    
    
    // 收信者
    MqttMessageBody_UserInfoBody *to = [[MqttMessageBody_UserInfoBody alloc] init];
    to.userid = @"222222";
    to.username = @"不二狗子";
    to.avatar = @"http://avalanching.cn/skjkgkjkjsfj2222dkjlgajskdja.png";
    to.mobile = @"18565493720";
    to.num = 13;
    
    MqttMessageBody_Attachment *att = [[MqttMessageBody_Attachment alloc] init];
    att.isPush = YES;
    att.content = @"我就是内容呀";
    
    message.to = to;
    message.from = from;
    message.att = att;
    NSLog(@"创建完成的对象:%@", message);
    
    NSData *data = [self creactProtobufData:message];
    
    message = [self getMessageBodyWithData:data];
}

- (NSData *)creactProtobufData:(MqttMessageBody *)body {
    NSData *data = [body data];
    return data;
}

- (MqttMessageBody *)getMessageBodyWithData:(NSData *)data {
    NSError *error = nil;
    MqttMessageBody *body = [[MqttMessageBody alloc] initWithData:data error:&error];
    if (!error) {
        NSLog(@"解析出来的对象: %@", body);
    } else {
        NSLog(@"解析失败了:%@", error);
    }
    return  body;
}


#pragma mark - action

- (IBAction)loginAction:(id)sender {
}

- (IBAction)send:(id)sender {
    
}

@end
