//
//  WPDiscoverTableViewCellType5.h
//  BiChat
//
//  Created by iMac on 2018/8/1.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import "WPDiscoverModel.h"

@interface WPDiscoverTableViewCellType5 : WPBaseTableViewCell

@property (nonatomic,strong)UIImageView *imageV;
@property (nonatomic,strong)UILabel *adLabel;
@property (nonatomic,strong)UIButton *closeBtn;
@property (nonatomic)void (^CloseBlock)(NSInteger index);
@property (nonatomic,assign)NSInteger index;

@property (nonatomic,strong)UIActivityIndicatorView *actView;

- (void)fillData:(WPDiscoverModel *)model;

@end
