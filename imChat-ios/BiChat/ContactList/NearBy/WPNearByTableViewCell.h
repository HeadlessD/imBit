//
//  WPNearByTableViewCell.h
//  BiChat
//
//  Created by iMac on 2018/11/5.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"
#import "WPNearbyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPNearByTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UIImageView *genderIV;
@property (nonatomic,strong)UILabel *tagLabel ;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *desLabel;
@property (nonatomic,strong)UILabel *distanceLabel;


- (void)fillData:(WPNearbyModel *)model;

@end

NS_ASSUME_NONNULL_END
