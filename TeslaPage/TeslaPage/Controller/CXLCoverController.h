//
//  CXLCoverController.h
//  TeslaPage
//
//  Created by 曹学亮 on 2018/2/3.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import "CXLTabBarController.h"
#import "CXLCoverProtocol.h"

@interface CXLCoverController : CXLTabBarController
<CXLCoverControllerDataSource,CXLPageControllerDelegate,CXLPageControllerDataSource>

@end
