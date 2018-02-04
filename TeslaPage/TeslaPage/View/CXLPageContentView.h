//
//  CXLPageContentView.h
//  TeslaPage
//
//  Created by 曹学亮 on 2018/2/2.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXLPageProtocols.h"

@interface CXLPageContentView : UIScrollView
/** 计算当前索引下可见区域的frame */
- (CGRect)calculationVisibleViewControllerFrameAtIndex:(NSInteger)index;

/** 计算当前索引下的偏移量 */
- (CGPoint)calculationOffsetAtIndex:(NSInteger)index;

/** 根据偏移量计算当前索引值 */
- (NSInteger)calculationIndexWithOffset:(CGFloat)offset width:(CGFloat)width;

/** 设置scrollView的 contentSize */
- (void)setIterm:(id<CXLPageControllerDataSource>)iterm;
@end

