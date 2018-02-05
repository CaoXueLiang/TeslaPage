//
//  CXLMainController.m
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLMainController.h"
#import "CXLSubListController.h"

@interface CXLMainController ()

@end

static  CGFloat const KCoverHeight = 280;
@implementation CXLMainController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"首页";
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (NSInteger)numberOfControllers{
    return 6;
}

- (UIViewController *)controllerAtIndex:(NSInteger)index{
    CXLSubListController *coverController = [[CXLSubListController alloc] init];
    coverController.view.frame = [self preferPageViewFrame];
    
    if (index == 0) {
        coverController.view.backgroundColor = [UIColor greenColor];
    } else if (index == 1) {
        coverController.view.backgroundColor = [UIColor blueColor];
    } else if (index == 2){
        coverController.view.backgroundColor = [UIColor purpleColor];
    }else if (index == 3){
        coverController.view.backgroundColor = [UIColor yellowColor];
    }
    return coverController;
}

- (NSInteger)preferPageFirstAtIndex{
    return 1;
}

- (BOOL)isPreLoad {
    return NO;
}

- (UIView *)preferCoverView{
    UIImageView *view = [[UIImageView alloc] initWithFrame:[self preferCoverFrame]];
    view.image = [UIImage imageNamed:@"top"];
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    //取消交互，才能使View跟随ScrollView
    view.userInteractionEnabled = NO;
    return view;
}

- (CGFloat)preferTarBarOriginalY{
    return KCoverHeight;
}

- (CGRect)preferCoverFrame{
    return CGRectMake(0, 0, kScreenWidth, KCoverHeight);
}

- (NSArray *)itermsArray{
    return @[@"第一页",@"第二页",@"第三页",@"第四页",@"第五页",@"第六页",];
}

@end
