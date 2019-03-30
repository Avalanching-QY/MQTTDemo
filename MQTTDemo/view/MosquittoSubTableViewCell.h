//
//  MosquittoSubTableViewCell.h
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/30.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MqttManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MosquittoSubTableViewCell : UITableViewCell

- (void)setValueToCellWithMessage:(MqttMessageBody *)message;

@end

NS_ASSUME_NONNULL_END
