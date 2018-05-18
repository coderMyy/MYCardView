//
//  MYCardView.h
//  KCWC
//
//  Created by 孟遥 on 2018/4/2.
//  Copyright © 2018年 TGF. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MYCardView,MYCardViewItem;

typedef enum {
    
    MYCardViewDragDirectionLeftType   = 0 << 0,
    MYCardViewDragDirectionRightType  = 1 << 0,
    MYCardViewDragDirectionTopType    = 2 << 0,
    MYCardViewDragDirectionBottomType = 3 << 0
    
}MYCardViewDragDirectionType;

typedef enum {
    
    MYCardViewDragByClick  = 0 << 0,
    MYCardViewDragByHand   = 1 << 0
    
}MYCardViewDragMode;

@protocol MYCardViewDeletagte <NSObject>
@optional

/**
 卡片开始滑动
 @param handleView <#handleView description#>
 @param direction <#direction description#>
 @param index <#index description#>
 @param dragMode <#dragMode description#>
 */
- (void)handleView:(MYCardView *)handleView beginMoveDirection:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode;
/**
 卡片成功滑动
 @param handleView <#handleView description#>
 @param direction <#direction description#>
 @param index <#index description#>
 */
- (void)handleView:(MYCardView *)handleView effectiveDragDirection:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode;

/**
 取消卡片滑动
 @param handleView <#handleView description#>
 @param direction <#direction description#>
 @param index <#index description#>
 */
- (void)handleView:(MYCardView *)handleView cancelDrag:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode;
/**
 点击当前卡片
 @param handleView <#handleView description#>
 @param index <#index description#>
 */
- (void)handleView:(MYCardView *)handleView didClickItemAtIndex:(NSInteger)index;
/**
 卡片正在滑动
 @param handleView <#handleView description#>
 @param index <#index description#>
 */
- (void)handleView:(MYCardView *)handleView cardDidScroll:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode;
/**
 卡片结束滑动
 @param handleView <#handleView description#>
 @param index <#index description#>
 */
- (void)handleView:(MYCardView *)handleView cardEndScroll:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode;
@end

@protocol MYCardViewDataSource <NSObject>

@required

/**
 卡片Item
 
 @param handleView <#handleView description#>
 @param index <#index description#>
 @return <#return value description#>
 */
- (__kindof MYCardViewItem *)handleView:(MYCardView *)handleView itemForIndex:(NSInteger)index;

/**
 数据源个数
 
 @param handleView <#handleView description#>
 @return <#return value description#>
 */
- (NSInteger)handleViewPageCountForView:(MYCardView *)handleView;
@optional

- (CGSize)handleViewSizeForItem:(MYCardView *)handleView;
- (CGFloat)handleViewTopInsetForItem:(MYCardView *)handleView;

@end

@interface MYCardView : UIView


- (__kindof MYCardViewItem *)dequeueReusableItemWithIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)class forItemReuseIdentifier:(NSString *)identifier;
//- (void)registerNib:(UINib *)nib forItemReuseIdentifier:(NSString *)identifier;
- (void)reloadData;

/**
 手动滑动
 
 @param direction <#direction description#>
 */
- (void)excuteSlide:(MYCardViewDragDirectionType)direction;

@property (nonatomic, weak) id<MYCardViewDataSource> dataSource;
@property (nonatomic, weak) id<MYCardViewDeletagte> delegate;

/**
 当前索引
 */
@property (nonatomic, assign,readonly) NSInteger currentIndex;
@property (nonatomic, assign) BOOL enable;
@end

