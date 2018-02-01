//
//  CXLMainController.m
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLMainController.h"
#import "CXLTarBar.h"

@interface CXLMainController ()<CXLTarBarDelegate>
@property (nonatomic,strong) CXLTarBar *tarBar;
@property (nonatomic,strong) NSArray *itermArray;
@end

@implementation CXLMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"首页";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.tarBar];
}

#pragma mark - CXLTarBarDelegate
- (void)didClickItermAtIndex:(NSInteger)index{
    NSLog(@"@----%ld---",index);
}

#pragma mark - Setter && Getter
- (CXLTarBar *)tarBar{
    if (!_tarBar) {
        _tarBar = [[CXLTarBar alloc]initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.bounds), 50) titleArray:@[@"第一个",@"第二二个",@"第三个",@"第四四个",@"第五五五个",@"第六六六个",@"第七七七凄凄切切个",@"第巴巴爸爸吧奥奥奥不不不个"]];
        _tarBar.tabDelegate = self;
        _tarBar.backgroundColor = [UIColor whiteColor];
        _tarBar.normalFont = [UIFont systemFontOfSize:15];
        _tarBar.selectFont = [UIFont systemFontOfSize:15];
        _tarBar.normalColor = [UIColor blackColor];
        _tarBar.selectColor = [UIColor orangeColor];
        _tarBar.itermPadding = 20;
    }
    return _tarBar;
}

@end
