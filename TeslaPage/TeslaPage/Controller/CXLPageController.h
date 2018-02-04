//
//  CXLPageController.h
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXLPageProtocols.h"

@interface CXLPageController : UIViewController

/** 数据源 */
@property (nonatomic,weak) id<CXLPageControllerDataSource> dataSource;
/** 代理 */
@property (nonatomic,weak) id<CXLPageControllerDelegate> delegate;
/** 当前选中的索引 */
@property (nonatomic,assign,readonly) NSInteger currentPageIndex;

/** 必须在reloadPage之前，把DataSource 回调的pageCount变了 */
- (void)reloadPage;

/** 切换界面 */
- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated;

/** 返回当前控制器的索引 */
- (NSInteger)indexOfController:(UIViewController *)controller;

/** 刷新 */
- (void)updateCurrentIndex:(NSInteger)index;

@end
