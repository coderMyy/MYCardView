//
//  MYCardViewItem.m
//  KCWC
//
//  Created by 孟遥 on 2018/4/2.
//  Copyright © 2018年 TGF. All rights reserved.
//

#import "MYCardViewItem.h"

@interface MYCardViewItem ()

@end

@implementation MYCardViewItem

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    return [self init];
}

- (instancetype)init
{
    if (self = [super init]) {
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
}


- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

@end
