//
//  WPRedPacketSendCoinSelectView.h
//  BiChat
//
//  Created by 张迅 on 2018/5/7.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPRedPacketSendCoinModel.h"

@interface WPRedPacketSendCoinSelectView : UIView <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,copy)void (^SelectBlock)(WPRedPacketSendCoinModel *model);
@property (nonatomic,strong)NSArray *coinArray;
@property (nonatomic,strong)UITableView *coinTV;

//赋数据
- (void)fillCoin:(NSArray *)coinArray;

@end
