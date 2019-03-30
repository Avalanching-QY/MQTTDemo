//
//  LoginViewController.m
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/28.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import "LoginViewController.h"
#import "MessageFactory.h"
#import "MqttManager.h"
#import "ChatViewController.h"

@interface LoginViewController () {
    NSDictionary *userinfo;
}

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController


#pragma mark - lifecycel

- (void)viewDidLoad {
    [super viewDidLoad];
    userinfo = @{@"avalanching1":@"123456",@"avalanching2":@"123456"};

}

#pragma mark - action

- (IBAction)loginAction:(UIButton *)sender {
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    NSString *temp = userinfo[username];
    if (temp && [temp isEqualToString:password]) {
        MqttMessageBody_UserInfoBody *from = [[MqttMessageBody_UserInfoBody alloc] init];
        from.userid = @"111111";
        from.username = username;
        from.avatar = [username isEqualToString:@"avalanching1"] ? @"avalanching1.jpg" : @"avalanching2.jpg";
        from.mobile = @"18269285645";
        from.num = 12;
        
        MqttMessageBody_UserInfoBody *to = [[MqttMessageBody_UserInfoBody alloc] init];
        to.userid = @"22222";
        to.username = [username isEqualToString:@"avalanching1"] ? @"avalanching2" : @"avalanching1";
        to.avatar = [username isEqualToString:@"avalanching1"] ? @"avalanching1.jpg" : @"avalanching2.jpg";
        to.mobile = @"18269285645";
        to.num = 12;
        [self configuratIoninformation:from to:to];
    } else {
        NSLog(@"登陆失败");
    }
}


#pragma mark - private

- (void)configuratIoninformation:(MqttMessageBody_UserInfoBody *)from to:(MqttMessageBody_UserInfoBody *)to {
    MessageFactory *factory = [MessageFactory share];
    [factory addLogin:from];
    [factory contactsObject:to];
    NSDictionary *dict = @{@"username":from.username, @"password":self.passwordTextField.text, @"clientId":@""};
    MQTTUserInfo *userinfo = [[MQTTUserInfo alloc] initWithDict:dict];
    __weak __typeof(self) weakself = self;
    [[MqttManager shareManager] loginWithMQTTUserInfo:userinfo complete:^BOOL(MQTTConnectionCode code, NSString *msg) {
        __strong __typeof(weakself) strongself = weakself;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ChatViewController *viewController = [story instantiateViewControllerWithIdentifier:@"ChatViewController"];
        [strongself.navigationController pushViewController:viewController animated:YES];
        return YES;
    }];
    
}

#pragma mark - system touch

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
