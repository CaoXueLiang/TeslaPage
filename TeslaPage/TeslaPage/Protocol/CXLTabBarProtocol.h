//
//  CXLTabBarProtocol.h
//  TeslaPage
//
//  Created by bjovov on 2018/2/1.
//  Copyright © 2018年 caoxueliang.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CXLTarBarDataSource <NSObject>
@required
/** iterm的个数 */
- (NSInteger)numberOfIterms;

/** 对应索引下的标题 */
- (NSString *)titleForItermAtIndex:(NSInteger)index;

@optional
/** iterm的宽度 */
- (CGFloat)widthForItermAtIndex:(NSInteger)index;

/** iterm是否可以点击 */
- (BOOL)itermCanPressAtIndex:(NSInteger)index;
@end




@protocol CXLTarBarDelegate <NSObject>
@optional
/** 点击相应的Iterm */
- (void)didClickedItermAtIndex:(NSInteger)index;
@end

