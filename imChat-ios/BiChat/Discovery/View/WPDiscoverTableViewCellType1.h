//
//  WPDiscoverTableViewCellType1.h
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYText.h>
#import "WPDiscoverModel.h"
#import "WPBaseTableViewCell.h"

@interface WPDiscoverTableViewCellType1 : WPBaseTableViewCell

@property (nonatomic,strong)YYLabel *titleLabel;
@property (nonatomic,strong)YYLabel *timeLabel;
@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UIButton *closeBtn;
@property (nonatomic,assign)NSInteger index;
@property (nonatomic,strong)WPDiscoverModel *currentModel;

@property (nonatomic,strong)UILabel *idLabel;

@property (nonatomic)void (^CloseBlock)(NSInteger index);

- (void)fillData:(WPDiscoverModel *)model;


@end
