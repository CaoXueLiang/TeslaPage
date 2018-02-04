//
//  CXLPageController.m
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLPageController.h"
#import "CXLPageContentView.h"

/**滚动方向*/
typedef NS_ENUM(NSInteger,CXLPageScrollDirection) {
    CXLPageScrollDirectionLeft = 0,
    CXLPageScrollDirectionRight = 1,
};

@interface CXLPageController ()<UIScrollViewDelegate>
/** 容器scrollView */
@property (nonatomic,strong) CXLPageContentView *scrollView;
/** 保存对应索引下的controller */
@property (nonatomic,strong) NSMutableDictionary *controllersDict;
/** 保存对应索引下的contentOffset */
@property (nonatomic,strong) NSMutableDictionary *lastContentOffsetDict;
/** 保存对应索引下的ContentSize */
@property (nonatomic,strong) NSMutableDictionary *lastContentSizeDict;
/** 上一次选中的索引 */
@property (nonatomic,assign) NSInteger lastSelectedIndex;
/** 当前选中的索引 */
@property (nonatomic,assign,readwrite) NSInteger currentPageIndex;
/** 将要移动到的索引 */
@property (nonatomic,assign) NSInteger guessToIndex;
/** 初始偏移量 */
@property (nonatomic,assign) CGFloat originalOffset;
@property (nonatomic,assign) BOOL firstWillAppear;
@property (nonatomic,assign) BOOL firstWillLayoutSubViews;
@property (nonatomic,assign) BOOL firstDidAppear;
@end

@implementation CXLPageController
#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.firstWillAppear = YES;
    self.firstDidAppear = YES;
    self.firstWillLayoutSubViews = YES;
    
    self.scrollView = [[CXLPageContentView alloc]initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.firstWillAppear) {
        //滚动到指定索引
        if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
            [self.delegate changeToSubController:[self p_controllerAtIndex:self.currentPageIndex]];
        }
        
        //解决手势冲突
        if ([self.dataSource respondsToSelector:@selector(screenEdgePanGestureRecognizer)] && [self.dataSource screenEdgePanGestureRecognizer]) {
            [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:[self.dataSource screenEdgePanGestureRecognizer]];
        }else{
            if ([self p_screenEdgePanGestureRecognizer]) {
                [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:[self p_screenEdgePanGestureRecognizer]];
            }
        }
        self.firstWillAppear = NO;
        [self p_updateScrollViewLayoutIfNeed];
    }
    
    [[self p_controllerAtIndex:self.currentPageIndex] beginAppearanceTransition:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.firstDidAppear) {
        //滚动到指定索引
        if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
            [self.delegate changeToSubController:[self p_controllerAtIndex:self.currentPageIndex]];
        }
        self.firstDidAppear = NO;
    }
    
    [[self p_controllerAtIndex:self.currentPageIndex] endAppearanceTransition];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (self.firstWillLayoutSubViews) {
        [self p_updateScrollViewLayoutIfNeed];
        [self p_updateScrollViewDisplayIndexIfNeed];
        self.firstWillLayoutSubViews = NO;
    }else{
        [self p_updateScrollViewLayoutIfNeed];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self clearMemory];
}

-(void)dealloc{
    self.delegate = nil;
    self.dataSource = nil;
    [self clearObserver];
    self.controllersDict = nil;
}

- (void)reloadPage{
    [self clearMemory];
    [self p_addVisibleViewControllerWithIndex:self.currentPageIndex];
    [self p_updateScrollViewLayoutIfNeed];
    [self showPageAtIndex:self.currentPageIndex animated:YES];
}

- (void)clearMemory{
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    [self.lastContentOffsetDict removeAllObjects];
    [self.lastContentSizeDict removeAllObjects];
    
    if (self.controllersDict.count > 0) {
        [self clearObserver];
        NSArray *controllerArray = self.controllersDict.allValues;
        [self.controllersDict removeAllObjects];
        for (UIViewController *vc in controllerArray) {
            [self p_removeFromeParentViewController:vc];
        }
        controllerArray = nil;
    }
}

- (void)clearObserver{
    [self.controllersDict.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *key = obj;
        UIViewController *controller = self.controllersDict[key];
        if ([controller conformsToProtocol:@protocol(CXLSubPageControllerDataSource)]) {
            UIScrollView *tmpScrollView = [(UIViewController<CXLSubPageControllerDataSource> *)controller preferScrollView];
            [tmpScrollView removeObserver:self forKeyPath:@"contentOffset"];
        }
    }];
}

/** return NO的方式规避添加/删除/切换的不合适的生命周期调用*/
- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    UIScrollView *scrollView = object;
    NSInteger index = scrollView.tag;
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (scrollView.tag != self.currentPageIndex) {
            return;
        }
        
        if (self.controllersDict.count == 0) {
            return;
        }
        
        BOOL isNotNeedChangeContentOffset = scrollView.contentSize.height < kScreenHeight - KTopHeight  &&  fabs ([self.lastContentSizeDict[@(index)] floatValue] -scrollView.contentSize.height) > 1.0;
        
        if (isNotNeedChangeContentOffset) {
            if (self.lastContentOffsetDict[@(index)] &&  fabs ([self.lastContentOffsetDict[@(index)] floatValue] -scrollView.contentOffset.y) >0.1) {
                scrollView.contentOffset = CGPointMake(0, [self.lastContentOffsetDict[@(index)] floatValue]);
            }
        } else {
            self.lastContentOffsetDict[@(index)] = @(scrollView.contentOffset.y);
            [self.delegate scrollWithPageOffset:scrollView.contentOffset.y index:index];
        }
        
        self.lastContentSizeDict[@(index)] = @(scrollView.contentSize.height);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.scrollView && scrollView.isDragging) {
        CGFloat offset = scrollView.contentOffset.x;
        CGFloat width = scrollView.width;
        NSInteger lastGuestureIndex = self.guessToIndex < 0 ? self.currentPageIndex : self.guessToIndex;
        
        if (self.originalOffset < offset) {
            self.guessToIndex = ceil(offset/width);
        }else if (self.originalOffset >= offset){
            self.guessToIndex = floor(offset/width);
        }
        
        NSInteger maxCount = [self.dataSource numberOfControllers];
        if ([self p_isPreLoad]) {
            //预加载
            if (lastGuestureIndex != self.guessToIndex &&
                self.guessToIndex != self.currentPageIndex &&
                self.guessToIndex >= 0 &&
                self.guessToIndex < maxCount) {
                
                UIViewController *fromVC = [self p_controllerAtIndex:self.currentPageIndex];
                UIViewController *toVC = [self p_controllerAtIndex:self.guessToIndex];
                
                if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
                    [self.delegate changeToSubController:toVC];
                }
                
                //管理生命周期
                [toVC beginAppearanceTransition:YES animated:YES];
                if (lastGuestureIndex == self.currentPageIndex) {
                    [fromVC beginAppearanceTransition:NO animated:YES];
                }
                
                if (lastGuestureIndex != self.currentPageIndex &&
                    lastGuestureIndex >= 0 &&
                    lastGuestureIndex < maxCount) {
                    UIViewController *lastGuestVC = [self p_controllerAtIndex:lastGuestureIndex];
                    [lastGuestVC beginAppearanceTransition:NO animated:YES];
                    [lastGuestVC endAppearanceTransition];
                }
            }
        }else{
            //非预加载
            if (self.guessToIndex != self.currentPageIndex &&
                !self.scrollView.isDecelerating) {
                if (lastGuestureIndex != self.guessToIndex &&
                    self.guessToIndex >= 0 &&
                    self.guessToIndex < maxCount) {
                    
                    if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
                        [self.delegate changeToSubController:[self p_controllerAtIndex:self.currentPageIndex]];
                    }
                }
            }
        }
     }
    //水平滚动的回调
    if ([self.delegate respondsToSelector:@selector(scrollViewContentOffsetWithRatio: draging:)]) {
        [self.delegate scrollViewContentOffsetWithRatio:scrollView.contentOffset.x/scrollView.width draging:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (!scrollView.isDecelerating) {
        self.originalOffset = scrollView.contentOffset.x;
        self.guessToIndex = self.currentPageIndex;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self p_updatePageViewAfterDragging:scrollView];
}

#pragma mark - Private Menthod
- (void)p_removeFromeParentViewController:(UIViewController *)controller{
    //`ViewController`从`容器ViewController`添加或移除前调用
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

- (void)p_addVisibleViewControllerWithIndex:(NSInteger)index{
    if (index < 0 || index >= [self.dataSource numberOfControllers]) {
        return;
    }
    UIViewController *controller = [self p_controllerAtIndex:index];
    CGRect childViewFrame = [self.scrollView calculationVisibleViewControllerFrameAtIndex:index];
    if (![self.childViewControllers containsObject:controller]) {
        [self addChildViewController:controller];
        [self didMoveToParentViewController:controller];
    }
    [super addChildViewController:controller];
    controller.view.frame = childViewFrame;
    [self.scrollView addSubview:controller.view];
}

- (UIViewController *)p_controllerAtIndex:(NSInteger)index{
    if (![self.controllersDict objectForKey:@(index)]) {
        UIViewController *controller = [self.dataSource controllerAtIndex:index];
        if (controller) {
            controller.view.hidden = NO;
            if ([controller conformsToProtocol:@protocol(CXLSubPageControllerDataSource)]) {
                //绑定scrollView通知
                [self p_bindController:(UIViewController<CXLSubPageControllerDataSource> *)controller index:index];
            }
            
            [self.controllersDict setObject:controller forKey:@(index)];
            [self p_addVisibleViewControllerWithIndex:index];
        }
    }
    return [self.controllersDict objectForKey:@(index)];
}

- (void)p_bindController:(UIViewController<CXLSubPageControllerDataSource> *)controller index:(NSInteger)index{
    
    UIScrollView *scrollView = [controller preferScrollView];
    scrollView.scrollsToTop = NO;
    scrollView.tag = index;
    
    //设置contentInsert
    if ([self.dataSource respondsToSelector:@selector(pageContentInsetTopAtIndex:)]) {
        UIEdgeInsets contentInsert = scrollView.contentInset;
        scrollView.contentInset = UIEdgeInsetsMake([self.dataSource pageContentInsetTopAtIndex:index], contentInsert.left, contentInsert.bottom, contentInsert.right);
        //ios11适配
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    
    scrollView.contentOffset = CGPointMake(0, -scrollView.contentInset.top);
}

- (void)p_updateScrollViewLayoutIfNeed{
    if (self.scrollView.width > 0) {
        [self.scrollView setIterm:self.dataSource];
    }
}

- (void)p_updateScrollViewDisplayIndexIfNeed{
    if (self.scrollView.width <= 0) {
        return;
    }
    [self p_addVisibleViewControllerWithIndex:self.currentPageIndex];
    self.scrollView.contentOffset = [self.scrollView calculationOffsetAtIndex:self.currentPageIndex];
    [self p_controllerAtIndex:self.currentPageIndex].view.frame = [self.scrollView calculationVisibleViewControllerFrameAtIndex:self.currentPageIndex];
}

- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated{
    self.lastSelectedIndex = self.currentPageIndex;
    self.currentPageIndex = index;
    
    if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
        [self.delegate changeToSubController:[self p_controllerAtIndex:index]];
    }
    
    [self p_addVisibleViewControllerWithIndex:index];
    [self p_scrollAnimation:animated];
}

- (void)p_scrollAnimation:(BOOL)animated{
    UIViewController *lastController = [self p_controllerAtIndex:self.lastSelectedIndex];
    UIViewController *currentController = [self p_controllerAtIndex:self.currentPageIndex];
    
    [currentController beginAppearanceTransition:YES animated:animated];
    if (self.currentPageIndex != self.lastSelectedIndex) {
        [lastController beginAppearanceTransition:NO animated:animated];
    }
    
    //设置ScrollView的contentOffSet
    [self.scrollView setContentOffset:[self.scrollView calculationOffsetAtIndex:self.currentPageIndex] animated:NO];
    
    [currentController endAppearanceTransition];
    if (self.currentPageIndex != self.lastSelectedIndex) {
        [lastController endAppearanceTransition];
    }
    
    if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
        [self.delegate changeToSubController:currentController];
    }
}

- (UIScreenEdgePanGestureRecognizer *)p_screenEdgePanGestureRecognizer{
    UIScreenEdgePanGestureRecognizer *gesture = nil;
    for (UIGestureRecognizer *recognizer in self.navigationController.view.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            gesture = (UIScreenEdgePanGestureRecognizer *)recognizer;
            break;
        }
    }
    return gesture;
}

- (BOOL)p_isPreLoad{
    return [self.dataSource respondsToSelector:@selector(isPreLoad)] && [self.dataSource isPreLoad];
}

- (void)p_updatePageViewAfterDragging:(UIScrollView *)scrollView{
    NSInteger newIndex = [self.scrollView calculationIndexWithOffset:scrollView.contentOffset.x width:scrollView.width];
    NSInteger oldIndex = self.currentPageIndex;
    self.currentPageIndex = newIndex;
    
    UIViewController *oldController = [self p_controllerAtIndex:oldIndex];
    UIViewController *newController = [self p_controllerAtIndex:newIndex];
    UIViewController *guessController = [self p_controllerAtIndex:self.guessToIndex];
    
    if (newIndex == oldIndex) {
        if (self.guessToIndex >= 0 && self.guessToIndex < [self.dataSource numberOfControllers]) {
            [oldController beginAppearanceTransition:YES animated:YES];
            [oldController endAppearanceTransition];
            
            [guessController beginAppearanceTransition:NO animated:YES];
            [guessController endAppearanceTransition];
        }
    }else{
        if (![self p_isPreLoad]) {
            [newController beginAppearanceTransition:YES animated:YES];
            [oldController beginAppearanceTransition:NO animated:YES];
        }
        [newController endAppearanceTransition];
        [oldController endAppearanceTransition];
    }
    
    self.originalOffset = scrollView.contentOffset.x;
    self.guessToIndex = newIndex;
    if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
        [self.delegate changeToSubController:[self p_controllerAtIndex:self.currentPageIndex]];
    }
}

#pragma mark - Public Menthod
- (NSInteger)indexOfController:(UIViewController *)vc{
    __block NSInteger number = -1;
    [self.controllersDict.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *controller = self.controllersDict[obj];
        if (vc == controller) {
            number = [obj integerValue];
        }
    }];
    return number;
}

- (void)updateCurrentIndex:(NSInteger)index{
    self.currentPageIndex = index;
}

#pragma mark - Setter && Getter
- (NSMutableDictionary *)controllersDict{
    if (!_controllersDict) {
        _controllersDict = [[NSMutableDictionary alloc]init];
    }
    return _controllersDict;
}

- (NSMutableDictionary *)lastContentOffsetDict{
    if (!_lastContentOffsetDict) {
        _lastContentOffsetDict = [[NSMutableDictionary alloc]init];
    }
    return _lastContentOffsetDict;
}

- (NSMutableDictionary *)lastContentSizeDict{
    if (!_lastContentSizeDict) {
        _lastContentSizeDict = [[NSMutableDictionary alloc]init];
    }
    return _lastContentSizeDict;
}

@end
