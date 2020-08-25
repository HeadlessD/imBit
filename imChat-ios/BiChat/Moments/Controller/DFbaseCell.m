//
//  DFMomentBaseCell.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/27.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//


#define UserNickMaxWidth 150

//#define UserNickLabelHeight 15

//位置高度暂时设置为0
#define LocationLabelHeight 15
#define TimeLabelHeight 15
#define UserNickLineHeight 1.2f
#define LikeLabelLineHeight 1.2f
#define LikeCommentTimeSpace 3
#define ToolbarWidth 190
#define ToolbarHeight 34

#define TextImageCell @"timeline_cell_text_image"
#define TextLineHeight 1.2f
#define TextImageSpace 10
#define GridMaxWidth (BodyMaxWidth)*0.85

#define contentHeight 119

#import "DFbaseCell.h"
#import "DFLikeCommentView.h"
#import "DFLikeCommentToolbar.h"
#import "DFToolUtil.h"
#import "DFBaseMomentModel.h"
#import "DFGridImageView.h"
#import "NSString+MLExpression.h"
#import "MLLinkClickLabel.h"
#import "DFShareNewsView.h"
#import "WPNewsDetailViewController.h"

@interface DFbaseCell()<DFLikeCommentToolbarDelegate,DFLikeCommentViewDelegate,MLLinkClickLabelDelegate,DFShareNewsViewDelegate,DFGridImageViewDelegate,YYTextViewDelegate>

@property (nonatomic, strong) DFBaseMomentModel * baseItem;
@property (nonatomic, strong) UIImageView *userAvatarView;
@property (nonatomic, strong) UILabel *userNickLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *likeCmtButton;
@property (nonatomic, strong) UIButton * deleteButton;
@property (nonatomic, strong) DFLikeCommentView *likeCommentView;
@property (nonatomic, assign) BOOL isLikeCommentToolbarShow;

@property (nonatomic,strong) MLLinkClickLabel * textContentYYTextView;

@property (copy, nonatomic) NSString * boardString;

@property (nonatomic, strong) UIButton * openBtn;

@property (strong, nonatomic) DFShareNewsView * shareNewsView;

@end

@implementation DFbaseCell

#pragma mark - Lifecycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //        _isLikeCommentToolbarShow = NO;
        
        [self initBaseCell];
    }
    return self;
}

-(void) initBaseCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat dfx = 0.0, dfy, dfwidth, dfheight;
    //    self.contentView.backgroundColor = [UIColor blueColor];
    if (_userAvatarView == nil ) {
        
        dfx = Margin;
        dfy = Margin;
        dfwidth = UserAvatarSize;
        dfheight = dfwidth;
        _userAvatarView = [[UIImageView alloc] initWithFrame:CGRectMake(dfx, dfy, dfwidth, dfheight)];
        
        _userAvatarView.layer.cornerRadius = _userAvatarView.frame.size.width/2;
        _userAvatarView.layer.masksToBounds = YES;
        _userAvatarView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer * avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickAvatarOnCell)];
        _userAvatarView.userInteractionEnabled = YES;
        [_userAvatarView addGestureRecognizer:avatarTap];
        
        [self.contentView addSubview:_userAvatarView];
    }
    
    [self.contentView addSubview:self.userNickLabel];
    
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor lightGrayColor];
        _titleLabel.font = DFFont_TimeLabel_12;
        //        [self.contentView addSubview:_titleLabel];
    }
    
    if (_bodyView == nil) {
        dfx = CGRectGetMaxX(_userAvatarView.frame) + Margin;
        dfy = 40;
        dfwidth = BodyMaxWidth;
        dfheight = 1;
        _bodyView = [[UIView alloc] initWithFrame:CGRectMake(dfx, dfy, dfwidth, dfheight)];
        [self.contentView addSubview:_bodyView];
    }
    
    //    _bodyView.backgroundColor = [UIColor blueColor];
    
    _shareNewsView = [[DFShareNewsView alloc]initWithFrame:CGRectMake(dfx,_bodyView.mj_y + _bodyView.mj_h+30, ScreenWidth - 10 - dfx, 60)];
    _shareNewsView.delegate = self;
    [self.contentView addSubview:_shareNewsView];
    
    if (_locationLabel == nil) {
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _locationLabel.textColor = DFNameColor;
        _locationLabel.font = DFFont_TimeLabel_12;
        _locationLabel.hidden = YES;
        _locationLabel.backgroundColor = DFCOLOR_Arc;
        [self.contentView addSubview:_locationLabel];
    }
    
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = [UIColor lightGrayColor];
        //        _timeLabel.backgroundColor = [UIColor greenColor];
        _timeLabel.font = DFFont_TimeLabel_12;
        _timeLabel.hidden = YES;
        [self.contentView addSubview:_timeLabel];
    }
    
    if (_deleteButton == nil) {
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        //        _deleteButton.hidden = YES;
        //        _deleteButton.backgroundColor = [UIColor blueColor];
        [_deleteButton setTitle:LLSTR(@"101018") forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = DFFont_TimeLabel_12;
        [_deleteButton setTitleColor:DFNameColor forState:UIControlStateNormal];
        //        [_deleteButton setImage:[UIImage imageNamed:@"AlbumOperateMore"] forState:UIControlStateNormal];
        //        [_deleteButton setImage:[UIImage imageNamed:@"AlbumOperateMoreHL"] forState:UIControlStateHighlighted];
        [_deleteButton addTarget:self action:@selector(clickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];
    }
    
    if (_likeCmtButton == nil) {
        _likeCmtButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _likeCmtButton.hidden = YES;
        [_likeCmtButton setImage:[UIImage imageNamed:@"AlbumOperateMore"] forState:UIControlStateNormal];
        [_likeCmtButton setImage:[UIImage imageNamed:@"AlbumOperateMoreHL"] forState:UIControlStateHighlighted];
        [_likeCmtButton addTarget:self action:@selector(onClickLikeCommentBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_likeCmtButton];
    }
    
    if (_likeCommentView == nil) {
        dfy = 0;
        dfwidth = BodyMaxWidth;
        dfheight = 10;
        _likeCommentView = [[DFLikeCommentView alloc] initWithFrame:CGRectMake(dfx, dfy, dfwidth, dfheight)];
        //        _likeCommentView.backgroundColor = [UIColor blueColor];
        _likeCommentView.delegate = self;
        [self.contentView addSubview:_likeCommentView];
    }
    
    if (_likeCommentToolbar == nil) {
        dfy = 0;
        dfx = 0;
        dfwidth = ToolbarWidth;
        dfheight = ToolbarHeight;
        _likeCommentToolbar = [[DFLikeCommentToolbar alloc] initWithFrame:CGRectMake(dfx,dfy, dfwidth, dfheight)];
        _likeCommentToolbar.delegate = self;
        _likeCommentToolbar.hidden = YES;
        
        [self.contentView addSubview:_likeCommentToolbar];
    }
    
    ///////////////// ///////////////// ///////////////////////
    
    [self.bodyView addSubview:self.textContentYYTextView];
    
    if (_gridImageView == nil) {
        
        CGFloat x, y , width, height;
        
        x = 0;
        y = 0;
        width = GridMaxWidth;
        height = width;
        
        _gridImageView = [[DFGridImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _gridImageView.delegate = self;
        [self.bodyView addSubview:_gridImageView];
    }
}



@end
