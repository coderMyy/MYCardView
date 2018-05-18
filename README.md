# MYCardView
</p>
</p>
<b>类似探探的卡片滑动，左滑不喜欢，右滑喜欢，也可通过按钮点击实现喜欢与不喜欢。
</p>
</p>
</p>

## 使用方法:
### 拖动MYCardView文件夹进入项目,类似tableView的用法

```
#pragma mark - dataSource
- (NSInteger)handleViewPageCountForView:(MYCardView *)handleView
{
return self.dataSource.count;
}

- (CGSize)handleViewSizeForItem:(MYCardView *)handleView
{
return CGSizeMake(345,480);
}

- (CGFloat)handleViewTopInsetForItem:(MYCardView *)handleView
{
return 12;
}

- (__kindof MYCardViewItem *)handleView:(MYCardView *)handleView itemForIndex:(NSInteger)index
{
if (index>self.dataSource.count-1) {
return nil;
}
//TestCardItem类继承于MYCardViewItem
TestCardItem *cardItem = [handleView dequeueReusableItemWithIdentifier:@"TestCardItem"];
cardItem.carModel = self.dataSource[index];
return cardItem;
}



#pragma mark - delegate
- (void)handleView:(MYCardView *)handleView didClickItemAtIndex:(NSInteger)index
{
NSLog(@"==============点击了卡片===========索引%li",index);
}

- (void)handleView:(MYCardView *)handleView beginMoveDirection:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode
{
NSLog(@"--------开始滑动--------");
}

- (void)handleView:(MYCardView *)handleView cardEndScroll:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode
{
NSLog(@"--------滑动结束--------");
}

- (void)handleView:(MYCardView *)handleView cardDidScroll:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode
{
NSLog(@"-------正在滑动----------");
}

- (void)handleView:(MYCardView *)handleView cancelDrag:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode
{
NSLog(@"------取消了第%li个的滑动",index);
}

- (void)handleView:(MYCardView *)handleView effectiveDragDirection:(MYCardViewDragDirectionType)direction itemIndex:(NSInteger)index dragMode:(MYCardViewDragMode)dragMode
{
NSLog(@"===========成功滑动卡片==========索引%li",index);
}


// 设置代理和数据源
_cardView.dataSource = self;
_cardView.delegate = self;

//注册卡片Item
[_cardView registerClass:[TestCardItem class] forItemReuseIdentifier:@"TestCardItem"];

```


## 1. 手势左滑不喜欢，右滑喜欢
</p>
</p>

![image](https://github.com/coderMyy/MYCardView/blob/master/examplePic/pic1.gif)

</p>
</p>

## 2. 按钮点击喜欢，不喜欢
</p>
</p>

![image](https://github.com/coderMyy/MYCardView/blob/master/examplePic/pic2.gif)

</p>
</p>

### 注意：
<b> 实际开发中，想要实现无缝滑动，需要在当前数据源未使用完时就进行提前预加载下一批数据，至少需要提前5个开始加载。如果预加载失败，卡片会被滑完，所以返回item方法只需要判断索引index和数据源即可，如果加载完了返回nil .详细见demo


