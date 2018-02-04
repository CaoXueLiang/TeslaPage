//
//  CXLCoverProtocol.h
//  TeslaPage
//
//  Created by 曹学亮 on 2018/2/2.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CXLCoverControllerDataSource <NSObject>
/** 返回CoverView视图 */
- (UIView *)preferCoverView;

/** 返回CoverView的frame */
- (CGRect)preferCoverFrame;

@end
