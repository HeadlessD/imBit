//
//  WPRedPacketSetTableViewCell.m
//  BiChat Dev
//
//  Created by iMac on 2018/10/29.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPRedPacketSetTableViewCell.h"

@implementation WPRedPacketSetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.font = Font(16);
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-100);
    }];
    
    self.mySwitch = [[UISwitch alloc]init];
    [self.contentView addSubview:self.mySwitch];
    [self.mySwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.centerY.equalTo(self.contentView);
    }];
    [self.mySwitch addTarget:self action:@selector(doSwitch) forControlEvents:UIControlEventValueChanged];
    
    return self;
}

- (void)doSwitch {
    if (self.SwitchBlock) {
        self.SwitchBlock(self.mySwitch.on);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
