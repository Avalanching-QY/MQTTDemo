//
//  Toast.h
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/28.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Toast : UIView

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIView *backgroundView;

+ (instancetype)toastWithContent:(NSString *)content;

@end
