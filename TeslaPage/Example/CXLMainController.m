//
//  CXLMainController.m
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLMainController.h"
#import "CXLSubListController.h"
#import "WeiBoHeaderView.h"
#import "WeiBoCustomNavigationView.h"

@interface CXLMainController ()
@property (nonatomic,assign) UIStatusBarStyle barStyle;
@property (nonatomic,strong) WeiBoHeaderView *headerView;
@property (nonatomic,strong) WeiBoCustomNavigationView *navigationView;
@end

static  CGFloat const KCoverHeight = 280;
@implementation CXLMainController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"首页";
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES];
    [self reloadData];
    [self.view addSubview:self.navigationView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.barStyle;
}

#pragma mark - DataSource
- (NSInteger)numberOfControllers{
    return self.itermsArray.count;
}

- (UIViewController *)controllerAtIndex:(NSInteger)index{
    CXLSubListController *coverController = [[CXLSubListController alloc] init];
    coverController.view.frame = [self preferPageViewFrame];
    coverController.currentIndex = index;
    if (index == 0) {
        coverController.view.backgroundColor = [UIColor greenColor];
    } else if (index == 1) {
        coverController.view.backgroundColor = [UIColor yellowColor];
    } else if (index == 2){
        coverController.view.backgroundColor = [UIColor purpleColor];
    }
    return coverController;
}

- (NSInteger)preferPageFirstAtIndex{
    return 1;
}

- (BOOL)isPreLoad {
    return YES;
}

- (UIView *)preferCoverView{
    return self.headerView;
}

- (CGFloat)preferTarBarOriginalY{
    return KCoverHeight;
}

- (CGRect)preferCoverFrame{
    return CGRectMake(0, 0, kScreenWidth, KCoverHeight);
}

- (NSArray *)itermsArray{
    return @[@"主页",@"微博",@"相册"];
}

- (void)scrollWithPageOffset:(CGFloat)realOffset index:(NSInteger)index{
    [super scrollWithPageOffset:realOffset index:index];
    [self.navigationView setAttributesWithOffSet:realOffset + KCoverHeight + 50];
    
    CGFloat ratio = MIN(MAX(0, realOffset + KCoverHeight + 50 / (250 - 2 *KTopHeight)), 1);
    if (ratio < 0.5) {
        self.barStyle = UIStatusBarStyleLightContent;
    }else{
        self.barStyle = UIStatusBarStyleDefault;
    }
    
    //更新状态栏颜色
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Setter && Getter
- (WeiBoHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[WeiBoHeaderView alloc]initWithFrame:[self preferCoverFrame]];
        //取消交互，才能使View跟随ScrollView
        _headerView.userInteractionEnabled = NO;
    }
    return _headerView;
}

- (WeiBoCustomNavigationView *)navigationView{
    if (!_navigationView) {
        @weakify(self);
        _navigationView = [WeiBoCustomNavigationView new];
        _navigationView.backBlock = ^{
            [weak_self.navigationController popViewControllerAnimated:YES];
        };
        _navigationView.moreBlock = ^{
            NSLog(@"点击了more按钮");
        };
    }
    return _navigationView;
}

@end
