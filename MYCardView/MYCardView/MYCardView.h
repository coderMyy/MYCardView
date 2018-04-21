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
    
    MYCardViewDragByHandMode  = 0 << 0,
    MYCardViewDragByClickMode = 1 << 0
    
}MYCardViewDragMode;

@protocol MYCardViewDeletagte <NSObject>

@optional


/**
 卡片成功滑动

 @param cardView <#cardView description#>
 @param direction <#direction description#>
 @param index <#index description#>
 @param dragMode <#dragMode description#>
 */
- (void)cardView:(MYCardView *)cardView effectiveDragDirection:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode;


/**
 取消卡片滑动

 @param cardView <#cardView description#>
 @param direction <#direction description#>
 @param index <#index description#>
 @param dragMode <#dragMode description#>
 */
- (void)cardView:(MYCardView *)cardView cancelDrag:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode;


/**
 点击当前卡片

 @param cardView <#cardView description#>
 @param index <#index description#>
 */
- (void)cardView:(MYCardView *)cardView didClickItemAtIndex:(NSInteger)index;


/**
 卡片正在滑动

 @param cardView <#cardView description#>
 @param index <#index description#>
 @param dragMode <#dragMode description#>
 */
- (void)cardView:(MYCardView *)cardView cardDidSCroll:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode;


/**
 卡片结束滑动

 @param cardView <#cardView description#>
 @param index <#index description#>
 @param dragMode <#dragMode description#>
 */
- (void)cardView:(MYCardView *)cardView cardEndScroll:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode;
@end

@protocol MYCardViewDataSource <NSObject>

@required


/**
 卡片Item

 @param cardView <#cardView description#>
 @param index <#index description#>
 @return <#return value description#>
 */
- (__kindof MYCardViewItem *)cardView:(MYCardView *)cardView itemForIndex:(NSInteger)index;


/**
 数据源个数

 @param cardView <#cardView description#>
 @return <#return value description#>
 */
- (NSInteger)cardViewPageCountForView:(MYCardView *)cardView;
@optional

- (CGSize)cardViewSizeForItem:(MYCardView *)cardView;
- (CGFloat)cardViewTopInsetForItem:(MYCardView *)cardView;

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
@property (nonatomic, assign) NSInteger currentIndex;

@end

