//
//  WPAccreditManagementTableViewCell.h
//  BiChat
//
//  Created by iMac on 2018/12/25.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPAccreditManagementTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *desLabel;

- (void)fillData:(NSDictionary *)dict;

@property (nonatomic,assign) BOOL hasAdd;

@end

NS_ASSUME_NONNULL_END
