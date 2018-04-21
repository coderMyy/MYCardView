//
//  MYCardView.m
//  KCWC
//
//  Created by 孟遥 on 2018/4/2.
//  Copyright © 2018年 TGF. All rights reserved.
//

#import "MYCardView.h"
#import "MYCardViewItem.h"

static const CGFloat defaultCardMargin = 20;
static const CGFloat defaultTopMargin = 16;
static const CGFloat defaultWidth = 345;
static const CGFloat defaultHeight = 480;

@interface MYCardView ()

@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIView *secondView;
@property (nonatomic, strong) UIView *thirdView;
@property (nonatomic, strong) UIView *fourthView;
@property (nonatomic, assign) NSInteger dragIndex;

//复用机制
@property (nonatomic, strong) NSCache *itemCache;

//默认布局属性
@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) BOOL firstLoad;
@property (nonatomic, assign) MYCardViewDragMode dragMode;

@end

@implementation MYCardView

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _firstLoad = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!_firstLoad) return;
    [self defaultInitUI];
    _firstLoad = NO;
}

- (void)defaultInitUI
{
    NSInteger dataCount = 0;
    if ([self.dataSource respondsToSelector:@selector(cardViewPageCountForView:)]) {
        dataCount = [self.dataSource cardViewPageCountForView:self];
    }
    if (!dataCount) return;
    
    [self.firstView removeFromSuperview];
    [self.secondView removeFromSuperview];
    [self.thirdView removeFromSuperview];
    [self.fourthView removeFromSuperview];
    self.firstView = nil;
    self.secondView = nil;
    self.thirdView = nil;
    self.fourthView = nil;
    
    self.firstView  = [self creatCardContainView:_currentIndex+0];
    self.secondView = [self creatCardContainView:_currentIndex+1];
    self.thirdView  = [self creatCardContainView:_currentIndex+2];
    self.fourthView = [self creatCardContainView:_currentIndex+3];
    
    [self addSubview:self.fourthView];
    [self addSubview:self.thirdView];
    [self addSubview:self.secondView];
    [self addSubview:self.firstView];
    
    [self defaulConfigFrame];
}

- (void)setDataSource:(id<MYCardViewDataSource>)dataSource
{
    _dataSource = dataSource;
}




- (void)defaulConfigFrame
{
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    //    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat topMargin = self.topInset;
    self.fourthView.frame = CGRectMake((screenW - self.itemSize.width+defaultCardMargin*2)*0.5,topMargin + topMargin, self.itemSize.width-defaultCardMargin*2,self.itemSize.height);
    self.thirdView.frame = self.fourthView.frame;
    self.secondView.frame = CGRectMake((screenW-self.itemSize.width+defaultCardMargin)*0.5,topMargin + topMargin*0.5,self.itemSize.width-defaultCardMargin,self.itemSize.height);
    self.firstView.frame = CGRectMake((screenW-self.itemSize.width)*0.5,topMargin,self.itemSize.width,self.itemSize.height);
}


//卡片滑动
- (void)cardViewDrag:(UIPanGestureRecognizer *)pan
{
    UIView *dragView = pan.view;
    if (pan.state == UIGestureRecognizerStateChanged) { //正在拖动
        NSLog(@"----卡片开始移动----");
        if ([self.delegate respondsToSelector:@selector(cardView:cardDidSCroll:dragMode:)]) {
            [self.delegate cardView:self cardDidSCroll:_dragIndex dragMode:_dragMode];
        }
        
        CGPoint point = [pan translationInView:dragView];
        CGPoint center = dragView.center;
        center.x += point.x;
        center.y += point.y;
        dragView.center = center;
        //底部卡片动画
        [self bottomCardsAnimation];
        
    }else if (pan.state == UIGestureRecognizerStateEnded){ //拖动结束
        NSLog(@"------拖动结束------");
        [self endDrag];
    }
    [pan setTranslation:CGPointZero inView:pan.view];
}

//点击卡片
- (void)cardViewClick
{
    if ([self.delegate respondsToSelector:@selector(cardView:didClickItemAtIndex:)]) {
        [self.delegate cardView:self didClickItemAtIndex:_dragIndex];
    }
}


//创建卡片容器
- (__kindof MYCardViewItem *)creatCardContainView:(NSInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(cardView:itemForIndex:)]) {
        
        MYCardViewItem *item = [self.dataSource cardView:self itemForIndex:index];
        
        //添加滑动手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(cardViewDrag:)];
        [item addGestureRecognizer:pan];
        
        //添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cardViewClick)];
        [item addGestureRecognizer:tap];
        
        return item;
    }else{
        return nil;
    }
}

//底部卡片动画
- (void)bottomCardsAnimation
{
    CGFloat first_W = self.itemSize.width;
    CGFloat topInset = self.topInset;
    //移动卡片中心点距离两侧
    CGPoint center =  self.firstView.center;
    //左侧
    if (center.x<[UIScreen mainScreen].bounds.size.width*0.5) {
        
        CGFloat third_W  = first_W - defaultCardMargin*2;
        CGFloat second_W = first_W - defaultCardMargin;
        CGFloat third_Y  = topInset + topInset;
        CGFloat second_Y = topInset + topInset*0.5;
        
        CGFloat third_WDifference  = second_W-third_W;
        CGFloat second_WDifference = first_W-second_W;
        CGFloat third_YDifference  = third_Y-second_Y;
        CGFloat second_YDifference = second_Y-topInset;
        
        
        CGFloat dragCenterX = center.x;
        if (dragCenterX<=[UIScreen mainScreen].bounds.size.width*0.2) {
            dragCenterX = 0;
        }
        CGFloat dragLength = [UIScreen mainScreen].bounds.size.width *0.5-dragCenterX;
        CGFloat scale = dragLength / ([UIScreen mainScreen].bounds.size.width *0.5);
        third_W += third_WDifference*scale;
        second_W += second_WDifference*scale;
        third_Y -= third_YDifference*scale;
        second_Y -= second_YDifference*scale;
        
        self.thirdView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-third_W)*0.5,third_Y,third_W,self.itemSize.height);
        self.secondView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-second_W)*0.5,second_Y,second_W,self.itemSize.height);
        NSLog(@"----item宽高-----%f----%f----比例-%f--宽度差距-%f",second_W,self.itemSize.height,scale,second_WDifference);
        NSLog(@"------scale-%f --- dragLenth-%f",scale,dragLength);
        //右侧
    }else{
        
        CGFloat third_W  = first_W-defaultCardMargin*2;
        CGFloat second_W = first_W-defaultCardMargin;
        CGFloat third_Y  = topInset + topInset;
        CGFloat second_Y = topInset + topInset*0.5;
        
        CGFloat third_WDifference  = second_W-third_W;
        CGFloat second_WDifference = first_W-second_W;
        CGFloat third_YDifference  = third_Y-second_Y;
        CGFloat second_YDifference = second_Y-topInset;
        
        CGFloat dragCenterX = center.x;
        if (dragCenterX>=[UIScreen mainScreen].bounds.size.width *0.8) {
            dragCenterX = [UIScreen mainScreen].bounds.size.width;
        }
        CGFloat dragLength = dragCenterX - [UIScreen mainScreen].bounds.size.width *0.5;
        
        CGFloat scale = dragLength / ([UIScreen mainScreen].bounds.size.width *0.5);
        third_W += third_WDifference*scale;
        second_W += second_WDifference*scale;
        third_Y -= third_YDifference*scale;
        second_Y -= second_YDifference*scale;
        
        self.thirdView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-third_W)*0.5,third_Y,third_W,self.itemSize.height);
        self.secondView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-second_W)*0.5,second_Y,second_W,self.itemSize.height);
    }
}

//拖拽结束
- (void)endDrag
{
    
    if ([self.delegate respondsToSelector:@selector(cardView:cardEndScroll:dragMode:)]) {
        [self.delegate cardView:self cardEndScroll:_dragIndex dragMode:_dragMode];
    }
    
    //有效拖拽
    if (self.firstView.center.x <= [UIScreen mainScreen].bounds.size.width*0.2) {
        
        [self effectiveEndDragInsertView];
        NSLog(@"向左有效滑动---当然页码--%li",_dragIndex);
        if ([self.delegate respondsToSelector:@selector(cardView:effectiveDragDirection:itemIndex:dragMode:)]) {
            [self.delegate cardView:self effectiveDragDirection:MYCardViewDragDirectionLeftType itemIndex:_dragIndex dragMode:_dragMode];
        }
        _dragIndex ++;
    }else if (self.firstView.center.x >= [UIScreen mainScreen].bounds.size.width*0.8){
        
        [self effectiveEndDragInsertView];
        NSLog(@"向右有效滑动---当然页码--%li",_dragIndex);
        if ([self.delegate respondsToSelector:@selector(cardView:effectiveDragDirection:itemIndex:dragMode:)]) {
            [self.delegate cardView:self effectiveDragDirection:MYCardViewDragDirectionRightType itemIndex:_dragIndex dragMode:_dragMode];
        }
        _dragIndex ++;
        //无效拖拽
    }else{
        
        MYCardViewDragDirectionType direction = 0;
        if (self.firstView.center.x >[UIScreen mainScreen].bounds.size.width*0.5) {
            direction = MYCardViewDragDirectionRightType;
        }else{
            direction = MYCardViewDragDirectionLeftType;
        }
        
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:(UIViewAnimationOptionCurveLinear) animations:^{
            
            [self defaulConfigFrame];
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(cardView:cancelDrag:itemIndex:dragMode:)]) {
                [self.delegate cardView:self cancelDrag:direction itemIndex:_dragIndex dragMode:_dragMode];
            }
        }];
    }
}

//有效拖拽后插入视图
- (void)effectiveEndDragInsertView
{
    [self.firstView removeFromSuperview];
    self.firstView = self.secondView;
    self.secondView = self.thirdView;
    self.thirdView = self.fourthView;
    self.fourthView = [self creatCardContainView:_dragIndex+4];
    [self insertSubview:self.fourthView belowSubview:self.thirdView];
    self.fourthView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - self.itemSize.width+defaultCardMargin*2)*0.5,self.topInset + self.topInset, self.itemSize.width-defaultCardMargin*2,self.itemSize.height);
}

- (void)excuteSlide:(MYCardViewDragDirectionType)direction
{
    CGPoint center = self.firstView.center;
    if (direction == MYCardViewDragDirectionLeftType) {
        center.x = - CGRectGetWidth(self.firstView.frame)*0.5;
        
    }else if (direction == MYCardViewDragDirectionRightType){
        center.x = CGRectGetWidth(self.firstView.frame)*0.5 + [UIScreen mainScreen].bounds.size.width;
    }
    
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakself.firstView.center = center;
    } completion:^(BOOL finished) {
        [weakself bottomCardsAnimation];
        [weakself endDrag];
    }];
}


- (__kindof MYCardViewItem *)dequeueReusableItemWithIdentifier:(NSString *)identifier
{
    NSString *className = [self.itemCache objectForKey:identifier];
    Class class = NSClassFromString(className);
    MYCardViewItem *item = [[class alloc]initWithReuseIdentifier:identifier];
    return item;
}
//
- (void)registerClass:(Class)class forItemReuseIdentifier:(NSString *)identifier
{
    NSString *className = NSStringFromClass(class);
    [self.itemCache setObject:className forKey:identifier];
    
//    [self defaultInitUI];
}
//
//- (void)registerNib:(UINib *)nib forItemReuseIdentifier:(NSString *)identifier
//{
//    for (NSInteger index = 0; index < 3; index ++) {
//        [self.itemCache setObject:nib forKey:identifier];
//    }
//}
//
//

//刷新
- (void)reloadData
{
    [self defaultInitUI];
}


- (NSCache *)itemCache
{
    if (!_itemCache) {
        _itemCache = [[NSCache alloc]init];
        _itemCache.countLimit = 100;
        _itemCache.totalCostLimit = 100;
    }
    return _itemCache;
}

- (CGFloat)topInset
{
    if (_topInset) {
        return _topInset;
    }
    if (!_topInset && [self.dataSource respondsToSelector:@selector(cardViewTopInsetForItem:)]) {
        _topInset = [self.dataSource cardViewTopInsetForItem:self];
    }else{
        _topInset = defaultTopMargin; //默认值16
    }
    NSLog(@"--顶部距离--%f",_topInset);
    return _topInset;
}

- (CGSize)itemSize
{
    if (_itemSize.width) {
        return _itemSize;
    }
    if (!_itemSize.width&&[self.dataSource respondsToSelector:@selector(cardViewSizeForItem:)]) {
            _itemSize = [self.dataSource cardViewSizeForItem:self];
    }else{
        _itemSize = CGSizeMake(defaultWidth,defaultHeight);//默认值
    }
    return _itemSize;
}

- (NSInteger)currentIndex {
    return _dragIndex;
}


@end
