//
//  CXLTarBar.h
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXLTabBarProtocol.h"

@interface CXLTarBar : UIScrollView

/**
 初始化方式
 @param frame frame
 @param dataSource 数据源
 @param delegate 代理
 @return TarBar
 */
- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<CXLTarBarDataSource>)dataSource delegate:(id<CXLTarBarDelegate>)delegate;

/** 数据源 */
@property (nonatomic,weak) id<CXLTarBarDataSource> tabDataSource;

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

///下划线滚动方法(pageView滑动调用)
- (void)lineViewScrollToContentRatio:(CGFloat)contentRatio;
@end

