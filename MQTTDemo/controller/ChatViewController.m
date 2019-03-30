//
//  ChatViewController.m
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/28.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import "ChatViewController.h"
#import "MqttManager.h"
#import "MessageFactory.h"
#import "MosquittoSubTableViewCell.h"
#import "MosquittoPubTableViewCell.h"

static NSString *const ToIdentifier = @"MosquittoSubTableViewCell";
static NSString *const FromIdentifier = @"MosquittoPubTableViewCell";

@interface ChatViewController ()<UITableViewDelegate, UITableViewDataSource, AVAMqttManagerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIButton *sendButton;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *marginBottom;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) MessageFactory *messagefactory;
@property (nonatomic, strong) MqttManager *manager;

@end

@implementation ChatViewController

- (void)dealloc {
    [[MqttManager shareManager] removeDelegateObject:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)commonInit {
    [self.manager addSubscriptionWithTheme:nil];
    self.navigationController.title = self.messagefactory.to.username;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MosquittoSubTableViewCell" bundle:nil] forCellReuseIdentifier:ToIdentifier];

    [self.tableView registerNib:[UINib nibWithNibName:@"MosquittoPubTableViewCell" bundle:nil] forCellReuseIdentifier:FromIdentifier];
    
    [[MqttManager shareManager] addDelegatesWithObject:self];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - private

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    __weak __typeof(self) weakself = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong __typeof(weakself) strongself = weakself;
        strongself.marginBottom.constant = height;
        [strongself.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.marginBottom.constant = 0;
}

- (void)appendNewMessage:(MqttMessageBody *)message {
    [self.dataSource addObject:message];
    [self.tableView reloadData];
}

#pragma mark - action

- (IBAction)textFieldDidChange:(UITextField *)sender {
    self.sendButton.enabled = sender.text.length > 0 ? YES : NO;
}
- (IBAction)sendButtonAction:(id)sender {
    NSString *context = self.textField.text;
    if (context && context.length > 0) {
      MqttMessageBody *body = [self.messagefactory getMessageWithContent:context];
        [self.manager sendMessageWithData:[body data]];
        [self appendNewMessage:body];
        self.textField.text = nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MqttMessageBody *message = self.dataSource[indexPath.row];
    
    BOOL flag = [[MqttManager shareManager] isSendWithMessageBody:message];
    if (flag) {
        MosquittoPubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FromIdentifier];
        [cell setValueToCellWithMessage:message];
        return cell;
    } else {
        MosquittoSubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ToIdentifier];
        [cell setValueToCellWithMessage:message];
        return cell;
    }
}


#pragma mark - AVAMqttManagerDelegate

- (void)newMessageArrival:(MqttMessageBody *)message {
    [self appendNewMessage:message];
}

- (void)sendMessageCallBackWithBool:(BOOL)flag message:(MqttMessageBody *)body {
    if (flag) {
        NSLog(@"%s\n发送成了, %@", __func__, body);
    }
}

#pragma mark - lazy load

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

- (MessageFactory *)messagefactory {
    return [MessageFactory share];
}

- (MqttManager *)manager {
    return [MqttManager shareManager];
}

@end
