//
//  WPDiscoverTableViewCellType5.m
//  BiChat
//
//  Created by iMac on 2018/8/1.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import "WPDiscoverTableViewCellType5.h"

@implementation WPDiscoverTableViewCellType5

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.imageV = [[UIImageView alloc]init];
    [self.contentView addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
        make.height.equalTo(@((ScreenWidth - 20) / 3));
        
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-30);
    }];
    self.imageV.contentMode = UIViewContentModeScaleAspectFill;
    self.imageV.layer.masksToBounds = YES;
    
    self.adLabel = [[UILabel alloc]init];
    [self.contentView addSubview:self.adLabel];
    [self.adLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.bottom.equalTo(self.contentView).offset(-8);
        make.width.equalTo(@35);
        make.height.equalTo(@18);
    }];
    self.adLabel.textAlignment = NSTextAlignmentCenter;
    self.adLabel.text = LLSTR(@"101310");
    self.adLabel.textColor = [UIColor whiteColor];
    self.adLabel.font = Font(10);
    self.adLabel.backgroundColor = LightBlue;
    self.adLabel.layer.cornerRadius = 3;
    self.adLabel.layer.masksToBounds = YES;
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.closeBtn];
    [self.closeBtn setImage:Image(@"disover_close") forState:UIControlStateNormal];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-10);
        make.bottom.equalTo(self.contentView);
        make.width.equalTo(@40);
        make.top.equalTo(self.imageV.mas_bottom);
    }];
    [self.closeBtn addTarget:self action:@selector(doClose) forControlEvents:UIControlEventTouchUpInside];
    
    self.actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.imageV addSubview:self.actView];
    [self.actView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.imageV);
        make.width.height.equalTo(@30);
    }];
    
    return self;
}

- (void)fillData:(WPDiscoverModel *)model {
    [self.actView startAnimating];
    self.actView.hidden = NO;
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:model.imgs[0]] placeholderImage:[UIImage imageWithColor:RGB(0xdddddd) size:CGSizeMake(1, 1)] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self.actView stopAnimating];
        self.actView.hidden = YES;
    }];
}

//删除某行
- (void)doClose {
    if (self.CloseBlock) {
        self.CloseBlock(self.index);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
