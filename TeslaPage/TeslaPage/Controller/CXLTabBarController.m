//
//  CXLTabBarController.m
//  TeslaPage
//
//  Created by 曹学亮 on 2018/2/3.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLTabBarController.h"
#import "CXLTarBar.h"
#import "CXLPageController.h"

static const CGFloat KTarBarHeight = 50;
@interface CXLTabBarController ()<CXLTarBarDelegate>
/** TarBar视图 */
@property (nonatomic,strong) CXLTarBar *tarBar;
/** 分页视图 */
@property (nonatomic,strong) CXLPageController *pageController;
/** 解决水平滚动*/
@property (nonatomic,assign) BOOL cannotScrollWithPageOffset;
@end

@implementation CXLTabBarController
#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.minTarBarOffsetY = KTopHeight;
    self.maxTarBarOffsetY = kScreenHeight;
    [self setupSubViews];
}

- (void)setupSubViews{
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    [self.view addSubview:self.tarBar];
    self.tarBar.top = [self preferTarBarOriginalY];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.cannotScrollWithPageOffset = NO;
    [self.pageController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.pageController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.cannotScrollWithPageOffset = YES;
    [self.pageController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.pageController endAppearanceTransition];
}

#pragma mark - Public Menthod
- (NSInteger)preferPageFirstAtIndex{
    return 0;
}

- (CGFloat)preferTarBarOriginalY{
    return KTopHeight;
}

- (void)reloadData{
    [self.pageController updateCurrentIndex:[self preferPageFirstAtIndex]];
    self.pageController.view.frame = [self preferPageViewFrame];
    [self.pageController reloadPage];
    
    //初始化TarBar选中的位置
    [self.tarBar updateTarBarWithCurrentIndex:[self preferPageFirstAtIndex]];
    [self.tarBar lineViewScrollToIndex:[self preferPageFirstAtIndex] animated:NO];
}

- (NSArray *)itermsArray{
    return nil;
}

#pragma mark - Private Menthod
- (CGFloat)p_tabBarTopWithContentOffset:(CGFloat)offset{
    CGFloat top = [self preferTarBarOriginalY] - offset;
    if (offset >= 0) {
        if (top <= self.minTarBarOffsetY) {
            top = self.minTarBarOffsetY;
        }
    } else {
        if (top >= self.maxTarBarOffsetY) {
            top = self.maxTarBarOffsetY;
        }
    }
    return top;
}

#pragma mark - CXLPageControllerDataSource
- (NSInteger)numberOfControllers{
    return 0;
}

- (UIViewController *)controllerAtIndex:(NSInteger)index{
    return nil;
}

- (CGRect)preferPageViewFrame{
    return CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}

- (CGFloat)pageContentInsetTopAtIndex:(NSInteger)index{
    return [self preferTarBarOriginalY] + KTarBarHeight - [self preferPageViewFrame].origin.y;
}

/** 解决侧滑失效问题 */
- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer{
    UIScreenEdgePanGestureRecognizer *gesture = nil;
    for (UIGestureRecognizer *recognizer in self.navigationController.view.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            gesture = (UIScreenEdgePanGestureRecognizer *)recognizer;
            break;
        }
    }
    return gesture;
}

- (BOOL)isPreLoad{
    return NO;
}

- (BOOL)getCannotScrollWithPageOffset{
    return self.cannotScrollWithPageOffset;
}

#pragma mark - CXLPageControllerDelegate
- (void)changeToSubController:(UIViewController *)toController{
    self.cannotScrollWithPageOffset = NO;
    if (!toController || [self numberOfControllers] <= 1) {
        return;
    }

    if ([toController conformsToProtocol:@protocol(CXLSubPageControllerDataSource)]) {
        UIViewController<CXLSubPageControllerDataSource> *toVCTemp =  (UIViewController<CXLSubPageControllerDataSource> *)toController;
        NSInteger newIndex = [self.pageController indexOfController:toVCTemp];
        CGFloat pageTop = [self pageContentInsetTopAtIndex:newIndex];
        CGFloat top = [self p_tabBarTopWithContentOffset:[toVCTemp preferScrollView].contentOffset.y + pageTop];

        //如果高度相同，不去修改offSet
        if (fabs(top - self.tarBar.frame.origin.y) > 0.1) {
            CGFloat scrollOffSet = [self preferTarBarOriginalY] - self.tarBar.top - [self pageContentInsetTopAtIndex:newIndex];
            [toVCTemp preferScrollView].contentOffset = CGPointMake(0, scrollOffSet);
        }
    }
}

//横向滚动回调
- (void)scrollViewContentOffsetWithRatio:(CGFloat)ratio draging:(BOOL)draging{
    [self.tarBar lineViewScrollToContentRatio:ratio];
    [self.tarBar scrollToIndex:ratio animated:YES];
    [self.tarBar updateTarBarWithCurrentIndex:floor(ratio + 0.5)];
}

//垂直滚动回调
- (void)scrollWithPageOffset:(CGFloat)realOffset index:(NSInteger)index{
    CGFloat offset = realOffset + [self pageContentInsetTopAtIndex:index];
    self.tarBar.top = [self p_tabBarTopWithContentOffset:offset];
}

- (void)willChangeInit{
    self.cannotScrollWithPageOffset = YES;
}

#pragma mark - CXLTarBarDelegate
- (void)didClickItermAtIndex:(NSInteger)index{
   [self.pageController showPageAtIndex:index animated:YES];
}

#pragma mark - Setter && Getter
- (CXLTarBar *)tarBar{
    if (!_tarBar) {
        _tarBar = [[CXLTarBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), KTarBarHeight)];
        _tarBar.tabDelegate = self;
        _tarBar.normalFont = [UIFont systemFontOfSize:15];
        _tarBar.selectFont = [UIFont systemFontOfSize:15];
        _tarBar.normalColor = [UIColor blackColor];
        _tarBar.selectColor = [UIColor orangeColor];
        _tarBar.itermPadding = 20;
        [_tarBar setTarBarItermArray:[self itermsArray]];
        //初始化TarBar选中的位置
        [_tarBar updateTarBarWithCurrentIndex:[self preferPageFirstAtIndex]];
        [_tarBar lineViewScrollToIndex:[self preferPageFirstAtIndex] animated:NO];
    }
    return _tarBar;
}

- (CXLPageController *)pageController{
    if (!_pageController) {
        _pageController = [[CXLPageController alloc]init];
        _pageController.delegate = self;
        _pageController.dataSource = self;
        _pageController.view.frame = [self preferPageViewFrame];
        [_pageController updateCurrentIndex:[self preferPageFirstAtIndex]];
    }
    return _pageController;
}

@end
