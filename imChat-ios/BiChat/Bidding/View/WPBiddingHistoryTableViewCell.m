//
//  WPBiddingHistoryTableViewCell.m
//  BiChat
//
//  Created by iMac on 2019/3/20.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "WPBiddingHistoryTableViewCell.h"

@implementation WPBiddingHistoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.backView = [[UIView alloc]init];
    [self.contentView addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView);
    }];
    self.backView.backgroundColor = [UIColor whiteColor];
    
    self.dateLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(10);
        make.right.equalTo(self.backView.mas_centerX);
        make.top.equalTo(self.backView);
        make.height.equalTo(@30);
    }];
    self.dateLabel.font = Font(14);
    
    self.rulelabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.rulelabel];
    [self.rulelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView.mas_centerX);
        make.right.equalTo(self.backView).offset(-10);
        make.top.equalTo(self.backView);
        make.height.equalTo(@30);
    }];
    self.rulelabel.font = Font(14);
    self.rulelabel.textAlignment = NSTextAlignmentRight;
    
    self.lineView = [[UIView alloc]init];
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(10);
        make.right.equalTo(self.backView).offset(-10);
        make.top.equalTo(self.backView).offset(30);
        make.height.equalTo(@0.5);
    }];
    self.lineView.backgroundColor = DFLightLineColor;
    
    self.label1 = [[UILabel alloc]init];
    [self.contentView addSubview:self.label1];
    [self.label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(10);
        make.right.equalTo(self.backView).offset(-10);
        make.top.equalTo(self.dateLabel.mas_bottom);
        make.height.equalTo(@25);
    }];
    self.label1.font = Font(14);
    self.label1.textColor = [UIColor grayColor];
    
    self.label2 = [[UILabel alloc]init];
    [self.contentView addSubview:self.label2];
    [self.label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(10);
        make.right.equalTo(self.backView).offset(-10);
        make.top.equalTo(self.label1.mas_bottom);
        make.height.equalTo(@20);
    }];
    self.label2.font = Font(14);
    self.label2.textColor = [UIColor grayColor];
    
    self.label3 = [[UILabel alloc]init];
    [self.contentView addSubview:self.label3];
    [self.label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(10);
        make.right.equalTo(self.backView).offset(-10);
        make.top.equalTo(self.label2.mas_bottom);
        make.height.equalTo(@20);
    }];
    self.label3.font = Font(14);
    self.label3.textColor = [UIColor grayColor];
    
    self.label4 = [[UILabel alloc]init];
    [self.contentView addSubview:self.label4];
    [self.label4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(10);
        make.right.equalTo(self.backView).offset(-10);
        make.top.equalTo(self.label3.mas_bottom);
        make.height.equalTo(@20);
    }];
    self.label4.font = Font(14);
    self.label4.textColor = [UIColor grayColor];
    
    self.label5 = [[UILabel alloc]init];
    [self.contentView addSubview:self.label5];
    [self.label5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView).offset(10);
        make.right.equalTo(self.backView).offset(-10);
        make.top.equalTo(self.label4.mas_bottom);
        make.height.equalTo(@20);
    }];
    self.label5.font = Font(14);
    self.label5.textColor = [UIColor grayColor];
    
    
    return self;
}

- (void)fillData:(WPBiddingActivityDetailModel *)model {
    //imc     4
    NSString *bit1 = [NSString stringWithFormat:@"%d",[[[[BiChatGlobal sharedManager] getCoinInfoBySymbol:model.coinType] objectForKey:@"bit"] intValue]];
    //force   2
    NSString *bit2 = [NSString stringWithFormat:@"%d",[[[[BiChatGlobal sharedManager] getCoinInfoBySymbol:model.castCoinType] objectForKey:@"bit"] intValue]];
    self.dateLabel.text = [model.resultTime getTimeWithTimestamp:@"yyyy/MM/dd HH:mm"];
    self.rulelabel.text = LLSTR(@"108018");
//    [NSString stringWithFormat:@"%@ %@\n%@",model.volume,[coinInfo objectForKey:@"dSymbol"],[LLSTR(@"101858") llReplaceWithArray:@[model.amount]]];
    NSMutableString *string1 = [NSMutableString string];
    [string1 appendString:[[NSString stringWithFormat:@"%@",model.userVolume] accuracyCheckWithFormatterString:bit1 auotCheck:YES]];
    [string1 appendString:@" "];
    [string1 appendString:[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.coinType]];
    [string1 appendString:@" "];
    [string1 appendString:[LLSTR(@"108008") llReplaceWithArray:@[model.amount]]];
    self.label1.text = string1;
//    [NSString stringWithFormat:@"%@ %@\n%@",[NSString stringWithFormat:@"%@",model.totalAmount],[coinInfo objectForKey:@"dSymbol"],[LLSTR(@"101859") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",model.userCount]]]];
    NSMutableString *string2 = [NSMutableString string];
    [string2 appendString:[model.totalAmount accuracyCheckWithFormatterString:bit2 auotCheck:NO]];
    [string2 appendString:@" "];
    [string2 appendString:[[BiChatGlobal sharedManager] getCoinDSymbolBySymbol:model.castCoinType]];
    [string2 appendString:[LLSTR(@"108009") llReplaceWithArray:@[model.userCount,model.orderCount]]];
    self.label2.text = string2;
    
    self.label3.text = [LLSTR(@"108031") llReplaceWithArray:@[[[NSString stringWithFormat:@"%@",model.bidPrice] accuracyCheckWithFormatterString:bit2 auotCheck:NO]]];
    self.label4.text = [LLSTR(@"108032") llReplaceWithArray:@[model.allotVolumeStr,[NSString stringWithFormat:@"%@",model.winningAmount]]];
    self.label5.text = [LLSTR(@"108033") llReplaceWithArray:@[[NSString stringWithFormat:@"%@",model.confirmUser] ,[NSString stringWithFormat:@"%@",model.confirmCount],[NSString stringWithFormat:@"%@",model.winningUser],[NSString stringWithFormat:@"%@",model.winningOrder]]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
