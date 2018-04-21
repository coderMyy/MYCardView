//
//  ViewController.m
//  MYCardView
//
//  Created by 孟遥 on 2018/4/20.
//  Copyright © 2018年 孟遥. All rights reserved.
//

#import "ViewController.h"
#import "MYCardView.h"
#import "TestCardItem.h"
#import "TestCardModel.h"

@interface ViewController ()<MYCardViewDeletagte,MYCardViewDataSource>

@property (nonatomic, strong) MYCardView *cardView;
@property (nonatomic, strong) UIButton *likeBtn;
@property (nonatomic, strong) UIButton *disLikeBtn;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    [self loadData];
}

- (void)loadData
{
    //模拟数据源数据
    for (NSInteger index = 1; index < 11; index ++) {
        
        TestCardModel *model = [[TestCardModel alloc]init];
        model.imgName = [NSString stringWithFormat:@"img_%li",index];
        model.name = @"卡片可自行添加控件，自定义内容等。复用机制暂时未实现，如果要实现无缝滑动，需在数据源个数前5个以上提前预加载分页数据。极端情况，会出现卡片被滑完情况，只需要返回nil即可";
        [self.dataSource addObject:model];
    }
    [self.cardView reloadData];
}

- (void)initUI
{
    [self.view addSubview:self.cardView];
    [self.cardView reloadData];
    [self.view addSubview:self.likeBtn];
    [self.view addSubview:self.disLikeBtn];
    self.likeBtn.frame = CGRectMake(70,CGRectGetHeight(self.view.frame)-90, 70,70);
    self.disLikeBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-140,CGRectGetMinY(self.likeBtn.frame), 70,70);
}

- (MYCardViewItem *)cardView:(MYCardView *)cardView itemForIndex:(NSInteger)index
{
    if (index>self.dataSource.count-1) {
        return nil;
    }
    TestCardItem *cardItem = [cardView dequeueReusableItemWithIdentifier:@"TestCardItem"];
    cardItem.carModel = self.dataSource[index];
    return cardItem;
}
- (NSInteger)cardViewPageCountForView:(MYCardView *)cardView
{
    return self.dataSource.count;
}

- (CGSize)cardViewSizeForItem:(MYCardView *)cardView
{
    return CGSizeMake(345,480);
}

- (CGFloat)cardViewTopInsetForItem:(MYCardView *)cardView
{
    return 10;
}


- (void)cardView:(MYCardView *)cardView didClickItemAtIndex:(NSInteger)index
{
    NSLog(@"==============点击了卡片===========索引%li",index);
}

- (void)cardView:(MYCardView *)cardView cardDidSCroll:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode
{
    NSLog(@"==============卡片正在滑动==========索引%li",index);
}

- (void)cardView:(MYCardView *)cardView cardEndScroll:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode
{
    NSLog(@"==============卡片结束滑动==========索引%li",index);
}

- (void)cardView:(MYCardView *)cardView cancelDrag:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode
{
    NSLog(@"============取消了卡片滑动============索引%li",index);
}

- (void)cardView:(MYCardView *)cardView effectiveDragDirection:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode
{
    NSLog(@"===========成功滑动卡片==========索引%li",index);
    if (self.dataSource.count-1 == index) {
        
        [self loadData]; //继续添加数据
    }
}

//不喜欢
- (void)disLikeClick
{
    [self.cardView excuteSlide:MYCardViewDragDirectionLeftType];
}

//喜欢
- (void)likeClick
{
    [self.cardView excuteSlide:MYCardViewDragDirectionRightType];
}


- (MYCardView *)cardView
{
    if (!_cardView) {
        _cardView = [[MYCardView alloc]initWithFrame:CGRectMake(0,88,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
        _cardView.dataSource = self;
        _cardView.delegate = self;
        [_cardView registerClass:[TestCardItem class] forItemReuseIdentifier:@"TestCardItem"];
    }
    return _cardView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UIButton *)likeBtn
{
    if (!_likeBtn) {
        _likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeBtn setImage:[UIImage imageNamed:@"icon_like_defautl"] forState:UIControlStateNormal];
        [_likeBtn addTarget:self action:@selector(likeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

- (UIButton *)disLikeBtn
{
    if (!_disLikeBtn) {
        _disLikeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_disLikeBtn setImage:[UIImage imageNamed:@"icon_unlike_default"] forState:UIControlStateNormal];
        [_disLikeBtn addTarget:self action:@selector(disLikeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _disLikeBtn;
}

@end
