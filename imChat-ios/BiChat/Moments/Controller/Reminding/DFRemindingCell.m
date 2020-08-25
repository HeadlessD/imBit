//
//  DFRemindingCell.m
//  BiChat Dev
//
//  Created by chat on 2018/9/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#define iconW  40
#define bianjie10  10
#define youbian  60



#import "DFRemindingCell.h"

@interface DFRemindingCell ()

@property (nonatomic,strong) UITapGestureRecognizer  * pushTap;
@property (nonatomic,strong) UILabel * deleLabel;
@property (nonatomic, strong) UIImageView * playView;

@end

@implementation DFRemindingCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    return self;
}

-(void)createView
{
    self.contentView.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.iconView];
    [self.backView addSubview:self.nameBtn];
    [self.backView addSubview:self.picView];
    [self.backView addSubview:self.rightLabel];
    
    [self.backView addSubview:self.timeLabel];
    //    [self.backView addSubview:self.contentLabel];
    [self.backView addSubview:self.contentYYLabel];
    [self.backView addSubview:self.praiseImg];
    
    [self.contentView addSubview:self.deleLabel];
    
    [self makeConstraints];
}

-(UILabel *)deleLabel{
    if (!_deleLabel) {
        _deleLabel = [[UILabel alloc]init];
        _deleLabel.backgroundColor = RGB(0xf3f3f5);
        //    deleLabel.backgroundColor = [UIColor blueColor];
        _deleLabel.text = @"该评论已被删除";
        _deleLabel.font = DFFont_Comment_14;
//        _deleLabel.frame = CGRectMake(_contentYYLabel.mj_x+10, _contentYYLabel.mj_y+5, 110, 20);
        //    deleLabel.hidden = YES;
    }
    return _deleLabel;
}

-(void)pushToUserTimeLine{
        //    NSLog(@"pushToUserTimeLine");
}

+(CGFloat)getCommentHeightWithModel:(DFPushModel *)pushModel
{

    if (pushModel.isDeletedRemindComment) {
        return 50+iconW/2;
    }
    
//    [self.contentView layoutIfNeeded];
    if (pushModel.dfContent.type == MOMENT_TYPE_COMMENTREDPOINT) {
        if (pushModel.dfContent.comment.content) {
            if (!pushModel.pushModelCellHeight) {
                NSMutableAttributedString * introText = [pushModel.dfContent.comment.content YYTransEmotionWithFont:DFFont_Comment_14];
                introText.yy_lineSpacing = 4;
                introText.yy_font = DFFont_Comment_14;
                
                YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(ScreenWidth - (bianjie10+bianjie10 + iconW + 5 +youbian), CGFLOAT_MAX) text:introText];
                CGFloat height = layout.textBoundingSize.height;
                CGFloat ttheight = 23 + height + 5 + 25;
                pushModel.pushModelCellHeight = ttheight;
                return ttheight;
            }else{
                return pushModel.pushModelCellHeight;
            }
        }else{
            return 50+iconW/2;
        }
    }else if (pushModel.dfContent.type == MOMENT_TYPE_PRAISEREDPOINT){
        return 50+iconW/2;
    }else{
        return 50+iconW/2;
    }
}

-(NSMutableAttributedString *)getNSAttributedStringWithString:(NSString *)content{
    
    NSMutableAttributedString * introText = [content YYTransEmotionWithFont:DFFont_Comment_14];

//    NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:content];
//    introText.yy_paragraphSpacing = 5;
    introText.yy_lineSpacing = 4;
    introText.yy_font = DFFont_Comment_14;
    return introText;
}

-(CGFloat)getMessageHeight:(NSAttributedString *)attString withWidth:(CGFloat)width
{
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(ScreenWidth - (bianjie10+bianjie10 + iconW + 5 +youbian), CGFLOAT_MAX) text:attString];
    CGFloat height = layout.textBoundingSize.height;
    return height;
}

-(void)updateCommentWithModel:(DFPushModel*)pushModel
{
    [self layoutIfNeeded];
    _nameBtn.text = pushModel.dfContent.remark;
    [_iconView setImageWithURL:[DFLogicTool getImgWithStr:pushModel.dfContent.avatar] title:pushModel.dfContent.remark size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    _timeLabel.text = [DFToolUtil preettyTime:pushModel.dfContent.ctime];

    if (pushModel.dfContent.comment.content && pushModel.isDeletedRemindComment) {
            _contentYYLabel.attributedText = [[NSAttributedString alloc]initWithString:@""];
            _contentYYLabel.backgroundColor = [UIColor whiteColor];
            _deleLabel.hidden = NO;
    }else{
        NSAttributedString * attStr = [self getNSAttributedStringWithString:pushModel.dfContent.comment.content];
        _contentYYLabel.attributedText = attStr;
        _contentYYLabel.backgroundColor = [UIColor whiteColor];
        _deleLabel.hidden = YES;
    }
//    _contentYYLabel.backgroundColor = [UIColor greenColor];

    if (pushModel.dfContent.comment.content.length > 0) {
        _praiseImg.hidden = YES;
    }else{
        _praiseImg.hidden = NO;
    }

    DFBaseMomentModel * baseModel = [[DFMomentsManager sharedInstance].allModel_dict objectForKey:pushModel.dfContent.msgId];
    if (baseModel && baseModel.message.mediasList.count) {
        _rightLabel.hidden = YES;
        _picView.hidden = NO;
        NSString * imgStr = [baseModel.message.mediasList[0] objectForKey:@"medias_thumb"];
        [_picView sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:imgStr]] placeholderImage:[UIImage imageNamed:@"defaultavatar"]];
        
        if (baseModel.message.type == MomentSendType_Video) {
            self.playView.hidden = NO;
            [self.playView setFrame:CGRectMake(10, 10, _picView.mj_w - 20, _picView.mj_h - 20)];
            [_picView addSubview:self.playView];
        }else{
            self.playView.hidden = YES;
        }
        
        [_picView addSubview:self.playView];
        
    }else{
        _picView.hidden = YES;
        self.playView.hidden = YES;
        _rightLabel.hidden = NO;
        
        if (baseModel.message.type == MomentSendType_News && baseModel.message.resourceContent.length >0) {
            NSDictionary * resourceDic = [DFLogicTool JsonStringToDictionary:baseModel.message.resourceContent];
            _rightLabel.text = [resourceDic objectForKey:@"title"];
        }else{
            NSMutableAttributedString * introText = [baseModel.message.content YYTransEmotionWithFont:DFFont_TimeLabel_12];
            _rightLabel.attributedText = introText;
//            _rightLabel.backgroundColor = [UIColor blueColor];
//            _rightLabel.text = baseModel.message.content;
        }
    }
}

-(void)makeConstraints{
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(bianjie10);
        make.right.mas_equalTo(-bianjie10);
        make.bottom.mas_equalTo(-2);
    }];
    
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(3);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(iconW);
        make.height.mas_equalTo(iconW);
    }];
    
    [_nameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_iconView.mas_top).mas_offset(0);
        make.left.mas_equalTo(_iconView.mas_right).mas_offset(5);
//        make.width.mas_equalTo(160);
        make.right.mas_equalTo(_picView.mas_left).offset(-5);
        make.height.mas_equalTo(15);
    }];

    [_picView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
//        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
//        make.bottom.mas_equalTo(-2);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(60);
    }];
    
    [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        //        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        //        make.bottom.mas_equalTo(-2);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(60);
    }];
    
    [_contentYYLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_nameBtn.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(_nameBtn.mas_left);
        make.right.mas_equalTo(_picView.mas_left).offset(-5);
        make.bottom.mas_equalTo(_timeLabel.mas_top).offset(-5);
    }];
    
    [_deleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_nameBtn.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(_nameBtn.mas_left);
//        make.right.mas_equalTo(-youbian);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(22);
    }];
    
    [_praiseImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_nameBtn.mas_bottom).mas_offset(8);
        make.left.mas_equalTo(_nameBtn.mas_left);
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(14);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(_nameBtn.mas_top);
        make.left.mas_equalTo(_nameBtn.mas_left);
        make.bottom.mas_equalTo(0);

        make.width.mas_equalTo(100);
        make.height.mas_equalTo(15);
    }];
}

-(UIImageView *)backView{
    if (!_backView) {
        _backView = [[UIImageView alloc]init];
        //        _backView.backgroundColor = [UIColor lightGrayColor];
//                _backView.backgroundColor = [UIColor greenColor];
//        _backView.image = [UIImage imageNamed:@"likenotcell"];
        //        _backView.layer.cornerRadius = 20; //宽度的一半
        //        _backView.layer.masksToBounds = YES;
        _backView.userInteractionEnabled = NO;
    }
    return _backView;
}

-(UIImageView *)praiseImg{
    if (!_praiseImg) {
        _praiseImg = [[UIImageView alloc]init];
        _praiseImg.backgroundColor = [UIColor clearColor];
        
        UIImage *image = [UIImage imageNamed:@"praiseBlueKong"];
        _praiseImg.image = image;
    }
    return _praiseImg;
}

-(UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.backgroundColor = [UIColor whiteColor];
//        _iconView.backgroundColor = [UIColor blueColor];
        _iconView.layer.cornerRadius = iconW/2;
        _iconView.layer.masksToBounds = YES;
        _iconView.userInteractionEnabled = NO;
        UITapGestureRecognizer * iconTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToUserTimeLine)];
        [_iconView addGestureRecognizer:iconTap];
    }
    return _iconView;
}

-(UILabel *)nameBtn
{
    if (!_nameBtn) {
        _nameBtn = [[UILabel alloc]init];
        _nameBtn.text = @"用户名";
        _nameBtn.textColor = DFNameColor;
        _nameBtn.font = DFFont_LikeLabelFont_14B;
        _nameBtn.backgroundColor = [UIColor whiteColor];
//        _nameBtn.backgroundColor = [UIColor orangeColor];
        _nameBtn.textAlignment = NSTextAlignmentLeft;
        _nameBtn.userInteractionEnabled = NO;
        UITapGestureRecognizer * nameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToUserTimeLine)];
        [_nameBtn addGestureRecognizer:nameTap];
    }
    return _nameBtn;
}

-(UILabel *)rightLabel{
    if (!_rightLabel) {
        _rightLabel = [[YYLabel alloc]init];
        _rightLabel.userInteractionEnabled = NO;
//        _rightLabel.lineBreakMode = NSLineBreakByCharWrapping;    //以字符为显示单位显示，后面部分省略不显示。
//        _rightLabel.backgroundColor = [UIColor redColor];
        _rightLabel.font = DFFont_TimeLabel_12;
        _rightLabel.numberOfLines = 4;
    }
    return _rightLabel;
}

-(UIImageView *)picView{
    if (!_picView) {
        _picView = [[UIImageView alloc]init];
//        _picView.backgroundColor = [UIColor blueColor];
//        _picView.image = [UIImage imageNamed:@"likenotcell"];
        _picView.userInteractionEnabled = NO;
        _picView.contentMode = UIViewContentModeScaleAspectFill;
        _picView.clipsToBounds = YES;
    }
    return _picView;
}

-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.text = @"9月4日 11:25";
        _timeLabel.font = DFFont_TimeLabel_12;
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.backgroundColor = [UIColor whiteColor];
//        _timeLabel.backgroundColor = [UIColor yellowColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

//-(UILabel *)contentLabel{
//    if (!_contentLabel) {
//        _contentLabel = [[UILabel alloc]init];
//        _contentLabel.text = @"评论正文";
//        _contentLabel.numberOfLines = 0;
//        _contentLabel.font = DFFont_Comment_14;
//        _contentLabel.backgroundColor = [UIColor clearColor];
//        _contentLabel.textAlignment = NSTextAlignmentLeft;
//    }
//    return _contentLabel;
//}

-(YYLabel *)contentYYLabel{
    if (!_contentYYLabel) {
        _contentYYLabel = [[YYLabel alloc] init];
        _contentYYLabel.font = DFFont_Comment_14;
        //        _contentYYLabel.attributedText = one;
        //        _contentYYLabel.frame = CGRectMake(20, 200, self.view.frame.size.width-40, 200);
        //        _contentYYLabel.textAlignment = NSTextAlignmentLeft;
        //        _contentYYLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        _contentYYLabel.numberOfLines = 0;
        //        _contentYYLabel.backgroundColor = [UIColor colorWithWhite:0.933 alpha:1.000];
        _contentYYLabel.backgroundColor = [UIColor whiteColor];
//        _contentYYLabel.backgroundColor = [UIColor greenColor];
    }
    return _contentYYLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(UIImageView *)playView{
    if (!_playView) {
        _playView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"playVideo"]];
        _playView.userInteractionEnabled = YES;
    }
    return _playView;
}

@end
