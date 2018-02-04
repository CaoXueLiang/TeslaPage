//
//  CXLPageContentView.m
//  TeslaPage
//
//  Created by 曹学亮 on 2018/2/2.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLPageContentView.h"
#import "CXLPageController.h"

@implementation CXLPageContentView
#pragma mark - Init Menthod
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_configure];
    }
    return self;
}

- (void)p_configure{
    self.autoresizingMask = (0x1<<6) - 1;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.scrollsToTop = NO;
    //ios11适配
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

#pragma mark - Public Menthod
- (CGRect)calculationVisibleViewControllerFrameAtIndex:(NSInteger)index{
    CGFloat offsetX = 0.0;
    offsetX = index *self.width;
    return CGRectMake(offsetX, 0, self.width, self.height);
}

- (CGPoint)calculationOffsetAtIndex:(NSInteger)index{
    CGFloat normalWidth = self.width;
    CGFloat maxWidth = self.contentSize.width;
    
    //offsetX的取值范围在0 ~ (maxWidth - normalWidth)之间
    CGFloat offsetX = MIN((maxWidth - normalWidth), MAX(0, index *normalWidth));
    return CGPointMake(offsetX, 0);
}

- (NSInteger)calculationIndexWithOffset:(CGFloat)offset width:(CGFloat)width{
    NSInteger currentIndex = (NSInteger)offset / width;
    currentIndex = MAX(0, currentIndex);
    return currentIndex;
}

- (void)setIterm:(id<CXLPageControllerDataSource>)iterm{
    NSInteger num = [iterm numberOfControllers];
    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.contentSize = CGSizeMake(num *self.width, self.height);
}

@end
