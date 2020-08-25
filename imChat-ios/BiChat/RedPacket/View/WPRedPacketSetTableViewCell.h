//
//  WPRedPacketSetTableViewCell.h
//  BiChat Dev
//
//  Created by iMac on 2018/10/29.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPRedPacketSetTableViewCell : WPBaseTableViewCell

@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UISwitch *mySwitch;

@property (nonatomic,copy)void (^SwitchBlock)(BOOL value);

@end

NS_ASSUME_NONNULL_END
