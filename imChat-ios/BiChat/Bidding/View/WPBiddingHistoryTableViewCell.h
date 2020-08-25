//
//  WPBiddingHistoryTableViewCell.h
//  BiChat
//
//  Created by iMac on 2019/3/20.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPBiddingActivityDetailModel.h"


@interface WPBiddingHistoryTableViewCell : UITableViewCell

@property (nonatomic,strong)UIView *backView;
@property (nonatomic,strong)UIView *lineView;
@property (nonatomic,strong)UILabel *dateLabel;
@property (nonatomic,strong)UILabel *rulelabel;
@property (nonatomic,strong)UILabel *label1;
@property (nonatomic,strong)UILabel *label2;
@property (nonatomic,strong)UILabel *label3;
@property (nonatomic,strong)UILabel *label4;
@property (nonatomic,strong)UILabel *label5;

- (void)fillData:(WPBiddingActivityDetailModel *)model;

@end
