//
//  DFDetailCommentCell.m
//  BiChat Dev
//
//  Created by chat on 2018/9/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#define iconW  33

#import "DFDetailCommentCell.h"

@interface DFDetailCommentCell ()<MLLinkClickLabelDelegate,MLLinkLabelDelegate>

@property (nonatomic,strong) UITapGestureRecognizer  * pushTap;
@property (copy, nonatomic) NSString * boardString;

@property (strong, nonatomic) CommentModel * detailCommentModel;
@property (nonatomic,strong) UIImageView * backView;
@property (nonatomic,strong) UIImageView * iconView;
@property (nonatomic,strong) UILabel * nameBtn;
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,strong) MLLinkClickLabel * contentYYLabel;

@end

@implementation DFDetailCommentCell

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

-(void)createView{
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.commentIcon];
    [self.backView addSubview:self.iconView];
    [self.backView addSubview:self.nameBtn];
    [self.backView addSubview:self.timeLabel];
    [self.backView addSubview:self.contentYYLabel];
    [self makeConstraints];
    
//    UILongPressGestureRecognizer * copyContent = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onLongPressClickContent:)];
//    [self addGestureRecognizer:copyContent];
    //        [_contentYYLabel addGestureRecognizer:copyContent];
}

-(void)pushToUserTimeLine{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(clickNameAndAvavtarWithId:)]) {
        [_delegate clickNameAndAvavtarWithId:_detailCommentModel.commentUser.uid];
    }
        //    NSLog(@"pushToUserTimeLine");
}

-(CGFloat)getCommentHeightWithModel:(CommentModel *)model
{
    [self.contentView layoutIfNeeded];
    NSMutableAttributedString * content = [DFAttStringManager getNSAttributedStringWithModel:model];
    CGFloat height = [DFAttStringManager getHeightWithContent:content withWidth:(ScreenWidth - (10+40+iconW+5+10+10))].size.height;
    
    CGFloat ttheight = _contentYYLabel.mj_y + height + 10;
    return ttheight;
}

-(void)updateCommentWithModel:(CommentModel*)commentModel
{
    [self layoutIfNeeded];
    
    _detailCommentModel = commentModel;
    
    _nameBtn.text = commentModel.commentUser.remark;
    
    [_iconView setImageWithURL:[DFLogicTool getImgWithStr:commentModel.commentUser.avatar] title:commentModel.commentUser.remark size:CGSizeMake(40, 40) placeHolde:nil color:nil textColor:nil];
    
    _timeLabel.text = [DFToolUtil preettyTime:commentModel.ctime];
    
    NSMutableAttributedString * attStr = [DFAttStringManager getNSAttributedStringWithModel:commentModel];
    CGFloat height = [DFAttStringManager getHeightWithContent:attStr withWidth:(ScreenWidth - (10+40+iconW+5+10+10))].size.height;

//    _contentYYLabel.backgroundColor = [UIColor blueColor];
    _contentYYLabel.attributedText = attStr;
}

-(void)makeConstraints{
    [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(0);
    }];
    
    [_commentIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(14);
    }];
    
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(40);
        make.width.mas_equalTo(iconW);
        make.height.mas_equalTo(iconW);
    }];
    
    [_nameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_iconView.mas_top).mas_offset(0);
        make.left.mas_equalTo(_iconView.mas_right).mas_offset(5);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(iconW/2);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_nameBtn.mas_top);
        make.left.mas_equalTo(_nameBtn.mas_right);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(_nameBtn.mas_height);
    }];
    
    [_contentYYLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_nameBtn.mas_bottom).mas_offset(2);
        make.left.mas_equalTo(_iconView.mas_right).mas_offset(5);
        make.right.mas_equalTo(_timeLabel.mas_right);
        make.bottom.mas_equalTo(-5);
    }];
}

-(UIImageView *)backView{
    if (!_backView) {
        _backView = [[UIImageView alloc]init];
        _backView.backgroundColor = [UIColor lightGrayColor];
        _backView.image = [UIImage imageNamed:@"likenotcell"];
        //        _backView.layer.cornerRadius = 20; //宽度的一半
        //        _backView.layer.masksToBounds = YES;
        _backView.userInteractionEnabled = YES;
    }
    return _backView;
}

-(UIImageView *)commentIcon{
    if (!_commentIcon) {
        _commentIcon = [[UIImageView alloc]init];
        _commentIcon.backgroundColor = [UIColor clearColor];
        
        UIImage *image = [UIImage imageNamed:@"CommentBlueKong"];
        _commentIcon.image = image;
    }
    return _commentIcon;
}

-(UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]init];
        _iconView.backgroundColor = [UIColor lightGrayColor];
        _iconView.layer.cornerRadius = iconW/2;
        _iconView.layer.masksToBounds = YES;
        _iconView.userInteractionEnabled = YES;
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
        _nameBtn.backgroundColor = [UIColor clearColor];
        _nameBtn.textAlignment = NSTextAlignmentLeft;
        _nameBtn.userInteractionEnabled = YES;
        UITapGestureRecognizer * nameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToUserTimeLine)];
        [_nameBtn addGestureRecognizer:nameTap];
    }
    return _nameBtn;
}

-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.text = @"9月4日 11:25";
        _timeLabel.font = DFFont_TimeLabel_12;
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

-(MLLinkClickLabel *)contentYYLabel{
    if (!_contentYYLabel) {
        _contentYYLabel = [[MLLinkClickLabel alloc] initWithFrame:CGRectZero];
        _contentYYLabel.clickDelegate = self;
        _contentYYLabel.font = DFFont_Comment_14;
        _contentYYLabel.numberOfLines = 0;
        _contentYYLabel.adjustsFontSizeToFitWidth = NO;
        _contentYYLabel.textInsets = UIEdgeInsetsZero;
        _contentYYLabel.dataDetectorTypes = MLDataDetectorTypeAll;
//        _contentYYLabel.allowLineBreakInsideLinks = NO;
        _contentYYLabel.linkTextAttributes = nil;
        _contentYYLabel.activeLinkTextAttributes = nil;
        _contentYYLabel.linkTextAttributes = @{NSForegroundColorAttributeName: DFNameColor};
//            [_contentYYLabel setLineBreakMode:NSLineBreakByCharWrapping];
        _contentYYLabel.backgroundColor = [UIColor clearColor];
        __block DFDetailCommentCell * detailCommentCell = self;
        
        [_contentYYLabel setDidClickLinkBlock:^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
            [detailCommentCell pushWithStr:link.linkValue];
        }];
    }
    return _contentYYLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)onLongPressClickContent:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state==UIGestureRecognizerStateBegan) {
        
        _boardString = _contentYYLabel.text;
        
            //    NSLog(@"长按了Label: %@",_contentYYLabel.text);
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

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    return NO;
    
    //交给系统去打理
    //    return YES;
}

-(void)pushWithStr:(NSString *)str{
    if ([[str substringToIndex:6] isEqualToString:@"userId"]) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(clickNameAndAvavtarWithId:)]) {
            [_delegate clickNameAndAvavtarWithId:[str substringFromIndex:6]];
        }
            //    NSLog(@"pushUserId");
    }else if ([[str substringToIndex:3] isEqualToString:@"url"]){
        if (_delegate != nil && [_delegate respondsToSelector:@selector(pushWithUrlFromeDFDetailCommentCell:)]) {
            [_delegate pushWithUrlFromeDFDetailCommentCell:[str substringFromIndex:3]];
        }
            //    NSLog(@"pushURL");
    }
}

//直接响应cell点击 不用另外写方法
-(void)onClickOutsideLinkWithIndex:(NSInteger)index{

}

@end
