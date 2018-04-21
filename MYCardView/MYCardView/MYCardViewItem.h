//
//  MYCardViewItem.h
//  KCWC
//
//  Created by 孟遥 on 2018/4/2.
//  Copyright © 2018年 TGF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MYCardViewItem : UIView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, strong) UIView *contentView;

@end
