//
//  DFMoreCell.m
//  BiChat Dev
//
//  Created by chat on 2018/9/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "DFMoreCell.h"

@implementation DFMoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    return self;
}

-(void)createView{
    [self.contentView addSubview:self.lineLeft];
//    [self.contentView addSubview:self.midLabel];
//    [self.contentView addSubview:self.lineRight];
    [self makeConstraints];
}

-(void)makeConstraints{
//    _lineLeft.text = @"———————————————  •  ———————————————";

    [_lineLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.left.right.mas_equalTo(self.contentView);

//        make.left.mas_equalTo(25);
//        make.width.mas_equalTo(80);
    }];
    
//    [_midLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.mas_equalTo(self.contentView);
//        make.left.mas_equalTo(_lineLeft.mas_right).offset(10);
//        make.right.mas_equalTo(_lineRight.mas_left).offset(-10);
//    }];
//
//    [_lineRight mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.mas_equalTo(self.contentView);
//        make.right.mas_equalTo(-25);
//        make.width.mas_equalTo(80);
//    }];
}

-(UILabel *)lineLeft{
    if (!_lineLeft) {
        _lineLeft =
        _lineLeft = [[UILabel alloc]init];
        _lineLeft.backgroundColor = [UIColor whiteColor];
        _lineLeft.text = LLSTR(@"104007");
        _lineLeft.font = [UIFont systemFontOfSize:15];
        _lineLeft.numberOfLines = 1;
        _lineLeft.lineBreakMode = NSLineBreakByCharWrapping;    //以字符为显示单位显示，后面部分省略不显示。
        _lineLeft.textAlignment = NSTextAlignmentCenter;
        _lineLeft.textColor = [UIColor lightGrayColor];
    }
    return _lineLeft;
}
-(UILabel *)lineRight{
    if (!_lineRight) {
        _lineRight =
        _lineRight = [[UILabel alloc]init];
        _lineRight.backgroundColor = [UIColor whiteColor];
        _lineRight.text = @"—————————";
        _lineRight.font = [UIFont systemFontOfSize:10];
        _lineRight.numberOfLines = 1;
        _lineRight.lineBreakMode = NSLineBreakByCharWrapping;    //以字符为显示单位显示，后面部分省略不显示。
        _lineRight.textAlignment = NSTextAlignmentCenter;
        _lineRight.textColor = [UIColor lightGrayColor];
    }
    return _lineRight;
}

-(UILabel *)midLabel{
    if (!_midLabel) {
        _midLabel =
        _midLabel = [[UILabel alloc]init];
        _midLabel.backgroundColor = [UIColor whiteColor];
        _midLabel.text = LLSTR(@"104007");
        _midLabel.font = [UIFont systemFontOfSize:14];
        _midLabel.numberOfLines = 1;
        _midLabel.textAlignment = NSTextAlignmentCenter;
        _midLabel.textColor = [UIColor lightGrayColor];
    }
    return _midLabel;
}






- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
