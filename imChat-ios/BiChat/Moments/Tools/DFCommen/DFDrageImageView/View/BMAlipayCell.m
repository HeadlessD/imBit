//
//  BMAlipayCell.m
//  BMDragCellCollectionViewDemo
//
//  Created by __liangdahong on 2017/7/25.
//  Copyright © 2017年 https://liangdahong.com All rights reserved.
//

#import "BMAlipayCell.h"

@interface BMAlipayCell ()

//@property (weak, nonatomic) IBOutlet UIView *myBackgroundView;
//@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;



@end


@implementation BMAlipayCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.myBackgroundView.layer.cornerRadius = 10;
//    self.myBackgroundView.layer.masksToBounds = YES;
}

- (void)setSendImage:(UIImage *)sendImage{
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
//    self.iconImageView.backgroundColor = [UIColor redColor];
    self.iconImageView.clipsToBounds = YES;
    [self.iconImageView setImage:sendImage];
}

//- (void)setImageStr:(NSString *)imageStr{
//    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
//    self.iconImageView.clipsToBounds = YES;
////    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:imageStr]]];
//    [self.iconImageView yy_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:imageStr]] placeholder:[UIImage imageNamed:@"default_image"]];
//
//}

//- (void)setModel:(BMAlipayModel *)model {
//    if (model == _model) {
//        return;
//    }
//    _model = model;
//    self.nameLabel.text = model.title;
//    self.iconImageView.image = [UIImage imageNamed:model.iconName];
//}

@end
