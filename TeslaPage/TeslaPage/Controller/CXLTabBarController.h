//
//  CXLTabBarController.h
//  TeslaPage
//
//  Created by 曹学亮 on 2018/2/3.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXLPageProtocols.h"

@interface CXLTabBarController : UIViewController
<CXLPageControllerDataSource,CXLPageControllerDelegate>

/** 纵向滑动时tarBarY坐标最小值 */
@property (nonatomic,assign) CGFloat minTarBarOffsetY;
/** 纵向滑动时tarBarY坐标最大值 */
@property (nonatomic,assign) CGFloat maxTarBarOffsetY;

/** 优先展示哪个页面, reloadData后 会调用这个方法*/
- (NSInteger)preferPageFirstAtIndex;

/** 需要完全刷新页面时调用这个接口 */
- (void)reloadData;

- (CGFloat)preferTarBarOriginalY;
@end
