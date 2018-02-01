//
//  CXLTarBar.m
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLTarBar.h"
#import "CXLTarItermView.h"

@interface CXLTarBar()
@property (nonatomic,strong) NSMutableArray<CXLTarItermView *> *itermArray;
/** 选中的iterm的索引 */
@property (nonatomic,assign) NSInteger selectIndex;
/** 指示器View */
@property (nonatomic,strong) UIView *lineView;
@end

@implementation CXLTarBar
#pragma mark - Init Menthod
- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<CXLTarBarDataSource>)dataSource delegate:(id<CXLTarBarDelegate>)delegate{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.tabDataSource = dataSource;
        self.tabDelegate = delegate;
        [self p_setProperty];
        [self p_setTarItermView];
        [self p_setLineView];
    }
    return self;
}

#pragma mark - Private Menthod
- (void)p_setProperty{
    _normalColor = [UIColor blackColor];
    _selectColor = [UIColor orangeColor];
    _normalFont = [UIFont systemFontOfSize:15];
    _selectFont = [UIFont systemFontOfSize:15];
    _itermPadding = 20;
    _selectIndex = 0;
    
    self.contentSize = CGSizeZero;
    self.directionalLockEnabled = YES;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
}

- (void)p_setTarItermView{
    CGFloat tarBarContentWidth = 0;
    CGFloat totalMarginWidth = 0;
    CGFloat totalMiddleMargin = 0;
    CGFloat offSet = 0;
    
    totalMarginWidth = ([self.tabDataSource numberOfIterms] + 1) *_itermPadding;
    totalMiddleMargin = ([self.tabDataSource numberOfIterms] - 1) *_itermPadding;
    for (int i = 0; i < [self.tabDataSource numberOfIterms]; i++) {
        CGFloat itermWidth = [self.tabDataSource widthForItermAtIndex:i];
        tarBarContentWidth += itermWidth;
    }
    
    //当iterm的总宽度 < 屏幕宽度时,让Iterm总体居中
    if (tarBarContentWidth + totalMarginWidth > self.frame.size.width) {
        offSet = _itermPadding;
    }else{
        offSet = (self.frame.size.width - tarBarContentWidth - totalMiddleMargin) / 2.0;
    }
    
    //设置Iterm的属性
    for (int i = 0; i < [self.tabDataSource numberOfIterms]; i++) {
        CGFloat itermWidth = [self.tabDataSource widthForItermAtIndex:i];
        CXLTarItermView *iterm = [[CXLTarItermView alloc]init];
        iterm.frame = CGRectMake(offSet, 0, itermWidth, CGRectGetHeight(self.bounds));
        offSet += itermWidth + _itermPadding;
        
        iterm.titleLabel.textColor = _selectIndex == i ? _selectColor : _normalColor;
        iterm.titleLabel.font = _selectIndex == i ? _selectFont : _normalFont;
        iterm.titleLabel.text = [self.tabDataSource titleForItermAtIndex:i];
        iterm.tag = i;
        [iterm addTarget:self action:@selector(clickedTabBar:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:iterm];
        [self.itermArray addObject:iterm];
    }
    //设置contentSize
    self.contentSize = CGSizeMake(offSet, self.frame.size.height);
}

- (void)p_setLineView{
    CGFloat width = [self.tabDataSource widthForItermAtIndex:_selectIndex];
    self.lineView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 2, width, 2);
    [self addSubview:self.lineView];
}

- (void)p_scrollToIndex:(NSInteger)toIndex{
    //先判断一下是否可以滚动
    if (self.itermArray.count <= toIndex || self.contentSize.width < self.frame.size.width) {
        return;
    }
    
    CXLTarItermView *nextItermView = self.itermArray[toIndex];
    CGFloat tagExceptScreen = [UIScreen mainScreen].bounds.size.width - nextItermView.frame.size.width;
    CGFloat tagPaddingInScreen = tagExceptScreen / 2.0;
    CGFloat offsetX = MAX(0, MIN(nextItermView.frame.origin.x - tagPaddingInScreen, self.itermArray.lastObject.frame.origin.x - tagExceptScreen));
    CGPoint nextPoint = CGPointMake(offsetX, 0);
    
    if (toIndex == self.itermArray.count - 1 && toIndex != 0) {
        nextPoint.x = self.contentSize.width - self.frame.size.width + self.contentInset.right;
    }
    [self setContentOffset:nextPoint animated:YES];
}

- (void)p_lineViewScrollToIndex:(NSInteger)toIndex animated:(BOOL)animated{
    if (toIndex >= self.itermArray.count || toIndex < 0) {
        return;
    }
    
    CXLTarItermView *itermView = self.itermArray[toIndex];
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
          self.lineView.center = CGPointMake(itermView.center.x, self.lineView.center.y);
        }];
    }else{
        CXLTarItermView *itermView = self.itermArray[toIndex];
        self.lineView.center = CGPointMake(itermView.center.x, self.lineView.center.y);
    }
}

#pragma mark - Public Menthod
- (void)lineViewScrollToContentRatio:(CGFloat)contentRatio{
    //ceil如果参数是小数,则求最小的整数但不小于本身. ceil(3.4) = 4;
    int fromIndex = ceil(contentRatio) - 1;
    if (fromIndex < 0 || self.itermArray.count <= fromIndex + 1) {
        return;
    }
    
    CGFloat fromWidth = [self.tabDataSource widthForItermAtIndex:fromIndex];
    CGFloat toWidth = [self.tabDataSource widthForItermAtIndex:fromIndex + 1];
    if (fromWidth != toWidth) {
        CGRect frame = self.lineView.frame;
        CGFloat lineWidth = fromWidth + (toWidth - fromWidth)*(contentRatio - fromIndex);
        self.lineView.frame = CGRectMake(frame.origin.x, frame.origin.y, lineWidth, frame.size.height);
    }
    
    CXLTarItermView *currentIterm = self.itermArray[fromIndex];
    CXLTarItermView *nextIterm = self.itermArray[fromIndex + 1];
    CXLTarItermView *firstIterm = self.itermArray.firstObject;
    CXLTarItermView *lastIterm = self.itermArray.lastObject;
    
    CGFloat moveCenterX = currentIterm.center.x + (contentRatio - fromIndex)*(nextIterm.center.x - currentIterm.center.x);
    if (moveCenterX <= firstIterm.center.x) {
        moveCenterX = firstIterm.center.x;
    }else if (moveCenterX >= lastIterm.center.x){
        moveCenterX = lastIterm.center.x;
    }
    
    self.lineView.center = CGPointMake(moveCenterX, self.lineView.center.y);
}

#pragma mark - Event Response
- (void)clickedTabBar:(UIControl *)sender{
    NSInteger tag = sender.tag;
    if (_selectIndex == tag) return;
    [self.tabDelegate didClickedItermAtIndex:tag];
    
    //iterm是否可以点击
    if ([self.tabDataSource respondsToSelector:@selector(itermCanPressAtIndex:)] && ![self.tabDataSource itermCanPressAtIndex:tag]) {
        return;
    }
    
    //记录当前选中的索引
    _selectIndex = tag;
    
    for (int i = 0; i < self.itermArray.count; i++) {
        CXLTarItermView *iterm = self.itermArray[i];
        iterm.titleLabel.textColor = _selectIndex == i ? _selectColor : _normalColor;
        iterm.titleLabel.font = _selectIndex == i ? _selectFont : _normalFont;
    }
    
    //移动到相应的位置
    [self p_scrollToIndex:_selectIndex];
    [self p_lineViewScrollToIndex:_selectIndex animated:YES];
}

#pragma mark - Setter && Getter
- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
}

- (void)setSelectColor:(UIColor *)selectColor{
    _selectColor = selectColor;
}

- (void)setNormalFont:(UIFont *)normalFont{
    _normalFont = normalFont;
}

- (void)setSelectFont:(UIFont *)selectFont{
    _selectFont = selectFont;
}

- (void)setItermPadding:(CGFloat)itermPadding{
    _itermPadding = itermPadding;
}

#pragma mark - Setter && Getter
- (NSMutableArray *)itermArray{
    if (!_itermArray) {
        _itermArray = [[NSMutableArray alloc]init];
    }
    return _itermArray;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.layer.cornerRadius = 1;
        _lineView.layer.masksToBounds = YES;
    }
    return _lineView;
}

@end
