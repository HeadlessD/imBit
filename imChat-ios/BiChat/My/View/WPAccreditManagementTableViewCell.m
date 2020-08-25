//
//  WPAccreditManagementTableViewCell.m
//  BiChat
//
//  Created by iMac on 2018/12/25.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import "WPAccreditManagementTableViewCell.h"

@implementation WPAccreditManagementTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.headIV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.headIV];
    [self.headIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.top.equalTo(self.contentView).offset(10);
        make.width.height.equalTo(@40);
    }];
    self.headIV.layer.cornerRadius = 20;
    self.headIV.layer.masksToBounds = YES;
    
    self.titleLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.equalTo(@20);
        make.bottom.equalTo(self.headIV.mas_centerY);
    }];
    self.titleLabel.font = Font(14);
    
    self.desLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.desLabel];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.equalTo(@40);
        make.top.equalTo(self.headIV.mas_centerY);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    self.desLabel.font = Font(12);
    self.desLabel.textColor = THEME_GRAY;
    self.desLabel.numberOfLines = 0;
    return self;
}

- (void)fillData:(NSDictionary *)dict {
    [self.headIV setImageWithURL:[NSString stringWithFormat:@"%@%@",[BiChatGlobal sharedManager].S3URL,[dict objectForKey:@"avatar"]] title:[dict objectForKey:@"groupName"] size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    self.titleLabel.text = [dict objectForKey:@"groupName"];
    NSMutableString *str = [NSMutableString string];
//    NSString *scope = [dict objectForKey:@"scope"];
//    [str appendString:LLSTR(@"106132")];
//    [str appendString:@"\n"];
    NSArray *array = [dict objectForKey:@"authItemText"];
    NSDictionary *authItemText = [dict objectForKey:@"langs"];
    for (NSString *string in array) {
        
//        if (self.hasAdd) {
//            [str appendString:@"，"];
//        }
        [str appendString:@"·"];
//        tipString = [DFLanguageManager getStrWithDic:[self.contentDic objectForKey:@"langs"] llstr:[self.contentDic objectForKey:@"promptText"]];
        NSString *appString = [DFLanguageManager getStrWithDic:authItemText llstr:string];
        [str appendString:appString];
        [str appendString:@"\n"];
//        self.hasAdd = YES;
    }
    
    NSString *resultStr = [str substringWithRange:NSMakeRange(0, str.length - 1)];
    
    
    
    
    
//    if ([scope containsString:@"snsapi_userinfo"]) {
//        [str appendString:LLSTR(@"102224")];
//        self.hasAdd = YES;
//    }
//    if ([scope containsString:@"snsapi_mobile"]) {
//        if (self.hasAdd) {
//            [str appendString:@"，"];
//        }
//        [str appendString:LLSTR(@"106103")];
//        self.hasAdd = YES;
//    }
//    if ([scope containsString:@"snsapi_location"]) {
//        if (self.hasAdd) {
//            [str appendString:@"，"];
//        }
//        [str appendString:LLSTR(@"102228")];
//    }
//
//    if ([scope containsString:@"snsapi_webIM"]) {
//        [str appendString:LLSTR([dict objectForKey:@""])];
//    }
    self.desLabel.text = resultStr;
    CGRect rect = [resultStr boundingRectWithSize:CGSizeMake(ScreenWidth - 70, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : Font(12)} context:nil];
    [self.desLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headIV.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.equalTo(@(rect.size.height + 10));
        make.top.equalTo(self.headIV.mas_centerY);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
