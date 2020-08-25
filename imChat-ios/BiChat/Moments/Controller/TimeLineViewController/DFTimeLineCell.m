//
//  DFTimeLineCell.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/10/15.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFTimeLineCell.h"

#define TextCellHeight 40
#define TextImageCellHeight 70

#define ImageTxtPadding 5

#define TimeDayLabelLeftMargin 10
#define TimeDayLabelTopMargin 15

#define BodyViewLeftMargin 80
#define BodyViewRightMargin 15

@interface DFTimeLineCell()

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UILabel *txtLabel;
@property (nonatomic, strong) UILabel *photoCountLabel;
@property (nonatomic, strong) DFBaseMomentModel *item;
@property (nonatomic, strong) UILabel *timeDayLabel;
@property (nonatomic, strong) UILabel *timeMonthLabel;

@property (nonatomic, strong) UIImageView * playView;

@property (strong, nonatomic) DFShareNewsView * shareNewsView;

@end

@implementation DFTimeLineCell

#pragma mark - Lifecycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}

-(void) initSubView
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (_timeDayLabel == nil) {
        _timeDayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeDayLabel.font = [UIFont boldSystemFontOfSize:30];
        //_timeDayLabel.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_timeDayLabel];
    }
    
    if (_timeMonthLabel == nil) {
        _timeMonthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeMonthLabel.font = DFFont_TimeLabel_12;
        //_timeDayLabel.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_timeMonthLabel];
    }
    
    if (_bodyView == nil) {
        _bodyView = [[UIButton alloc] initWithFrame:CGRectZero];
        //_bodyView.backgroundColor = [UIColor darkGrayColor];

        [_bodyView addTarget:self action:@selector(onClickBodyView:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_bodyView];
    }
    
    if (_coverView == nil) {
        _coverView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _coverView.backgroundColor = [UIColor lightGrayColor];
        _coverView.contentMode = UIViewContentModeScaleAspectFill;
        _coverView.layer.masksToBounds = YES;
        [self.bodyView addSubview:_coverView];
    }
    if (_txtLabel == nil) {
        _txtLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _txtLabel.font = DFFont_Comment_14;
        _txtLabel.numberOfLines = 0;
//        _txtLabel.backgroundColor = [UIColor blueColor];
        [self.bodyView addSubview:_txtLabel];
    }
    if (_photoCountLabel == nil) {
        _photoCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _photoCountLabel.font = [UIFont systemFontOfSize:10];
        _photoCountLabel.textColor = [UIColor darkGrayColor];
        [self.bodyView addSubview:_photoCountLabel];
    }
    
    
    //分享链接View
    _shareNewsView = [[DFShareNewsView alloc]initWithFrame:CGRectMake(BodyViewLeftMargin,_bodyView.mj_y + _bodyView.mj_h,    [UIScreen mainScreen].bounds.size.width - BodyViewLeftMargin - BodyViewRightMargin, 60)];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickBodyView:)];
    [_shareNewsView addGestureRecognizer:tap];
    [self.contentView addSubview:_shareNewsView];
}

-(void) updateWithItem:(DFBaseMomentModel *) item
{
    self.item = item;
    
    CGFloat basey = item.bShowTime?TimeDayLabelTopMargin:0;
    _timeDayLabel.frame = CGRectMake(TimeDayLabelLeftMargin, basey, 40, 25);
    _timeDayLabel.text = item.day < 10 ? [NSString stringWithFormat:@"0%ld", (unsigned long)item.day]: [NSString stringWithFormat:@"%ld", (unsigned long)item.day];
    _timeDayLabel.hidden = !item.bShowTime;
    
    _timeMonthLabel.frame = CGRectMake(CGRectGetMinX(_timeDayLabel.frame)+_timeDayLabel.frame.size.width, CGRectGetMinY(_timeDayLabel.frame)+10, 30, 15);;
    
    NSString * monthNum = [NSString stringWithFormat:@"%ld",101050+(unsigned long)item.month];
    _timeMonthLabel.text = LLSTR(monthNum);
    _timeMonthLabel.hidden = _timeDayLabel.hidden;
    
    CGFloat  secy, secwidth;
    secy = _item.bShowTime?TimeDayLabelTopMargin:0;
    secwidth = [UIScreen mainScreen].bounds.size.width - BodyViewLeftMargin - BodyViewRightMargin;
//    _bodyView.frame = CGRectMake(BodyViewLeftMargin, secy, secwidth, TextImageCellHeight);

    CGFloat x, y, width, height;
    
    x = 0;
    y = 0;
    width= TextImageCellHeight;
    height = width;
    _coverView.frame  = CGRectMake(x, y, width, height);
    
    //表情转换
   NSAttributedString * attStr = [item.message.content DFTransEmotionWithFont:DFFont_Comment_14];

    if (item.message.mediasList.count) {
        _bodyView.frame = CGRectMake(BodyViewLeftMargin, secy, secwidth, TextImageCellHeight);

        _coverView.hidden = NO;
        
        [_coverView setImage:[UIImage imageNamed:@"default_image"]];

        x = CGRectGetMaxX(_coverView.frame) + ImageTxtPadding;
        width = CGRectGetWidth(self.bodyView.frame) - x - 10;
        height = CGRectGetHeight(self.bodyView.frame) - 20;
        self.bodyView.backgroundColor = [UIColor clearColor];
        
        _txtLabel.text = item.message.content;
        _txtLabel.attributedText = attStr;
        _txtLabel.frame = CGRectMake(x, 0, width, _bodyView.mj_h - 20);
//        _txtLabel.lineBreakMode = NSLineBreakByCharWrapping;
        CGSize size = [_txtLabel sizeThatFits:CGSizeMake(_txtLabel.frame.size.width, MAXFLOAT)];
        
        if (size.height > (_bodyView.mj_h - 20)) {
            size.height = _bodyView.mj_h - 20;
        }
        _txtLabel.frame =CGRectMake(x, 0, width, size.height+5);
        
            //    NSLog(@"item.message.content_%@",item.message.content);
        [self  setImgViewOnCoverViewWithModel:item];
    }else{
        _bodyView.frame = CGRectMake(BodyViewLeftMargin, secy, secwidth, TextCellHeight);

        _coverView.hidden = YES;
        x = ImageTxtPadding;
        y = ImageTxtPadding;
        width = CGRectGetWidth(self.bodyView.frame) - 2*x;
        height = CGRectGetHeight(self.bodyView.frame) - 2*y;
        self.bodyView.backgroundColor = [UIColor colorWithWhite:240/255.0 alpha:1.0];
        _txtLabel.text = item.message.content;
        _txtLabel.attributedText = attStr;
        _txtLabel.frame = CGRectMake(x, 5, width, _bodyView.mj_h - 10);
    }
//    [_txtLabel sizeToFit];
    
//    _bodyView.backgroundColor = [UIColor blueColor];
//    _txtLabel.backgroundColor = [UIColor redColor];
    
    if (item.message.mediasList.count > 1) {
        _photoCountLabel.hidden = NO;
        x = CGRectGetMaxX(_coverView.frame) + ImageTxtPadding;
        width = 30;
        height = 12;
        y = CGRectGetMaxY(_coverView.frame)-height;
        _photoCountLabel.frame = CGRectMake(x, y, width, height);
        _photoCountLabel.text = [NSString stringWithFormat:@"共%ld张",item.message.mediasList.count];
        
    }else{
        _photoCountLabel.hidden = YES;
    }
    
    if (item.message.type == MomentSendType_News) {
        _shareNewsView.hidden = NO;
        _shareNewsView.frame = CGRectMake(_bodyView.mj_x, CGRectGetMaxY(_bodyView.frame), _bodyView.mj_w, 60);
    }else{
        _shareNewsView.hidden = YES;
    }
    
    if (item.message.type == MomentSendType_News && item.message.resourceContent.length >0) {
        NSDictionary * resourceDic = [DFLogicTool JsonStringToDictionary:item.message.resourceContent];
        _shareNewsView.shareLabel.text = [resourceDic objectForKey:@"title"];
        [_shareNewsView.shareImgView sd_setImageWithURL:[NSURL URLWithString:[resourceDic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
    }
}

-(void)setImgViewOnCoverViewWithModel:(DFBaseMomentModel *)model{
    
    if (model.message.mediasList.count == 1) {
       
        UIImageView * subView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _coverView.mj_w, _coverView.mj_w)];
        subView.contentMode = UIViewContentModeScaleAspectFill;
        subView.layer.masksToBounds = YES;
        NSString * imgStr = [model.message.mediasList[0] objectForKey:@"medias_thumb"];
        [subView sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:imgStr]]];

        if (model.message.type == MomentSendType_Video) {
            self.playView.hidden = NO;
            [self.playView setFrame:CGRectMake(10, 10, _coverView.mj_w - 20, _coverView.mj_w - 20)];
            [subView addSubview:self.playView];
        }else{
            self.playView.hidden = YES;
        }

        [_coverView addSubview:subView];

    }else if (model.message.mediasList.count == 2) {
        self.playView.hidden = YES;

        for (int i = 0; i < 2; i++) {
            UIImageView * subView = [[UIImageView alloc]initWithFrame:CGRectMake(i*_coverView.mj_w/2, 0, _coverView.mj_w/2, _coverView.mj_w)];
            subView.contentMode = UIViewContentModeScaleAspectFill;
            subView.layer.masksToBounds = YES;
            
            NSString * imgStr = [model.message.mediasList[i] objectForKey:@"medias_thumb"];
            [subView sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:imgStr]]];
            [_coverView addSubview:subView];
        }
    }else if (model.message.mediasList.count == 3){
        self.playView.hidden = YES;

        UIImageView * subView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _coverView.mj_w/2, _coverView.mj_w)];
        subView.contentMode = UIViewContentModeScaleAspectFill;
        subView.layer.masksToBounds = YES;

        NSString * imgStr = [model.message.mediasList[0] objectForKey:@"medias_thumb"];
        [subView sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:imgStr]]];
        [_coverView addSubview:subView];

        for (int i = 0; i < 2; i++) {
            UIImageView * littleView = [[UIImageView alloc]initWithFrame:CGRectMake(subView.mj_w, i*_coverView.mj_w/2, _coverView.mj_w/2, _coverView.mj_w/2)];
            littleView.contentMode = UIViewContentModeScaleAspectFill;
            littleView.layer.masksToBounds = YES;
            
            NSString * imgStr = [model.message.mediasList[i+1] objectForKey:@"medias_thumb"];
            [littleView sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:imgStr]]];
            [_coverView addSubview:littleView];
        }
        
    }else if (model.message.mediasList.count >= 4){
        self.playView.hidden = YES;

        for (int i = 0; i < 4; i++) {
            UIImageView * subView = [[UIImageView alloc]initWithFrame:CGRectMake((i/2)*_coverView.mj_w/2,
                                                                                 (i%2)*_coverView.mj_w/2,
                                                                                 _coverView.mj_w/2,
                                                                                 _coverView.mj_w/2)];
            subView.contentMode = UIViewContentModeScaleAspectFill;
            subView.layer.masksToBounds = YES;

            NSString * imgStr = [model.message.mediasList[i] objectForKey:@"medias_thumb"];
            [subView sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:imgStr]]];
            [_coverView addSubview:subView];
        }
    }
}

+(CGFloat) getCellHeight:(DFBaseMomentModel *) item
{
    CGFloat heigh = item.bShowTime? TimeDayLabelTopMargin+10:10;

    
    if (item.message.mediasList.count) {
        heigh += TextImageCellHeight;
    }else{
        heigh += TextCellHeight;
    }
    
    if (item.message.type == MomentSendType_News) {
        return heigh + 60;
    }else{
        return heigh;
    }
}

-(void) onClickBodyView:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(onClickItem:)]){
        [_delegate onClickItem:self.item];
    }
}


-(UIImageView *)playView{
    if (!_playView) {
        _playView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"playVideo"]];
        _playView.userInteractionEnabled = YES;
    }
    return _playView;
}

@end
