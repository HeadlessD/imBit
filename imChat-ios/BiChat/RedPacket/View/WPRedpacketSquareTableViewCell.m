//
//  WPRedpacketSquareTableViewCell.m
//  BiChat
//
//  Created by iMac on 2018/8/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPRedpacketSquareTableViewCell.h"

@implementation WPRedpacketSquareTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    
    self.backView = [[UIView alloc]init];
    [self.contentView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.bottom.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(@280);
    }];
    self.backView.layer.cornerRadius = 5;
    self.backView.layer.masksToBounds = YES;
    
    self.coinIV = [[UIImageView alloc]init];
    [self.backView addSubview:self.coinIV];
    [self.coinIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@36);
        make.left.equalTo(self.backView).offset(15);
        make.centerY.equalTo(self.backView).offset(-10);
    }];
    
    self.coinTypeLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.coinTypeLabel];
    [self.coinTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coinIV).offset(-5);
        make.right.equalTo(self.coinIV).offset(5);
        make.top.equalTo(self.coinIV.mas_bottom).offset(-2);
        make.height.equalTo(@18);
    }];
    self.coinTypeLabel.textAlignment = NSTextAlignmentCenter;
    self.coinTypeLabel.textColor = [UIColor whiteColor];
    self.coinTypeLabel.font = Font(9);
    
    self.sharedIV = [[UIImageView alloc]init];
    [self.backView addSubview:self.sharedIV];
    [self.sharedIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@38);
        make.right.top.equalTo(self.backView);
    }];
    self.sharedIV.image = Image(@"redPacket_shared");
    self.sharedIV.hidden = YES;
    
    self.titleLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coinIV.mas_right).offset(10);
        make.height.equalTo(@20);
        make.right.equalTo(self.backView).offset(-10);
        make.bottom.equalTo(self.coinIV.mas_centerY).offset(-1);
    }];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = Font(16);
    
    self.contentTV = [[UITextView alloc]init];
    [self.backView addSubview:self.contentTV];
    [self.contentTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.height.equalTo(@20);
        make.top.equalTo(self.coinIV.mas_centerY).offset(3);
    }];
    self.contentTV.textColor = [UIColor whiteColor];
    self.contentTV.font = Font(12);
    self.contentTV.editable = NO;
    self.contentTV.userInteractionEnabled = NO;
    self.contentTV.textContainerInset = UIEdgeInsetsZero;
    self.contentTV.textContainer.lineFragmentPadding = 0;
    self.contentTV.backgroundColor = [UIColor clearColor];
    
    UIView *bottomV = [[UIView alloc]init];
    [self.backView addSubview:bottomV];
    [bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
    }];
    bottomV.backgroundColor = [UIColor whiteColor];
    
    self.timeLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView).offset(-10);
        make.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
        make.left.equalTo(self.backView).offset(10);
    }];
    self.timeLabel.font = Font(12);
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    self.coinLabel = [[UILabel alloc]init];
    [self.backView addSubview:self.coinLabel];
    [self.coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.timeLabel.mas_left).offset(-10);
        make.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
        make.left.equalTo(self.backView).offset(10);;
    }];
    self.coinLabel.textColor = [UIColor grayColor];
    self.coinLabel.font = Font(12);
    self.coinLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    return self;
}

- (void)fillData:(WPRedPacketModel *)model isPersonal:(BOOL)personal isPush:(BOOL)push isShare:(BOOL)share{
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coinIV.mas_right).offset(10);
        make.right.equalTo(self.backView).offset(-10);
        make.top.equalTo(self.backView);
        make.bottom.equalTo(self.backView).offset(-20);
    }];
    self.titleLabel.numberOfLines = 3;
    self.contentTV.hidden = YES;
    //设置标题
    self.titleLabel.text = model.rewardName;
    [self.coinIV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].StaticUrl,model.imgWhite]]];
    //红包过期时间到了刷新列表
    NSTimeInterval a = [[BiChatGlobal getCurrentDate] timeIntervalSince1970];
    long long timeInterval = model.expiredTime / 1000.0 - a;
    if (timeInterval < 0) {
        timeInterval = 0;
        if (self.RefreshBlock) {
            self.RefreshBlock();
        }
    }
    //设置来源
    if (model.groupName) {
        self.coinLabel.text = [NSString stringWithFormat:@"「%@」",model.groupName];
    } else {
        self.coinLabel.text = [NSString stringWithFormat:@"「%@」",model.nickName];
    }
    if (model.isPublic) {
        self.coinLabel.text = [NSString stringWithFormat:@"「%@」",model.groupName];
    }
    self.contentTV.text = LLSTR(@"101427");
    self.backView.backgroundColor = RGB(0xf56547);
    if (model.groupName) {
        self.coinLabel.text = [NSString stringWithFormat:@"「%@」",model.groupName];
    } else {
        self.coinLabel.text = [NSString stringWithFormat:@"「%@」",model.nickName];
    }
    if (model.isPublic) {
        self.coinLabel.text = [NSString stringWithFormat:@"「%@」",model.groupName];
    }
    self.coinTypeLabel.text = [[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType];
    self.timeLabel.font = Font(12);
    NSTimeInterval interval = model.expiredTime / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    //已领
    if ([model.status isEqualToString:@"3"] || model.hasReceived) {
        self.timeLabel.text = LLSTR(@"101419");
        self.backView.backgroundColor = RGB(0xfab2a3);
    }
    //已抢待领
    else if (([model.status isEqualToString:@"2"] && ![model.rewardStatus isEqualToString:@"4"]) || model.hasOccupied) {
        self.timeLabel.text = LLSTR(@"101420");
        self.backView.backgroundColor = RGB(0xfab2a3);
    }
    //已过期
    else if ([date compare:[BiChatGlobal getCurrentDate]] == NSOrderedAscending || [model.rewardStatus isEqualToString:@"4"] || model.hasExpired) {
        self.timeLabel.text = LLSTR(@"101421");
        self.backView.backgroundColor = RGB(0xfab2a3);
    }
    //已抢完
    else if ([model.leftValue floatValue] == 0 || [model.rewardStatus isEqualToString:@"2"] || [model.rewardStatus isEqualToString:@"3"] || model.hasFinished) {
        self.timeLabel.text = LLSTR(@"101422");
        self.backView.backgroundColor = RGB(0xfab2a3);
    }
    //红包还未开始、已达活动预算上限 不可抢
    else if ((model.showDisable && ![model.status isEqualToString:@"2"]) || [model.rewardStatus isEqualToString:@"5"] || [model.rewardStatus isEqualToString:@"6"]) {
        self.timeLabel.text = LLSTR(@"101423");
        self.backView.backgroundColor = RGB(0xfab2a3);
    }
    //正常红包
    else {
        self.timeLabel.text = nil;
    }
    CGRect rect = [self.timeLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.timeLabel.font} context:nil];
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.backView).offset(-10);
        make.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
        make.width.equalTo(@(rect.size.width + 5));
    }];
    [self.coinLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.timeLabel.mas_left).offset(-10);
        make.bottom.equalTo(self.backView);
        make.height.equalTo(@20);
        make.left.equalTo(self.backView).offset(3);;
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
