//
//  Toast.m
//  MQTTDemo
//
//  Created by Avalanching on 2019/3/28.
//  Copyright © 2019 Avalanching. All rights reserved.
//

#import "Toast.h"

@interface Toast ()


@end

@implementation Toast

#pragma mark - public method

+ (instancetype)toastWithContent:(NSString *)content {
    Toast *toast = [[Toast alloc] init];
    toast.contentLabel.text = content;
    toast.frame = CGRectMake(0, 0, 1, 1);
    return toast;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 不裁剪
    self.clipsToBounds = NO;
    
    [self commonInit];
}

#pragma mark - private method

- (void)commonInit {
    if ()
}

#pragma mark - lazy load

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = [UIColor whiteColor];
    }
    return _contentLabel;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor lightGrayColor];
        _backgroundView.alpha = 0.6;
    }
    return _backgroundView;
}

@end
