//
//  CXLCoverController.m
//  TeslaPage
//
//  Created by 曹学亮 on 2018/2/3.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLCoverController.h"
#import "CXLPageController.h"

@interface CXLCoverController ()
@property (nonatomic,strong) UIView *coverView;
@end

@implementation CXLCoverController
#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCoverView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)loadCoverView{
    if (self.coverView) {
        [self.coverView removeFromSuperview];
        self.coverView = nil;
    }
    self.coverView = [self preferCoverView];
    self.coverView.frame = [self preferCoverFrame];
    [self.view addSubview:self.coverView];
}

- (void)reloadData{
    [super reloadData];
    [self loadCoverView];
}

#pragma mark - CXLPageController M
- (void)scrollWithPageOffset:(CGFloat)realOffset index:(NSInteger)index{
    [super scrollWithPageOffset:realOffset index:index];
    CGFloat currentOffSet = realOffset + [self pageContentInsetTopAtIndex:index];
    CGFloat top = [self preferTarBarOriginalY] - currentOffSet;
    if (currentOffSet >= 0) {
        if (top <= self.minTarBarOffsetY) {
            top = self.minTarBarOffsetY;
        }
    }else{
        if (top >= self.maxTarBarOffsetY) {
            top = self.maxTarBarOffsetY;
        }
    }
    
    currentOffSet = [self preferTarBarOriginalY] - top;
    CGFloat coverHeight = [self preferCoverFrame].size.height - currentOffSet;
    self.coverView.height = MAX(0, coverHeight);
}

- (CGFloat)pageContentInsetTopAtIndex:(NSInteger)index{
    CGFloat pageTop = [super pageContentInsetTopAtIndex:index];
    return pageTop > [self preferCoverFrame].origin.y + [self preferCoverFrame].size.height ? pageTop : [self preferCoverFrame].origin.y + [self preferCoverFrame].size.height;
}

#pragma mark - CXLCoverControllerDataSource
- (UIView *)preferCoverView{
    return nil;
}

- (CGRect)preferCoverFrame{
    return CGRectZero;
}

@end
