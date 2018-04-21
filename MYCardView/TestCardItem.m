//
//  TestCardItem.m
//  MYCardView
//
//  Created by 孟遥 on 2018/4/20.
//  Copyright © 2018年 孟遥. All rights reserved.
//

#import "TestCardItem.h"
#import "TestCardModel.h"

@interface  TestCardItem ()

@property (nonatomic, strong) UIImageView *coverImgView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation TestCardItem

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.layer.borderColor = [UIColor colorWithRed:221.f/255 green:221.f/255 blue:221.f/255 alpha:1].CGColor;
        self.layer.borderWidth = 1;
        [self.contentView addSubview:self.coverImgView];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.coverImgView.frame = CGRectMake(0,0,CGRectGetWidth(self.frame),CGRectGetWidth(self.frame));
    self.nameLabel.frame = CGRectMake(0,CGRectGetMaxY(self.coverImgView.frame)+20,CGRectGetWidth(self.frame),CGRectGetHeight(self.frame)- CGRectGetMaxY(self.coverImgView.frame)-20);
}

- (void)setCarModel:(TestCardModel *)carModel
{
    _carModel = carModel;
    self.nameLabel.text = carModel.name;
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"picsSource" ofType:@"bundle"];
    NSString *imgPath = [[NSBundle bundleWithPath:bundlePath]pathForResource:carModel.imgName ofType:@"jpg"];
    self.coverImgView.image = [UIImage imageWithContentsOfFile:imgPath];
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = [UIColor redColor];
        _nameLabel.font = [UIFont systemFontOfSize:16 weight:1];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.numberOfLines = 0;
    }
    return _nameLabel;
}


- (UIImageView *)coverImgView
{
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc]init];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImgView;
}


@end
