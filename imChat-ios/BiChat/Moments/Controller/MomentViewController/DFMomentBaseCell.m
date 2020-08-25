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
#define ToolbarWidth 190
#define ToolbarHeight 30
#define Margin 10
#define TextImageSpace 6
#define LikeCommentTimeSpace 3

#define UserAvatarSize 40

#define  BodyMaxWidth [UIScreen mainScreen].bounds.size.width - UserAvatarSize - 3*Margin

#define TextImageCell @"timeline_cell_text_image"
#define TextLineHeight 1.2f
#define GridMaxWidth (BodyMaxWidth)*0.85

#define contentHeight 119

#import "DFMomentBaseCell.h"
#import "DFLikeCommentView.h"
#import "DFLikeCommentToolbar.h"
#import "DFToolUtil.h"
#import "DFBaseMomentModel.h"
#import "DFGridImageView.h"
#import "NSString+MLExpression.h"
#import "MLLinkClickLabel.h"
#import "DFShareNewsView.h"
#import "WPNewsDetailViewController.h"

@interface DFMomentBaseCell()<DFLikeCommentToolbarDelegate,DFLikeCommentViewDelegate,MLLinkClickLabelDelegate,DFShareNewsViewDelegate,DFGridImageViewDelegate,YYTextViewDelegate>

@property (nonatomic, strong) DFBaseMomentModel * baseItem;
@property (nonatomic, strong) UIImageView *userAvatarView;
@property (nonatomic, strong) UILabel *userNickLabel;
@property (nonatomic, strong) UIButton *locationLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *likeCmtButton;
@property (nonatomic, strong) UIButton * deleteButton;
//@property (nonatomic, assign) BOOL isLikeCommentToolbarShow;

@property (nonatomic,strong) MLLinkClickLabel * textContentYYTextView;

@property (copy, nonatomic) NSString * boardString;

@property (nonatomic, strong) UIButton * openBtn;

@property (strong, nonatomic) DFShareNewsView * shareNewsView;

@property (nonatomic, strong) UIImageView * videoImgView;
@property (nonatomic, strong) UIImageView * playView;

@end

@implementation DFMomentBaseCell

#pragma mark - Lifecycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initBaseCell];
    }
    return self;
}

-(void) initBaseCell
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.userAvatarView];
    [self.contentView addSubview:self.userNickLabel];
    [self.contentView addSubview:self.bodyView];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.shareNewsView];
    [self.contentView addSubview:self.videoImgView];

    [self.contentView addSubview:self.likeCmtButton];
    [self.contentView addSubview:self.likeCommentToolbar];
    
    [self.bodyView addSubview:self.textContentYYTextView];
}

#pragma mark - Method
-(void)updateWithItem:(DFBaseMomentModel *)item
{
    self.baseItem = item;
    
    if (item.message.isPrais) {
        [_likeCommentToolbar.likeButton setTitle:LLSTR(@"101002") forState:UIControlStateNormal];
    }else{
        [_likeCommentToolbar.likeButton setTitle:LLSTR(@"104002") forState:UIControlStateNormal];
    }
    
    [_likeCommentToolbar changeWidth];
    
    //设置头像
    [_userAvatarView setImageWithURL:item.message.createUser.avatar title:item.message.createUser.remark size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    
    NSMutableAttributedString * userNick = [item.message.createUser.remark DFTransEmotionWithFont:DFFont_NameFont_16B];
    _userNickLabel.attributedText = userNick;
    //设置完富文本需要重新设置linebreak
    _userNickLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    _userNickLabel.frame = CGRectMake(CGRectGetMaxX(_userAvatarView.frame) + Margin,
                                      CGRectGetMinY(_userAvatarView.frame) +2,
                                      ScreenWidth - (CGRectGetMaxX(_userAvatarView.frame) + Margin) - 20,
                                      25);
    
    //设置正文
    CGFloat contentFrameH = 0;
    
    NSMutableAttributedString * attStr2 = [DFAttStringManager getUrlAttOnAtt:[item.message.content DFTransEmotionWithFont:DFFont_Content_15]];
    
    CGSize  textSizenew = [DFAttStringManager getHeightWithContent:attStr2 withWidth:BodyMaxWidth].size;
    
    _textContentYYTextView.attributedText = attStr2;
    if (textSizenew.height > contentHeight) {
        // 修改按钮的折叠打开状态
        if (item.isOpen) {
            _textContentYYTextView.frame = CGRectMake(0, 0, BodyMaxWidth, textSizenew.height);
            [_openBtn setTitle:LLSTR(@"104019") forState:UIControlStateNormal];
            
            self.openBtn.frame = CGRectMake(_textContentYYTextView.mj_x, _textContentYYTextView.mj_y + _textContentYYTextView.mj_h + 10, 80 , 15);
        }else{
            _textContentYYTextView.frame = CGRectMake(0, 0, BodyMaxWidth,contentHeight);
            [_openBtn setTitle:LLSTR(@"104020") forState:UIControlStateNormal];
            textSizenew.height = contentHeight;
            self.openBtn.frame = CGRectMake(_textContentYYTextView.mj_x, _textContentYYTextView.mj_y + _textContentYYTextView.mj_h + 10, 80 , 15);
        }
        
        self.openBtn.hidden = NO;
        contentFrameH = CGRectGetMaxY(_textContentYYTextView.frame)+TextImageSpace + 30;
    }else{
        self.openBtn.hidden = YES;
        _textContentYYTextView.frame = CGRectMake(0, 0, BodyMaxWidth, textSizenew.height);
        contentFrameH = CGRectGetMaxY(_textContentYYTextView.frame)+TextImageSpace;
    }
    
    if (item.itthumbImages.count > 0) {
        [self.bodyView addSubview:self.gridImageView];
        self.gridImageView.hidden = NO;
        CGFloat gridHeight = [DFGridImageView gridGetHeight:item.itthumbImages maxWidth:GridMaxWidth withModel:item];
        
        _gridImageView.frame = CGRectMake(_gridImageView.frame.origin.x,
                                          contentFrameH,
                                          _gridImageView.frame.size.width, gridHeight);
        contentFrameH += gridHeight + TextImageSpace;
        [_gridImageView updateWithImagesForBaseModel:item];

    }else{
        self.gridImageView.hidden = YES;
    }
    
    _bodyView.frame = CGRectMake(_bodyView.frame.origin.x, _bodyView.frame.origin.y, _bodyView.frame.size.width, contentFrameH);
    
    CGFloat otherHeight = CGRectGetMaxY(_bodyView.frame);
    
    
    NSDictionary * resourceDic = [DFLogicTool JsonStringToDictionary:item.message.resourceContent];
    
    //设置分享的新闻
    if (item.message.type == MomentSendType_News && item.message.resourceContent.length >0) {

        _shareNewsView.hidden = NO;
        
        _shareNewsView.shareLabel.text = [resourceDic objectForKey:@"title"];
        [_shareNewsView.shareImgView sd_setImageWithURL:[NSURL URLWithString:[resourceDic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"share_link_gray"]];
        _shareNewsView.frame = CGRectMake(CGRectGetMaxX(_userAvatarView.frame) + Margin,
                                          otherHeight,
                                          ScreenWidth - 10 - (CGRectGetMaxX(_userAvatarView.frame) + Margin),
                                          60);
        otherHeight += 60 + TextImageSpace;
    }else{
        _shareNewsView.hidden = YES;
    }
    
    if (item.message.type == MomentSendType_Video) {
        
        NSDictionary * videoDic = item.message.mediasList[0];
//        NSDictionary * videoDic = [DFLogicTool JsonStringToDictionary:item.message.mediasList[0]];

        _videoImgView.hidden = NO;
        
        if ([DFLogicTool getImgWithStr:[videoDic objectForKey:@"medias_thumb"]]) {
            [_videoImgView sd_setImageWithURL:[NSURL URLWithString:[DFLogicTool getImgWithStr:[videoDic objectForKey:@"medias_thumb"]]] placeholderImage:[UIImage imageNamed:@"default_image"]];
        }else{
            [_videoImgView setImage:item.videoImgArr[0]];
        }
        
        CGSize videoSize = CGSizeZero;
        videoSize.width =  [[videoDic objectForKey:@"oneImgWidth"] integerValue];
        videoSize.height = [[videoDic objectForKey:@"oneImgHeight"] integerValue];
        if (!videoSize.width || !videoSize.height) {
            videoSize.width =  item.videoImgWidth;
            videoSize.height = item.videoImgHeight;
        }
        
        
        CGSize sizeTwo = [DFLogicTool calcDFThumbSize:videoSize.width height:videoSize.height];
        
        _videoImgView.frame = CGRectMake(CGRectGetMaxX(_userAvatarView.frame) + Margin, otherHeight, sizeTwo.width*0.8, sizeTwo.height*0.8);
                
//        [_playView setFrame:CGRectMake((sizeTwo.width - 70)/2, (sizeTwo.height - 70)/2, 70, 70)];
        _playView.center = CGPointMake(CGRectGetMidX(_videoImgView.bounds), CGRectGetMidY(_videoImgView.bounds));

        otherHeight += sizeTwo.height*0.8 + TextImageSpace;

    }else{
        _videoImgView.hidden = YES;
    }

    //设置位置
    if (self.baseItem.message.location != nil && ![self.baseItem.message.location isEqualToString:@""] && ![self.baseItem.message.location isEqualToString:@"{}"]) {
        
        [self.contentView addSubview:self.locationLabel];
        
        _locationLabel.hidden = NO;
        
        NSDictionary * locaDic = [DFLogicTool JsonStringToDictionary:self.baseItem.message.location];
        if (locaDic) {
            [_locationLabel setTitle:[locaDic objectForKey:@"name"] forState:UIControlStateNormal];
        }
        
        CGSize theStringSize = [_locationLabel.titleLabel.text sizeWithFont:DFFont_TimeLabel_12 constrainedToSize:CGSizeMake(MAXFLOAT, LocationLabelHeight) lineBreakMode:NSLineBreakByCharWrapping];
        
        _locationLabel.frame = CGRectMake(_bodyView.frame.origin.x, otherHeight+5, theStringSize.width + 5, LocationLabelHeight);
        _locationLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        otherHeight += LocationLabelHeight + TextImageSpace+5;
        
    }else{
        _locationLabel.hidden = YES;
    }
    
    _timeLabel.text = [DFToolUtil preettyTime:self.baseItem.message.ctime];
    NSDictionary *attributes = @{NSFontAttributeName:DFFont_TimeLabel_12,};
    CGSize textSize = [_timeLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, TimeLabelHeight) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;;
    _timeLabel.frame = CGRectMake(_bodyView.frame.origin.x, otherHeight, textSize.width + 5, TimeLabelHeight);
    
    _deleteButton.frame =  CGRectMake(_timeLabel.mj_x+_timeLabel.mj_w, _timeLabel.mj_y, 45, _timeLabel.mj_h);
    //    _deleteButton.backgroundColor = [UIColor redColor];
    _deleteButton.titleEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    
    if ([self.baseItem.message.createUser.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
        _deleteButton.hidden = NO;
    }else{
        _deleteButton.hidden = YES;
    }
    
    //点赞评论按钮
    _likeCmtButton.frame = CGRectMake(CGRectGetMaxX(_bodyView.frame) - 25 + 2, otherHeight-7, 25, 25);
    
    //点赞和评论Toolbar
    _likeCommentToolbar.frame = CGRectMake(CGRectGetMinX(_likeCmtButton.frame)-_likeCommentToolbar.frame.size.width - 10,
                                           CGRectGetMinY(_likeCmtButton.frame) - 4,
                                           _likeCommentToolbar.frame.size.width,
                                           _likeCommentToolbar.frame.size.height);
    
    //点赞和评论
    if (self.baseItem.praiseList.count ==0 && self.baseItem.commentList.count == 0) {
        
        _likeCommentView.hidden = YES;
    }else{
        [self.contentView addSubview:self.likeCommentView];
        _likeCommentView.hidden = NO;
        _likeCommentView.frame = CGRectMake(CGRectGetMinX(_timeLabel.frame),
                                            CGRectGetMaxY(_timeLabel.frame)+LikeCommentTimeSpace,
                                            _likeCommentView.frame.size.width,
                                            [DFLikeCommentView getHeight:self.baseItem maxWidth:BodyMaxWidth]);
        [_likeCommentView updateLikeCommentWithItem:self.baseItem];
    }
    
    if (item.dontClick) {
        //            self.likeCmtButton.hidden = YES;
        self.deleteButton.userInteractionEnabled = NO;
        [_deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        _likeCommentToolbar.likeButton.userInteractionEnabled = NO;
        [_likeCommentToolbar.likeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        _likeCommentToolbar.commentButton.userInteractionEnabled = NO;
        [_likeCommentToolbar.commentButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
    }else{
        //            self.likeCmtButton.hidden = NO;
        self.deleteButton.userInteractionEnabled = YES;
        [_deleteButton setTitleColor:DFNameColor forState:UIControlStateNormal];
        
        _likeCommentToolbar.likeButton.userInteractionEnabled = YES;
        [_likeCommentToolbar.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _likeCommentToolbar.commentButton.userInteractionEnabled = YES;
        [_likeCommentToolbar.commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}


-(void)playVideoClick{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(DFMomentBaseCellToPlayVideoWithMoment:)]) {
        [_delegate DFMomentBaseCellToPlayVideoWithMoment:self.baseItem];
    }
}

-(void)clickLocationBtn{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(DFMomentBaseCellToClickLocation:)]) {
        [_delegate DFMomentBaseCellToClickLocation:self.baseItem];
    }
}

-(void)shareNewsClickWithModel{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(DFMomentBaseCellToClickShareNewsWithMoment:)]) {
        [_delegate DFMomentBaseCellToClickShareNewsWithMoment:self.baseItem];
    }
}

-(void)clickDeleteBtn:(UIButton *)btn{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(deleteMomentWithMoment:)]) {
        [_delegate deleteMomentWithMoment:self.baseItem];
    }
}

+(CGFloat)getMomentBaseCellHeight:(DFBaseMomentModel *)item isSaveH:(BOOL)isSaveH;
{
    if (item.cellHeight != 0 && !item.cellHeightChange) {
        return item.cellHeight;
    }else{
        CGFloat height = [DFMomentBaseCell getCellHeight:item];
        item.cellHeight = height;
        item.cellHeightChange = NO;
        if ((isSaveH && !item.isOpen) || item.message.location != nil) {
            
            if (item.itthumbImages.count > 0) {
                id imgStr = item.itthumbImages[0];
                if([imgStr isKindOfClass:[NSString class]]){
                    [DFYTKDBManager saveMomentModel:item];//存库
                    //                    NSLog(@"是img字符串");
                }else{
                    //                    NSLog(@"是img对象");
                }
            }
        }
        
        return height;
    }
}

+(CGFloat) getCellHeight:(DFBaseMomentModel *)item
{
    CGFloat cellHeight = Margin + UserAvatarSize;
    
    NSMutableAttributedString * attStr = [item.message.content DFTransEmotionWithFont:DFFont_Content_15];
    
    NSMutableAttributedString * attStr2 = [DFAttStringManager getUrlAttOnAtt:attStr];
    CGSize   textSizenew = [DFAttStringManager getHeightWithContent:attStr2 withWidth:BodyMaxWidth].size;
    
    if (textSizenew.height > contentHeight) {
        
        if (item.isOpen) {
            //    NSLog(@"open");
        }else{
            //    NSLog(@"closed");
            textSizenew.height = contentHeight;
        }
        cellHeight += textSizenew.height + 25;
    }else{
        cellHeight += textSizenew.height;
    }
    
    if (item.itthumbImages.count > 0) {
        CGFloat gridHeight = [DFGridImageView gridGetHeight:item.itthumbImages maxWidth:GridMaxWidth withModel:item];
        cellHeight += gridHeight + TextImageSpace;
    }
    
    //链接
    if (item.message.type == MomentSendType_News && item.message.resourceContent.length >0) {
        cellHeight += 60 + TextImageSpace;
    }
    
    if (item.message.type == MomentSendType_Video) {

        NSDictionary * videoDic = item.message.mediasList[0];
//        NSDictionary * videoDic = [DFLogicTool JsonStringToDictionary:item.message.mediasList[0]];

        CGSize videoSize = CGSizeZero;
        videoSize.width =  [[videoDic objectForKey:@"oneImgWidth"] integerValue];
        videoSize.height = [[videoDic objectForKey:@"oneImgHeight"] integerValue];
        if (!videoSize.width || !videoSize.height) {
            videoSize.width =  item.videoImgWidth;
            videoSize.height = item.videoImgHeight;
        }
        
        CGSize sizeTwo = [DFLogicTool calcDFThumbSize:videoSize.width height:videoSize.height];
 
        cellHeight += sizeTwo.height*0.8 + TextImageSpace;
    }
    
    //位置
    if (item.message.location != nil && ![item.message.location isEqualToString:@""] && ![item.message.location isEqualToString:@"{}"]) {
        cellHeight += LocationLabelHeight + TextImageSpace+5;
    }
    
    //时间
    cellHeight += TimeLabelHeight + TextImageSpace;
    
    //点赞和评论
    if (!(item.praiseList.count == 0 && item.commentList.count == 0)) {
        cellHeight += [DFLikeCommentView getHeight:item maxWidth:BodyMaxWidth] + TextImageSpace;
    }
    
    return cellHeight;
}

-(void)clickImgOnDFGridImageViewWithThumbImgArr:(NSArray *)thumbImgArr displayImgArr:(NSArray *)displayImgArr withTag:(NSInteger)tag
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(clickImgOnDFMomentBaseCellWithThumbImgArr:displayImgArr:withTag:withBaseModel:)]) {
        [_delegate clickImgOnDFMomentBaseCellWithThumbImgArr:thumbImgArr displayImgArr:displayImgArr withTag:tag withBaseModel:self.baseItem];
    }
}

-(void)onClickAvatarOnCell
{
    //    NSLog(@"点击左侧用户头像");
    if (_delegate != nil && [_delegate respondsToSelector:@selector(onClickAvatarOnCellLeftBtn:)]) {
        [_delegate onClickAvatarOnCellLeftBtn:self.baseItem.message.createUser.uid];
    }
}

-(void)pushWithUrlFromeDFLikeCommentView:(NSString *)url{
    if ([[url substringToIndex:6] isEqualToString:@"userId"]) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(onClickAvatarOnCellLeftBtn:)]) {
            [_delegate onClickAvatarOnCellLeftBtn:[url substringFromIndex:6]];
        }
    }else if ([[url substringToIndex:3] isEqualToString:@"url"]){
        if (_delegate != nil && [_delegate respondsToSelector:@selector(pushWithUrlFromeDFMomentBaseCell:)]) {
            [_delegate pushWithUrlFromeDFMomentBaseCell:[url substringFromIndex:3]];
        }
    }
}

-(void) onClickLikeCommentBtn
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(momentViewClickLikeCommentBtn:momCell:)]) {
        [_delegate momentViewClickLikeCommentBtn:self.baseItem momCell:self];
    }
}

-(void)hideLikeCommentToolbar
{
    _likeCommentToolbar.hidden = YES;
}

#pragma mark - DFLikeCommentToolbarDelegate
-(void)on2LikeFromCommentTool
{
    [self hideLikeCommentToolbar];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(on3LikeFromeLineCell:)]) {
        [_delegate on3LikeFromeLineCell:self.baseItem];
    }
}

#pragma mark - DFLikeCommentViewDelegate
//点击评论btn
- (void)clickCommentButtonOne{
    [self hideLikeCommentToolbar];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(clickCommentButtonTwo:)]) {
        [_delegate clickCommentButtonTwo:self.baseItem];
    }
}

//点击评论View
-(void)clickCommentViewOne:(CommentModel *)commentModel{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(clickCommentViewTwo:momentId:)]) {
        [_delegate clickCommentViewTwo:commentModel momentId:self.baseItem.message.momentId];
    }
}

-(NSInteger) getIndexFromPoint: (CGPoint) point
{
    return [_gridImageView getIndexFromPoint:point];
}


-(void)onLongPressClickContent:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state==UIGestureRecognizerStateBegan) {
        
        //        self.baseItem.message.content
        if (self.baseItem.message.content.length > 0) {
            _boardString = self.baseItem.message.content;
        }
        
        [self becomeFirstResponder];
        
        UIMenuItem *msgCopy = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102401") action:@selector(msgCopy:)];
        //    UIMenuItem *msgDelete = [[UIMenuItem alloc] initWithTitle:LLSTR(@"101018") action:@selector(msgDelete:)];
        
        UIMenuController *menuView = [UIMenuController sharedMenuController];
        [menuView setMenuItems:nil];
        menuView.menuItems = @[msgCopy];
        [menuView setTargetRect:longPress.view.bounds inView:longPress.view];
        [menuView setMenuVisible:YES animated:YES];
        [UIMenuController sharedMenuController].menuItems = nil;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(msgCopy:) || action == @selector(msgDelete:)) return YES;
    
    return NO;
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)msgCopy:(UIMenuController *)menu  {
    // 将自己的文字复制到粘贴板
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    if (_boardString.length > 0) {
        board.string = _boardString;
    }
    //    NSLog(@"board.string_%@",board.string);
    // 将粘贴板的文字 复制 到自己身上
    //        self.text = board.string;
}

- (void)msgDelete:(UIMenuController *)menu  {
    //    NSLog(@"%s %@", __func__ , menu);
}

-(UIButton *)openBtn{
    if (!_openBtn) {
        _openBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_openBtn setTitle:LLSTR(@"104020") forState:UIControlStateNormal];
        _openBtn.titleLabel.font = DFFont_Content_15;
        [_openBtn setTitleColor:DFNameColor forState:UIControlStateNormal];
        [_openBtn addTarget:self action:@selector(clickOpenContent:) forControlEvents:UIControlEventTouchUpInside];
        
        _openBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.bodyView addSubview:_openBtn];
    }
    return _openBtn;
}

-(void)clickOpenContent:(UIButton *)btn{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(clickOpenContentWithMoment:)]) {
        [_delegate clickOpenContentWithMoment:self];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    
    return NO;
    //交给系统去打理
    //    return YES;
}


-(MLLinkClickLabel *)textContentYYTextView{
    if (!_textContentYYTextView) {
        _textContentYYTextView = [[MLLinkClickLabel alloc] initWithFrame:CGRectZero];
        _textContentYYTextView.clickDelegate = self;
        _textContentYYTextView.font = DFFont_Comment_14;
        _textContentYYTextView.numberOfLines = 0;
        _textContentYYTextView.adjustsFontSizeToFitWidth = NO;
        _textContentYYTextView.textInsets = UIEdgeInsetsZero;
        _textContentYYTextView.dataDetectorTypes = MLDataDetectorTypeAll;
        //        _textContentYYTextView.allowLineBreakInsideLinks = NO;
        _textContentYYTextView.linkTextAttributes = nil;
        _textContentYYTextView.activeLinkTextAttributes = nil;
        _textContentYYTextView.linkTextAttributes = @{NSForegroundColorAttributeName: DFNameColor};
        //        [_textContentYYTextView setLineBreakMode:NSLineBreakByCharWrapping];
        _textContentYYTextView.backgroundColor = [UIColor clearColor];
        //        _textContentYYTextView.backgroundColor = DFCOLOR_Arc;
        
        __block DFMomentBaseCell * momentBaseCell = self;
        
        [_textContentYYTextView setDidClickLinkBlock:^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
            //    NSLog(@"%@",link.linkValue);
            
            [momentBaseCell pushWithUrlFromeDFLikeCommentView:link.linkValue];
            //            if (_delegate != nil && [_delegate respondsToSelector:@selector(pushWithUrlFromeDFMomentBaseCell:)]) {
            //                [momentBaseCell.delegate pushWithUrlFromeDFMomentBaseCell:link.linkValue];
            //            }
        }];
        
        UILongPressGestureRecognizer * copyContent = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onLongPressClickContent:)];
        _textContentYYTextView.userInteractionEnabled = YES;
        [_textContentYYTextView addGestureRecognizer:copyContent];
    }
    return _textContentYYTextView;
}

-(UILabel *)userNickLabel{
    
    if (!_userNickLabel) {
        
        _userNickLabel =[[UILabel alloc] initWithFrame:CGRectZero];
        _userNickLabel.textColor = DFNameColor;
        _userNickLabel.font = DFFont_NameFont_16B;
        _userNickLabel.numberOfLines = 1;
        _userNickLabel.adjustsFontSizeToFitWidth = NO;
        //        _userNickLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        //        _userNickLabel.backgroundColor = [UIColor blueColor];
        //        _userNickLabel.textInsets = UIEdgeInsetsZero;
        //        _userNickLabel.dataDetectorTypes = MLDataDetectorTypeAll;
        //        _userNickLabel.linkTextAttributes = nil;
        //        _userNickLabel.activeLinkTextAttributes = nil;
        
        UITapGestureRecognizer * avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickAvatarOnCell)];
        _userNickLabel.userInteractionEnabled = YES;
        [_userNickLabel addGestureRecognizer:avatarTap];
    }
    return _userNickLabel;
}

-(UIImageView *)userAvatarView{
    if (!_userAvatarView) {
        _userAvatarView = [[UIImageView alloc] initWithFrame:CGRectMake(Margin, Margin, UserAvatarSize, UserAvatarSize)];
        _userAvatarView.layer.cornerRadius = _userAvatarView.frame.size.width/2;
        _userAvatarView.layer.masksToBounds = YES;
        _userAvatarView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer * avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickAvatarOnCell)];
        _userAvatarView.userInteractionEnabled = YES;
        [_userAvatarView addGestureRecognizer:avatarTap];
    }
    return _userAvatarView;
}

-(UIView *)bodyView{
    if (!_bodyView) {
        _bodyView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_userAvatarView.frame) + Margin, 40, BodyMaxWidth, 1)];
    }
    return _bodyView;
}

-(DFShareNewsView *)shareNewsView{
    if (!_shareNewsView) {
        _shareNewsView  = [[DFShareNewsView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_userAvatarView.frame) + Margin,_bodyView.mj_y + _bodyView.mj_h+30, ScreenWidth - 10 - (CGRectGetMaxX(_userAvatarView.frame) + Margin), 60)];
        _shareNewsView.delegate = self;
    }
    return _shareNewsView;
}

-(UIButton *)locationLabel{
    if (!_locationLabel) {
        _locationLabel = [[UIButton alloc] initWithFrame:CGRectZero];
        //        [_locationLabel setTitle:LLSTR(@"101018") forState:UIControlStateNormal];
        _locationLabel.titleLabel.font = DFFont_TimeLabel_12;
        [_locationLabel setTitleColor:DFNameColor forState:UIControlStateNormal];
        //        [_deleteButton setImage:[UIImage imageNamed:@"AlbumOperateMore"] forState:UIControlStateNormal];
        //        [_deleteButton setImage:[UIImage imageNamed:@"AlbumOperateMoreHL"] forState:UIControlStateHighlighted];
        [_locationLabel addTarget:self action:@selector(clickLocationBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationLabel;
}


-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = [UIColor lightGrayColor];
        //        _timeLabel.backgroundColor = [UIColor greenColor];
        _timeLabel.font = DFFont_TimeLabel_12;
    }
    return _timeLabel;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        //        _deleteButton.hidden = YES;
        //        _deleteButton.backgroundColor = [UIColor blueColor];
        [_deleteButton setTitle:LLSTR(@"101018") forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = DFFont_TimeLabel_12;
        [_deleteButton setTitleColor:DFNameColor forState:UIControlStateNormal];
        //        [_deleteButton setImage:[UIImage imageNamed:@"AlbumOperateMore"] forState:UIControlStateNormal];
        //        [_deleteButton setImage:[UIImage imageNamed:@"AlbumOperateMoreHL"] forState:UIControlStateHighlighted];
        [_deleteButton addTarget:self action:@selector(clickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

-(UIButton *)likeCmtButton{
    if (!_likeCmtButton) {
        _likeCmtButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_likeCmtButton setImage:[UIImage imageNamed:@"AlbumOperateMore"] forState:UIControlStateNormal];
        [_likeCmtButton setImage:[UIImage imageNamed:@"AlbumOperateMoreHL"] forState:UIControlStateHighlighted];
        [_likeCmtButton addTarget:self action:@selector(onClickLikeCommentBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeCmtButton;
}

-(DFLikeCommentView *)likeCommentView{
    if (!_likeCommentView) {
        _likeCommentView = [[DFLikeCommentView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_userAvatarView.frame) + Margin, 0, BodyMaxWidth, 10)];
        _likeCommentView.delegate = self;
    }
    return _likeCommentView;
}

-(DFLikeCommentToolbar *)likeCommentToolbar{
    if (!_likeCommentToolbar) {
        _likeCommentToolbar = [[DFLikeCommentToolbar alloc] initWithFrame:CGRectMake(0,0, ToolbarWidth, ToolbarHeight)];
        _likeCommentToolbar.delegate = self;
        _likeCommentToolbar.hidden = YES;
    }
    return _likeCommentToolbar;
}

-(DFGridImageView *)gridImageView{
    if (!_gridImageView) {
        _gridImageView = [[DFGridImageView alloc] initWithFrame:CGRectMake(0, 0, GridMaxWidth, GridMaxWidth)];
        _gridImageView.delegate = self;
    }
    return _gridImageView;
}

-(UIImageView *)videoImgView{
    if (!_videoImgView) {
        _videoImgView = [[UIImageView alloc]init];
        _videoImgView.userInteractionEnabled = YES;
        [_videoImgView addSubview:self.playView];
    }
    return _videoImgView;
}

-(UIImageView *)playView{
    if (!_playView) {
        _playView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"playVideo"]];
        _playView.userInteractionEnabled = YES;

        UITapGestureRecognizer * clickVideo = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVideoClick)];
        [_playView addGestureRecognizer:clickVideo];
    }
    return _playView;
}

@end
