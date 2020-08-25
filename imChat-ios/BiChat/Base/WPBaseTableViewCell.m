//
//  WPBaseTableViewCell.m
//  BiChat
//
//  Created by 张迅 on 2018/4/10.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPBaseTableViewCell.h"

@implementation WPBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.lineV = [[UIView alloc]init];
    [self.contentView addSubview:self.lineV];
    [self.lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@0.5);
    }];
    self.lineV.backgroundColor = RGB(0xeeeeee);
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
