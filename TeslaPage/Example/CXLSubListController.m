//
//  CXLSubListController.m
//  TeslaPage
//
//  Created by 曹学亮 on 2018/2/4.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLSubListController.h"
#import "CXLMainController.h"

@interface CXLSubListController ()
<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation CXLSubListController
#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = (0x1<<6) - 1;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"------viewWillAppear 索引:%ld----",self.currentIndex);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"------viewDidAppear 索引:%ld----",self.currentIndex);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"------viewWillDisappear 索引:%ld----",self.currentIndex);
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"------viewDidDisappear 索引:%ld----",self.currentIndex);
}

#pragma mark - UITableView M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static  NSString *cellId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CXLMainController *controller = [[CXLMainController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
    self.navigationController.navigationItem.title = [NSString stringWithFormat:@"索引%ld",indexPath.row];
}

#pragma mark - CXLSubPageControllerDataSource
-(UIScrollView *)preferScrollView{
    return self.tableView;
}

@end
