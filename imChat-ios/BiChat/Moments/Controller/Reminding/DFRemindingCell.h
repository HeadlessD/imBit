//
//  DFRemindingCell.h
//  BiChat Dev
//
//  Created by chat on 2018/9/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFRemindingCell : UITableViewCell

@property (nonatomic,strong) UIImageView * backView;
@property (nonatomic,strong) UIImageView * praiseImg;

@property (nonatomic,strong) UIImageView * iconView;
@property (nonatomic,strong) UILabel * nameBtn;
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,strong) UILabel * contentLabel;
@property (nonatomic,strong) YYLabel * contentYYLabel;

@property (nonatomic,strong) UIImageView * picView;
@property (nonatomic,strong) YYLabel * rightLabel;


+(CGFloat)getCommentHeightWithModel:(DFPushModel *)pushModel;

-(void)updateCommentWithModel:(DFPushModel*)pushModel;

@end
