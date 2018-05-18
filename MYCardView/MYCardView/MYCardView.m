//
//  MYCardView.m
//  KCWC
//
//  Created by 孟遥 on 2018/4/2.
//  Copyright © 2018年 TGF. All rights reserved.
//

#import "MYCardView.h"
#import "MYCardViewItem.h"

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
@property (nonatomic, strong) NSMutableDictionary *itemCache;

//默认布局属性
@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) BOOL firstLoad;
@property (nonatomic, assign) MYCardViewDragMode dragMode;
@property (nonatomic, assign) BOOL isMoving;

@end

@implementation MYCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //初始化设置
        _firstLoad = YES;
        _enable    = YES;
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
    if ([self.dataSource respondsToSelector:@selector(handleViewPageCountForView:)]) {
        dataCount = [self.dataSource handleViewPageCountForView:self];
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
    
    self.firstView  = [self creatCardContainView:_dragIndex+0];
    self.secondView = [self creatCardContainView:_dragIndex+1];
    self.thirdView  = [self creatCardContainView:_dragIndex+2];
    self.fourthView = [self creatCardContainView:_dragIndex+3];
    
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
    self.fourthView.frame = CGRectMake((screenW - self.itemSize.width+defaultTopMargin*2)*0.5,topMargin + topMargin, self.itemSize.width-defaultTopMargin*2,self.itemSize.height);
    self.thirdView.frame = self.fourthView.frame;
    self.secondView.frame = CGRectMake((screenW-self.itemSize.width+defaultTopMargin)*0.5,topMargin + topMargin*0.5,self.itemSize.width-defaultTopMargin,self.itemSize.height);
    self.firstView.frame = CGRectMake((screenW-self.itemSize.width)*0.5,topMargin,self.itemSize.width,self.itemSize.height);
}


//卡片滑动
- (void)cardViewDrag:(UIPanGestureRecognizer *)pan
{
    _dragMode = MYCardViewDragByHand;
    _isMoving = YES;
    //禁用其他卡片
    self.secondView.userInteractionEnabled = NO;
    self.thirdView.userInteractionEnabled = NO;
    self.fourthView.userInteractionEnabled = NO;
    
    UIView *dragView = pan.view;
    if (pan.state == UIGestureRecognizerStateBegan) { //开始拖动
        //卡片开始滑动
        if ([self.delegate respondsToSelector:@selector(handleView:beginMoveDirection:itemIndex:dragMode:)]) {
            [self.delegate handleView:self beginMoveDirection:self.direction itemIndex:_dragIndex dragMode:_dragMode];
        }
    }else if (pan.state == UIGestureRecognizerStateChanged) { //正在拖动
        //手势滑动
        NSLog(@"----卡片开始移动----");
        if ([self.delegate respondsToSelector:@selector(handleView:cardDidScroll:itemIndex:dragMode:)]) {
            [self.delegate handleView:self cardDidScroll:self.direction itemIndex:_dragIndex dragMode:_dragMode];
        }
        
        CGPoint point = [pan translationInView:dragView];
        CGPoint center = dragView.center;
        center.x += point.x;
        center.y += point.y;
        dragView.center = center;
        NSLog(@"---移动x--%f",point.x);
        NSLog(@"---移动y--%f",point.y);
        //底部卡片动画
        [self bottomCardsAnimation];
        
    }else if (pan.state == UIGestureRecognizerStateEnded){ //拖动结束
        NSLog(@"------拖动结束------");
        [self endDrag];
        //解禁卡片
        self.firstView.userInteractionEnabled = YES;
        self.secondView.userInteractionEnabled = YES;
        self.thirdView.userInteractionEnabled = YES;
        self.fourthView.userInteractionEnabled = YES;
        _isMoving = NO;
    }
    [pan setTranslation:CGPointZero inView:pan.view];
}

//点击卡片
- (void)cardViewClick
{
    if (_isMoving) return;
    if ([self.delegate respondsToSelector:@selector(handleView:didClickItemAtIndex:)]) {
        [self.delegate handleView:self didClickItemAtIndex:_dragIndex];
    }
}


//创建卡片容器
- (__kindof MYCardViewItem *)creatCardContainView:(NSInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(handleView:itemForIndex:)]) {
        
        MYCardViewItem *item = [self.dataSource handleView:self itemForIndex:index];
        
        //        item.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.f green:arc4random_uniform(255)/255.f blue:arc4random_uniform(255)/255.f alpha:1];
        //    view.layer.cornerRadius = 5;
        //    view.clipsToBounds = YES;
        
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
        
        CGFloat third_W  = first_W - defaultTopMargin*2;
        CGFloat second_W = first_W - defaultTopMargin;
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
        
        CGFloat third_W  = first_W-defaultTopMargin*2;
        CGFloat second_W = first_W-defaultTopMargin;
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
        NSLog(@"------scale-%f --- dragLenth-%f",scale,dragLength);
    }
}

//拖拽结束
- (void)endDrag
{
    
    //有效拖拽
    if (self.firstView.center.x <= [UIScreen mainScreen].bounds.size.width*0.2 &&_enable) {
        
        [self effectiveEndDragInsertView];
        NSLog(@"向左有效滑动---当然页码--%li",_dragIndex);
        if ([self.delegate respondsToSelector:@selector(handleView:effectiveDragDirection:itemIndex: dragMode:)]) {
            [self.delegate handleView:self effectiveDragDirection:MYCardViewDragDirectionLeftType itemIndex:_dragIndex dragMode:_dragMode];
        }
        _dragIndex ++;
    }else if (self.firstView.center.x >= [UIScreen mainScreen].bounds.size.width*0.8 &&_enable){
        
        [self effectiveEndDragInsertView];
        NSLog(@"向右有效滑动---当然页码--%li",_dragIndex);
        if ([self.delegate respondsToSelector:@selector(handleView:effectiveDragDirection:itemIndex:dragMode:)]) {
            [self.delegate handleView:self effectiveDragDirection:MYCardViewDragDirectionRightType itemIndex:_dragIndex dragMode:_dragMode];
        }
        //滑动结束
        if ([self.delegate respondsToSelector:@selector(handleView:cardEndScroll:itemIndex:dragMode:)]) {
            [self.delegate handleView:self cardEndScroll:self.direction itemIndex:_dragIndex dragMode:_dragMode];
        }
        _dragIndex ++;
        //无效拖拽
    }else{
        
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:(UIViewAnimationOptionCurveLinear) animations:^{
            [self defaulConfigFrame];
        } completion:^(BOOL finished) {
            //取消滑动
            if ([self.delegate respondsToSelector:@selector(handleView:cancelDrag:itemIndex:dragMode:)]) {
                [self.delegate handleView:self cancelDrag:self.direction itemIndex:_dragIndex dragMode:_dragMode];
            }
            //滑动结束
            if ([self.delegate respondsToSelector:@selector(handleView:cardEndScroll:itemIndex:dragMode:)]) {
                [self.delegate handleView:self cardEndScroll:self.direction itemIndex:_dragIndex dragMode:_dragMode];
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
    self.fourthView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - self.itemSize.width+defaultTopMargin*2)*0.5,self.topInset + self.topInset, self.itemSize.width-defaultTopMargin*2,self.itemSize.height);
}

- (void)excuteSlide:(MYCardViewDragDirectionType)direction
{
    if (_isMoving) return;
    if (!self.firstView) return;
    _isMoving = YES;
    _dragMode = MYCardViewDragByClick;
    
    //卡片开始滑动
    if ([self.delegate respondsToSelector:@selector(handleView:beginMoveDirection:itemIndex:dragMode:)]) {
        [self.delegate handleView:self beginMoveDirection:direction itemIndex:_dragIndex dragMode:_dragMode];
    }
    
    //模拟正在滑动
    for (NSInteger index = 0; index < 50; index ++) {
        if ([self.delegate respondsToSelector:@selector(handleView:cardDidScroll:itemIndex:dragMode:)]) {
            [self.delegate handleView:self cardDidScroll:self.direction itemIndex:_dragIndex dragMode:_dragMode];
        }
    }
    
    //如果禁止滑动
    if (!_enable) {
        __block CGFloat transformX = 0;
        [UIView animateWithDuration:0.3 animations:^{
            
            if (direction == MYCardViewDragDirectionLeftType) {
                transformX = - 150;
            }else if (direction == MYCardViewDragDirectionRightType){
                transformX =   150;
            }
            self.firstView.transform = CGAffineTransformMakeTranslation(transformX,0);
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.firstView.transform = CGAffineTransformIdentity;
            if ([self.delegate respondsToSelector:@selector(handleView:cardEndScroll:itemIndex:dragMode:)]) {
                [self.delegate handleView:self cardEndScroll:self.direction itemIndex:_dragIndex dragMode:_dragMode];
            }
            if ([self.delegate respondsToSelector:@selector(handleView:cancelDrag:itemIndex:dragMode:)]) {
                [self.delegate handleView:self cancelDrag:self.direction itemIndex:_dragIndex dragMode:_dragMode];
            }
        }];
    }else{
        
        CGPoint center = self.firstView.center;
        if (direction == MYCardViewDragDirectionLeftType) {
            center.x = - CGRectGetWidth(self.firstView.frame)*0.5;
        }else if (direction == MYCardViewDragDirectionRightType){
            center.x = CGRectGetWidth(self.firstView.frame)*0.5 + [UIScreen mainScreen].bounds.size.width;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.firstView.center = center;
        } completion:^(BOOL finished) {
            _isMoving = NO;
            [self bottomCardsAnimation];
            [self endDrag];
        }];
    }
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
    //    _dragIndex = 0;
    [self defaultInitUI];
}


- (NSMutableDictionary *)itemCache
{
    if (!_itemCache) {
        _itemCache = [NSMutableDictionary dictionary];
    }
    return _itemCache;
}

- (CGFloat)topInset
{
    if (_topInset) {
        return _topInset;
    }
    if (!_topInset && [self.dataSource respondsToSelector:@selector(handleViewTopInsetForItem:)]) {
        _topInset = [self.dataSource handleViewTopInsetForItem:self];
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
    if (!_itemSize.width&&[self.dataSource respondsToSelector:@selector(handleViewSizeForItem:)]) {
        _itemSize = [self.dataSource handleViewSizeForItem:self];
    }else{
        _itemSize = CGSizeMake(defaultWidth,defaultHeight);//默认值
    }
    return _itemSize;
}

- (NSInteger)currentIndex {
    return _dragIndex;
}

- (MYCardViewDragDirectionType)direction
{
    MYCardViewDragDirectionType direction = 0;
    if (self.firstView.center.x >[UIScreen mainScreen].bounds.size.width*0.5) {
        direction = MYCardViewDragDirectionRightType;
    }else{
        direction = MYCardViewDragDirectionLeftType;
    }
    return direction;
}

@end
