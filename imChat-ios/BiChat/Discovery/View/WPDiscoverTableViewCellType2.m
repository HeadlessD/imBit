//
//  WPDiscoverTableViewCellType2.m
//  BiChat
//
//  Created by 张迅 on 2018/4/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPDiscoverTableViewCellType2.h"

@implementation WPDiscoverTableViewCellType2

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.idLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.idLabel];
    [self.idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.top.equalTo(self.contentView);
        make.height.equalTo(@10);
    }];
    self.idLabel.font = Font(8);
    self.idLabel.hidden = YES;
    
    self.titleLabel = [YYLabel new];
    self.titleLabel.numberOfLines = 3;
    self.titleLabel.font = Font(16);
    self.titleLabel.preferredMaxLayoutWidth = ScreenWidth - 20;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.top.equalTo(self.contentView).offset(10);
    }];
    
    CGFloat imageWidth = (ScreenWidth - 30) / 3.0;
    CGFloat imageHeight = imageWidth * 10 / 16;
    
    self.timeLabel = [[YYLabel alloc]init];
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.right.equalTo(self.contentView);
        make.height.equalTo(@15);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(imageHeight + 20);
    }];
    self.timeLabel.font = Font(11);
    self.timeLabel.textColor = RGB(0x999999);
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.closeBtn];
    [self.closeBtn setImage:Image(@"disover_close") forState:UIControlStateNormal];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-10);
        make.centerY.equalTo(self.timeLabel);
        make.width.equalTo(@40);
        make.height.equalTo(@30);
    }];
    [self.closeBtn addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
    
    [self.lineV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.bottom.equalTo(self.contentView);
        make.height.equalTo(@0.5);
    }];
    return self;
}
- (void)fillData:(WPDiscoverModel *)model {
    self.idLabel.text = model.newsid;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@  ",model.title]];
    if (model.hasRead) {
        [attStr setAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(0, attStr.string.length)];
        attStr.yy_color = [UIColor grayColor];
    } else {
        attStr.yy_color = [UIColor blackColor];
    }
    attStr.yy_font = Font(16);
//    NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  model.tag  "]];
////    文字颜色和字体
//    tagText.yy_font = Font(10);
//    tagText.yy_color = RGB(0x2fb6fa);
//    边框
//    YYTextBorder *border = [YYTextBorder borderWithFillColor:RGB(0xc0e9fd) cornerRadius:10];
//    border.insets = UIEdgeInsetsMake(0, 0, 0, 0);
//    [tagText yy_setTextBackgroundBorder:border range:NSMakeRange(0, tagText.string.length)];
//    [tagText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:tagText.yy_rangeOfAll];
//    [attStr appendAttributedString:tagText];
    // iOS 生成的时间戳是10位
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, model.title.length)];
    self.titleLabel.attributedText = attStr;
    
    NSTimeInterval interval = [model.ctime doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
    long minute = timeInterval / 60;
    if (minute == 0) {
        minute = 1;
    }
    NSMutableString *timeStr = [NSMutableString string];
    if (minute < 60) {
        [timeStr appendString:model.pubnickname];
        [timeStr appendString:[LLSTR(@"101067") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",minute]]]];
    } else if (minute >= 60 && minute < 60 * 24){
        [timeStr appendString:model.pubnickname];
        [timeStr appendString:[LLSTR(@"101066") llReplaceWithArray:@[[NSString stringWithFormat:@"%ld",minute / 60]]]];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        NSString *dateStr = [formatter stringFromDate:date];
        [timeStr appendString:[NSString stringWithFormat:@"%@ %@",model.pubnickname,dateStr]];
    }
    [timeStr appendString:@"  "];
    [timeStr appendString:[NSString stringWithFormat:@"%.4f",[model.score floatValue]]];
#ifdef ENV_LIVE
    timeStr = [NSMutableString string];
    if (model.pubnickname)
        [timeStr appendString:model.pubnickname];
#endif
#ifdef ENV_CN
    timeStr = [NSMutableString string];
    if (model.pubnickname)
        [timeStr appendString:model.pubnickname];
#endif
#ifdef ENV_ENT
    timeStr = [NSMutableString string];
    if (model.pubnickname)
        [timeStr appendString:model.pubnickname];
#endif
    NSMutableAttributedString *timeAttStr = [[NSMutableAttributedString alloc]initWithString:timeStr];
    [timeAttStr addAttribute:NSFontAttributeName value:Font(12) range:timeAttStr.yy_rangeOfAll];
    [timeAttStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:timeAttStr.yy_rangeOfAll];
    
//    NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" 已关注"]];
////    文字颜色和字体
//    tagText.yy_font = Font(10);
//    tagText.yy_color = RGB(0x2fb6fa);
////    边框
//    YYTextBorder *border = [YYTextBorder borderWithFillColor:RGB(0xc0e9fd) cornerRadius:2];
//    border.insets = UIEdgeInsetsMake(-2, -2, -2, -2);
//    [tagText yy_setTextBackgroundBorder:border range:NSMakeRange(0, tagText.string.length)];
//    [tagText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:tagText.yy_rangeOfAll];
//    [tagText appendAttributedString:timeAttStr];
    self.timeLabel.attributedText = timeAttStr;
    
    for (UIImageView *imageV in self.contentView.subviews) {
        if ([imageV isKindOfClass:[UIImageView class]]) {
            [imageV removeFromSuperview];
        }
    }
    CGFloat imageWidth = (ScreenWidth - 30) / 3.0;
    CGFloat imageHeight = imageWidth * 10 / 16;
    UIImageView *lastIV;
    for (int i = 0; i < model.imgs.count ; i++) {
        UIImageView *imageV = [[UIImageView alloc]init];
        [self.contentView addSubview:imageV];
        [imageV mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (lastIV) {
                make.left.equalTo(lastIV.mas_right).offset(5);
            } else {
                make.left.equalTo(self.contentView).offset(10);
            }
            make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
            make.width.equalTo(@(imageWidth));
            make.height.equalTo(@(imageHeight));
        }];
        [imageV sd_setImageWithURL:[NSURL URLWithString:model.imgs[i]]];
        imageV.layer.masksToBounds = YES;
        imageV.contentMode = UIViewContentModeScaleAspectFill;
        imageV.layer.cornerRadius = 3;
        lastIV = imageV;
    }
    [self.contentView bringSubviewToFront:self.closeBtn];
}
//删除某行
- (void)doClose {
    if (self.CloseBlock) {
        self.CloseBlock(self.index);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
