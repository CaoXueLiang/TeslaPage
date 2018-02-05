//
//  CXLTarBar.h
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CXLTarBarDelegate <NSObject>
- (void)didClickItermAtIndex:(NSInteger)index;
@end

@interface CXLTarBar : UIScrollView
/** 代理 */
@property (nonatomic,weak) id<CXLTarBarDelegate> tabDelegate;

/** 默认状态的颜色 */
@property (nonatomic,strong) UIColor *normalColor;

/** 选中状态下的颜色 */
@property (nonatomic,strong) UIColor *selectColor;

/** 默认状态下的字体大小 */
@property (nonatomic,strong) UIFont *normalFont;

/** 选中状态下的字体大小 */
@property (nonatomic,strong) UIFont *selectFont;

/** iterm之间的间距 */
@property (nonatomic,assign) CGFloat itermPadding;

///设置iterm数组
- (void)setTarBarItermArray:(NSArray *)itermArray;

///刷新字体，颜色属性
- (void)updateTarBarWithCurrentIndex:(NSInteger)index;

///下划线滚动到相应的位置
- (void)lineViewScrollToIndex:(NSInteger)index animated:(BOOL)animated;

//设置选中Iterm的contentOffset
- (void)scrollToIndex:(NSInteger)toIndex animated:(BOOL)animated;

///下划线滚动方法(pageView滑动调用)
- (void)lineViewScrollToContentRatio:(CGFloat)contentRatio;
@end

