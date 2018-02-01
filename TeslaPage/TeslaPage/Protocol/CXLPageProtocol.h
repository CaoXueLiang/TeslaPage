//
//  CXLPageProtocol.h
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
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

/** 页面是否可以滑动 */
- (BOOL)isSubPageCanScrollAtIndex:(NSInteger)index;
@end



@protocol CXLPageControllerDelegate <NSObject>
@optional


@end
