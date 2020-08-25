//
//  WPDiscoverTableViewCellType4.m
//  BiChat
//
//  Created by iMac on 2018/7/24.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPDiscoverTableViewCellType4.h"

@implementation WPDiscoverTableViewCellType4

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.contentView addSubview:self.titleLabel];
    
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.numberOfLines = 0;
    self.descLabel.font = Font(14);
    self.descLabel.textColor = [UIColor grayColor];
    self.descLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:self.descLabel];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.numberOfLines = 0;
    self.timeLabel.font = Font(14);
    self.timeLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.right.equalTo(self.contentView).offset(-20);
        make.top.equalTo(self.contentView).offset(5);
        make.height.equalTo(@20);
    }];
    
    UIView *lineV = [[UIView alloc]init];
    [self.contentView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.width.equalTo(@0.5);
        make.top.bottom.equalTo(self.contentView);
    }];
    lineV.backgroundColor = THEME_GRAY;
    
    UIView *circleV = [[UIView alloc]init];
    [self.contentView addSubview:circleV];
    [circleV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@10);
        make.centerX.equalTo(lineV);
        make.centerY.equalTo(self.timeLabel);
    }];
    circleV.backgroundColor = LightBlue;
    circleV.layer.cornerRadius = 5;
    circleV.layer.masksToBounds = YES;
    
    self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.shareBtn];
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-12);
        make.width.equalTo(@50);
        make.top.equalTo(self.descLabel.mas_bottom);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.contentView);
    }];
    [self.shareBtn addTarget:self action:@selector(shareBlock) forControlEvents:UIControlEventTouchUpInside];
    [self.shareBtn setImage:Image(@"discover_share") forState:UIControlStateNormal];
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)fillData:(WPDiscoverModel *)model {
    self.model = model;
    NSTimeInterval interval = [model.ctime doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *dateStr = [formatter stringFromDate:date];
    self.timeLabel.text = dateStr;
    
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    CGRect titleRect = [model.title boundingRectWithSize:CGSizeMake(ScreenWidth - 50, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font,NSParagraphStyleAttributeName : style} context:nil];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.top.equalTo(self.timeLabel.mas_bottom);
        make.right.equalTo(self.contentView).offset(-20);
        make.height.equalTo(@(titleRect.size.height + 5));
    }];
    self.titleLabel.text = model.title;
    CGRect descRect = [model.content boundingRectWithSize:CGSizeMake(ScreenWidth - 50, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(14)} context:nil];
    [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.right.equalTo(self.contentView).offset(-20);
        make.height.equalTo(@(descRect.size.height + 5));
    }];
    self.descLabel.text = model.content;
}

- (void)shareBlock {
    if (self.ShareBlock) {
        self.ShareBlock(self.model);
    }
}

@end
