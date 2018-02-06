//
//  CXLPageProtocols.h
//  TeslaPage
//
//  Created by 曹学亮 on 2018/2/2.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CXLPageController;
@protocol CXLPageControllerDataSource <NSObject>
@required
/** 控制器的个数 */
- (NSInteger)numberOfControllers;

/** 返回当前索引下的控制器 */
- (UIViewController *)controllerAtIndex:(NSInteger)index;

/** 返回pageController的view的frame */
- (CGRect)preferPageViewFrame;

@optional
/** 用于设置子controller的scrollview的inset */
- (CGFloat)pageContentInsetTopAtIndex:(NSInteger)index;

/** 解决侧滑失效问题 */
- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer;

/** 交互切换的时候，是否预加载 */
- (BOOL)isPreLoad;

/** 解决非交互切换 contentInsert问题*/
- (BOOL)getCannotScrollWithPageOffset;
@end



@protocol CXLPageControllerDelegate <NSObject>
@optional
/** 切换到子Controller */
- (void)changeToSubController:(UIViewController *)toController;

/** 横向滑动的回调 */
- (void)scrollViewContentOffsetWithRatio:(CGFloat)ratio draging:(BOOL)draging;

/** 垂直滚动的回调 */
- (void)scrollWithPageOffset:(CGFloat)realOffset index:(NSInteger)index;

/** 解决点击非交互切换 contentInsert问题 */
- (void)willChangeInit;
@end


//如ChildController实现了这个协议，表示Tab和Cover会跟随Page纵向滑动
@protocol CXLSubPageControllerDataSource <NSObject>
@optional
/** 子controller需要实现这个方法,如果需要cover跟着上下滑动 */
- (UIScrollView *)preferScrollView;
@end



