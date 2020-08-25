//
//  WPPublicSearchResultTableViewCell.h
//  BiChat
//
//  Created by 张迅 on 2018/4/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import "WPPublicSearchResultModel.h"

@interface WPPublicSearchResultTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *contentLabel;
@property (nonatomic,strong)UIImageView *followIV;

- (void)fillData:(WPPublicSearchResultModel *)model;

@end
