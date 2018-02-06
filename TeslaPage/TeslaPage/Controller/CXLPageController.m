//
//  CXLPageController.m
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLPageController.h"
#import "CXLPageContentView.h"

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
/** 是否是第一次 */
@property (nonatomic,assign) BOOL isFirst;
@end

@implementation CXLPageController
#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.isFirst = YES;
    
    self.scrollView = [[CXLPageContentView alloc]initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    [self setUp];
}

- (void)setUp{
    //解决手势冲突
    if ([self.dataSource respondsToSelector:@selector(screenEdgePanGestureRecognizer)] && [self.dataSource screenEdgePanGestureRecognizer]) {
        [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:[self.dataSource screenEdgePanGestureRecognizer]];
    }else{
        if ([self p_screenEdgePanGestureRecognizer]) {
            [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:[self p_screenEdgePanGestureRecognizer]];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
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
    [self.scrollView setIterm:self.dataSource];
    [self showPageAtIndex:self.currentPageIndex animated:YES];

    //滚动到指定索引
    if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
        [self.delegate changeToSubController:[self p_controllerAtIndex:self.currentPageIndex]];
    }
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
        NSInteger maxCount = [self.dataSource numberOfControllers];
        CGFloat offset = scrollView.contentOffset.x;
        CGFloat width = scrollView.width;
        NSInteger lastSelectIndex = self.currentPageIndex;
        
        if (self.originalOffset < offset) {
            self.guessToIndex = MIN(maxCount, ceil(offset/width));
        }else if (self.originalOffset >= offset){
            self.guessToIndex = MAX(0, floor(offset/width));
        }
        
        if ([self p_isPreLoad]) {
            //预加载
            if (lastSelectIndex != self.guessToIndex){
                
                //NSLog(@"%ld-----%ld",self.currentPageIndex,self.guessToIndex);
                UIViewController *fromVC = [self p_controllerAtIndex:self.currentPageIndex];
                UIViewController *toVC = [self p_controllerAtIndex:self.guessToIndex];
                
                if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
                    [self.delegate changeToSubController:toVC];
                }

            }
        }else{
            //非预加载
            if (self.guessToIndex != self.currentPageIndex &&
                !self.scrollView.isDecelerating) {
                if (lastSelectIndex != self.guessToIndex){
                    if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
                        [self.delegate changeToSubController:[self p_controllerAtIndex:self.currentPageIndex]];
                    }
                }
            }
        }
     }
    
    /**
     当点击TarBar切换界面时，不调用代理方法
     scrollView.tracking = NO，scrollView.dragging = NO，scrollView.decelerating = NO
     */
    if (scrollView == self.scrollView && !(scrollView.tracking == NO && scrollView.dragging == NO && scrollView.decelerating == NO)) {
        //水平滚动的回调
        if ([self.delegate respondsToSelector:@selector(scrollViewContentOffsetWithRatio: draging:)]) {
            [self.delegate scrollViewContentOffsetWithRatio:scrollView.contentOffset.x/scrollView.width draging:YES];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (!scrollView.isDecelerating) {
        self.originalOffset = scrollView.contentOffset.x;
        self.guessToIndex = self.currentPageIndex;
    }
}

/** 滚动停止时调用*/
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self p_updatePageViewAfterDragging:scrollView];
}

#pragma mark - Private Menthod
- (void)p_removeFromeParentViewController:(UIViewController *)controller{
    //`ViewController`从`容器ViewController`添加或移除前调用
    // removeChildViewController
    [controller willMoveToParentViewController:nil];
    [controller beginAppearanceTransition:NO animated:YES];
    [controller.view removeFromSuperview];
    [controller endAppearanceTransition];
    [controller removeFromParentViewController];
}

/** 将当前索引控制器添加到Self */
- (void)p_addVisibleViewControllerWithIndex:(NSInteger)index{
    if (index < 0 || index >= [self.dataSource numberOfControllers]) {
        return;
    }
    UIViewController *controller = [self p_controllerAtIndex:index];
    CGRect childViewFrame = [self.scrollView calculationVisibleViewControllerFrameAtIndex:index];
    if (![self.childViewControllers containsObject:controller]) {
        // addChildViewController
        [self addChildViewController:controller];
        controller.view.frame = childViewFrame;
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

/** 获取保存在字典中的当前索引的控制器*/
- (UIViewController *)p_controllerAtIndex:(NSInteger)index{
    if (![self.controllersDict objectForKey:@(index)]) {
        UIViewController *controller = [self.dataSource controllerAtIndex:index];
        if (controller) {
            controller.view.hidden = NO;
            if ([controller conformsToProtocol:@protocol(CXLSubPageControllerDataSource)]) {
                //绑定scrollView通知
                [self p_bindController:(UIViewController<CXLSubPageControllerDataSource> *)controller index:index];
                
                //添加子控制器
                CGRect childViewFrame = [self.scrollView calculationVisibleViewControllerFrameAtIndex:index];
                if (![self.childViewControllers containsObject:controller]) {
                    [self addChildViewController:controller];
                    controller.view.frame = childViewFrame;
                    [self.scrollView addSubview:controller.view];
                    [controller didMoveToParentViewController:self];
                }
            }
            [self.controllersDict setObject:controller forKey:@(index)];
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

- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated{
    //选中的是当前索引，不进行任何操作
    if (self.currentPageIndex == index && !self.isFirst) {
        return;
    }
    self.lastSelectedIndex = self.currentPageIndex;
    self.currentPageIndex = index;
    [self p_scrollAnimation:animated];
    self.isFirst = NO;
}

- (void)p_scrollAnimation:(BOOL)animated{
    UIViewController *lastController = [self p_controllerAtIndex:self.lastSelectedIndex];
    UIViewController *currentController = [self p_controllerAtIndex:self.currentPageIndex];

    
//    [lastController beginAppearanceTransition:NO animated:animated];
//    [currentController beginAppearanceTransition:YES animated:NO];

    //设置ScrollView的contentOffSet
    [self.scrollView setContentOffset:[self.scrollView calculationOffsetAtIndex:self.currentPageIndex] animated:NO];
    
    //[self.delegate changeToSubController:currentController];
    
//    [lastController endAppearanceTransition];
//    [currentController endAppearanceTransition];
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
 
    if (newIndex != oldIndex) {
        return;
    }
//    UIViewController *oldController = [self p_controllerAtIndex:oldIndex];
//    UIViewController *newController = [self p_controllerAtIndex:newIndex];
//
//    [newController beginAppearanceTransition:YES animated:YES];
//    [oldController beginAppearanceTransition:NO animated:YES];
//
    self.originalOffset = scrollView.contentOffset.x;
    self.guessToIndex = newIndex;
    if ([self.delegate respondsToSelector:@selector(changeToSubController:)]) {
        [self.delegate changeToSubController:[self p_controllerAtIndex:self.currentPageIndex]];
    }
    
//    if (![self.dataSource isPreLoad]) {
//        [newController beginAppearanceTransition:YES animated:YES];
//        [oldController beginAppearanceTransition:NO animated:YES];
//    }
//   
//    [newController endAppearanceTransition];
//    [oldController endAppearanceTransition];
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
//        for (int i = 0; i < [self.dataSource numberOfControllers]; i++) {
//            UIViewController *controller = [self p_controllerAtIndex:i];
//            [_controllersDict setObject:controller forKey:@(i)];
//        }
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
