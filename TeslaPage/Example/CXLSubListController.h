//
//  CXLSubListController.h
//  TeslaPage
//
//  Created by 曹学亮 on 2018/2/4.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXLPageProtocols.h"

@interface CXLSubListController : UIViewController<CXLSubPageControllerDataSource>
@property (nonatomic,assign) NSInteger currentIndex;
@end
