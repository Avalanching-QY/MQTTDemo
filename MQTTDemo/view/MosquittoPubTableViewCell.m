//
//  MosquittoPubTableViewCell.m
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/30.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import "MosquittoPubTableViewCell.h"

@interface MosquittoPubTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *buddyBackgroundView;

@end

@implementation MosquittoPubTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setValueToCellWithMessage:(MqttMessageBody *)message {
    self.contentLabel.text = message.content;
    BOOL flag = [[MqttManager shareManager] isSendWithMessageBody:message];
    UIImage *image;
    if (flag) {
        image = [UIImage imageNamed:message.from.avatar];
    } else {
        image = [UIImage imageNamed:message.to.avatar];
    }
    
    [self.avatarImageView setImage:image];
    self.avatarImageView.layer.cornerRadius = 3.f;
    self.buddyBackgroundView.layer.cornerRadius = 5.f;
}

@end
