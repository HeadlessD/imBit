//
//  DFLikeCommentView.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/28.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFLikeCommentView.h"

#define BottomMargin 5
#define TopMargin 10
#define LikeIconLeftMargin 8
#define LikeIconTopMargin 12
#define LikeIconSize 15
#define LikeLabelIconSpace 5
#define LikeLabelRightMargin 10
#define CommentLabelMargin 5
#define LikeCommentSpace 5

#define LikeLabelLineHeight 1.2f    //点赞名称的行间距
#define CommentHeight 4          //每条评论间距

@interface DFLikeCommentView()<UIGestureRecognizerDelegate,MLLinkLabelDelegate,MLLinkClickLabelDelegate>

@property (nonatomic, strong) UIImageView *likesanjiao;
@property (strong, nonatomic) UIImageView *likeIconView;

@property (strong, nonatomic) MLLinkLabel *likeLabel;

@property (strong, nonatomic) UIView *divider;
@property (strong, nonatomic) NSMutableArray *commentLabels;
@property (strong, nonatomic) DFBaseMomentModel * baseModel;

@property (copy, nonatomic) NSString * boardString;

@property (strong, nonatomic) CommentModel * commentModel;

@end

@implementation DFLikeCommentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _commentLabels = [NSMutableArray array];
        [self initView];
    }
    return self;
}

-(void) initView
{
    CGFloat x,y,width,height;
    
    if (_likesanjiao == nil) {
        x = 0;
        y = 0;
        width = self.frame.size.width;
        height = self.frame.size.height;
        
        _likesanjiao = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        UIImage *image = [UIImage imageNamed:@"likesanjiao"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 30, 10, 10) resizingMode:UIImageResizingModeStretch];
        _likesanjiao.image = image;
        [self addSubview:_likesanjiao];
    }
    
    if (_likeIconView == nil) {
        x = LikeIconLeftMargin;
        y = LikeIconTopMargin;
        width = LikeIconSize;
        //        height = width;
        _likeIconView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, 14)];
        _likeIconView.image = [UIImage imageNamed:@"praiseBlueKong"];
//        _likeIconView.backgroundColor = [UIColor blueColor];
        [self addSubview:_likeIconView];
    }
    
    [self addSubview:self.likeLabel];
    
    
    if (_divider == nil) {
        _divider = [[UIView alloc] initWithFrame:CGRectZero];
        _divider.backgroundColor = [UIColor colorWithWhite:225/255.0 alpha:1.0];
        [self addSubview:_divider];
    }
}


-(void)layoutSubviews
{
    CGFloat x,y,width,height;
    x = 0;
    y = 0;
    width = self.frame.size.width;
    height = self.frame.size.height;
    
    _likesanjiao.frame = CGRectMake(x, y, width, height);
}

-(void)updateLikeCommentWithItem:(DFBaseMomentModel *)item
{
    _baseModel = item;
    
    CGFloat x, y, width, height;
    
    _divider.hidden = YES;
    
    if (item.praiseList.count > 0) {
        
        _likeLabel.hidden = NO;
        _likeIconView.hidden = NO;
        
        x = CGRectGetMaxX(_likeIconView.frame)+LikeLabelIconSpace;
        y = TopMargin;
        width = self.frame.size.width - x - LikeLabelRightMargin;
        
        NSMutableAttributedString * likeAtt = [DFAttStringManager getLikeAttSstr:item];
        _likeLabel.attributedText = likeAtt;
//        _likeLabel.text = @"sdsdsd";
        [_likeLabel sizeToFit];
        
        CGSize textSize = [DFAttStringManager getHeightWithContent:likeAtt withWidth:width].size;
        _likeLabel.frame = CGRectMake(x, y, width, textSize.height);
    }else{
        _likeLabel.hidden = YES;
        _likeIconView.hidden = YES;
    }
    
    if (item.commentList.count > 0) {
        
        CGFloat sumHeight = TopMargin;
        if (item.praiseList.count > 0) {
            //显示分割线
            y = CGRectGetMaxY(_likeLabel.frame) + LikeCommentSpace;
            _divider.hidden = NO;
            _divider.frame = CGRectMake(0, y, self.frame.size.width, 0.5);
            sumHeight = CGRectGetMaxY(_likeLabel.frame) + LikeCommentSpace + 2;
        }
        
        NSUInteger labelCount = _commentLabels.count;
        
        for (int i=0; i<labelCount; i++) {
            MLLinkClickLabel * label = [_commentLabels objectAtIndex:i];
            label.attributedText = nil;
            label.frame = CGRectZero;
            label.hidden = !(i<item.commentList.count);
        }
        //text
        for (int i=0;i<item.commentList.count;i++) {
            MLLinkClickLabel * label;
            if ( labelCount > 0 && i < labelCount) {
                label = [_commentLabels objectAtIndex:i];
            }else{
                label = [self createLinkLabel];
                
                [_commentLabels addObject:label];
                [self addSubview:label];
            }
            //            label.backgroundColor = DFCOLOR_Arc;
            
            CommentModel *commentItem = [item.commentList objectAtIndex:i];

            width = self.frame.size.width - 2*CommentLabelMargin;
            
            NSMutableAttributedString * muattStr = [DFAttStringManager getCommentAttStr:commentItem];

            CGSize size = [DFAttStringManager getHeightWithContent:muattStr withWidth:width].size;
            
            label.attributedText = muattStr;
            
            label.tag = 100+i;
            label.userInteractionEnabled = YES;

            label.frame = CGRectMake(CommentLabelMargin, sumHeight, width, size.height);

            sumHeight += size.height + CommentHeight;
        }
    }else{
        for (int i=0; i<_commentLabels.count; i++) {
            MLLinkClickLabel * label = [_commentLabels objectAtIndex:i];
            label.attributedText = nil;
            label.frame = CGRectZero;
            label.hidden = YES;
        }
    }
}

-(void)onLongClickOutsideLinkLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state==UIGestureRecognizerStateBegan) {
    
        CommentModel *commentModel = [_baseModel.commentList objectAtIndex:(longPress.view.tag - 100)];
        
        _commentModel = commentModel;
        _boardString = commentModel.content;
        
            //    NSLog(@"长按了Label: %@",commentModel.content);
        [self becomeFirstResponder];
        
        UIMenuItem *msgCopy = [[UIMenuItem alloc]initWithTitle:LLSTR(@"102401") action:@selector(msgCopy:)];
        
        UIMenuItem *msgDelete = nil;
        if ([commentModel.commentUser.uid isEqualToString:[BiChatGlobal sharedManager].uid]) {
            msgDelete = [[UIMenuItem alloc] initWithTitle:LLSTR(@"101018") action:@selector(msgDelete:)];
        }
        
        UIMenuController *menuView = [UIMenuController sharedMenuController];
        [menuView setMenuItems:nil];
        
        if (msgDelete) {
            menuView.menuItems = @[msgCopy,msgDelete];
        }else{
            menuView.menuItems = @[msgCopy];
        }
        
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
        //    NSLog(@"点击了评论");
    if (_delegate && [_delegate respondsToSelector:@selector(clickCommentViewOne:)]) {
        [_delegate clickCommentViewOne:_commentModel];
    }
}

-(void)onClickOutsideLinkWithIndex:(NSInteger)index{
            //    NSLog(@"单击了%ld-Label",index);
    if (_delegate && [_delegate respondsToSelector:@selector(clickCommentViewOne:)]) {
        CommentModel *commentItem = [_baseModel.commentList objectAtIndex:(index - 100)];
        [_delegate clickCommentViewOne:commentItem];
    }
}

+(CGFloat)getHeight:(DFBaseMomentModel *)item maxWidth:(CGFloat)maxWidth
{
    //    _baseModel = item;
    
    CGFloat height = TopMargin;
    
    if (item.praiseList.count > 0) {
        
        CGFloat width = maxWidth -  LikeIconLeftMargin - LikeIconSize - LikeLabelIconSpace - LikeLabelRightMargin;
        
        NSMutableAttributedString * likeAtt = [DFAttStringManager getLikeAttSstr:item];
        CGSize textSize = [DFAttStringManager getHeightWithContent:likeAtt withWidth:width].size;
        
        height+= textSize.height +2;
    }
    
    if (item.commentList.count > 0) {
        
        CGFloat width = maxWidth - CommentLabelMargin*2;
        
        for (CommentModel * comm in item.commentList) {
            
            NSMutableAttributedString *str = [DFAttStringManager getCommentAttStr:comm];
            CGSize textSize = [DFAttStringManager getHeightWithContent:str withWidth:width].size;
            
            height+= textSize.height+CommentHeight;
        }
    }
    height+=BottomMargin;
    return height;
}

-(MLLinkClickLabel *) createLinkLabel
{
    MLLinkClickLabel *lable = [[MLLinkClickLabel alloc] initWithFrame:CGRectZero];
    lable.clickDelegate = self;
    lable.font = DFFont_Comment_14;
    lable.numberOfLines = 0;
    lable.adjustsFontSizeToFitWidth = NO;
    lable.textInsets = UIEdgeInsetsZero;
    lable.dataDetectorTypes = MLDataDetectorTypeAll;
//    lable.allowLineBreakInsideLinks = NO;
    lable.linkTextAttributes = nil;
    lable.activeLinkTextAttributes = nil;
    lable.linkTextAttributes = @{NSForegroundColorAttributeName: DFNameColor};
//    [lable setLineBreakMode:NSLineBreakByCharWrapping];
    
    __block DFLikeCommentView *likeCommentView = self;

    [lable setDidClickLinkBlock:^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
        if (_delegate && [_delegate respondsToSelector:@selector(pushWithUrlFromeDFLikeCommentView:)]) {
            [likeCommentView.delegate pushWithUrlFromeDFLikeCommentView:link.linkValue];
        }
            //    NSLog(@"%@",link.linkValue);
    }];
    return lable;
}

-(MLLinkLabel *)likeLabel{
    if (!_likeLabel) {
        _likeLabel =[[MLLinkLabel alloc] initWithFrame:CGRectZero];
        _likeLabel.font = DFFont_Comment_14;
        _likeLabel.numberOfLines = 0;
        _likeLabel.adjustsFontSizeToFitWidth = NO;
        _likeLabel.textInsets = UIEdgeInsetsZero;
        _likeLabel.dataDetectorTypes = MLDataDetectorTypeAll;
//        _likeLabel.allowLineBreakInsideLinks = NO;
        _likeLabel.linkTextAttributes = nil;
        _likeLabel.activeLinkTextAttributes = nil;
        _likeLabel.linkTextAttributes = @{NSForegroundColorAttributeName: DFNameColor};
      
        __block DFLikeCommentView *likeCommentView = self;

        [_likeLabel setDidClickLinkBlock:^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
            if (_delegate && [_delegate respondsToSelector:@selector(pushWithUrlFromeDFLikeCommentView:)]) {
                [likeCommentView.delegate pushWithUrlFromeDFLikeCommentView:link.linkValue];
            }
                //    NSLog(@"%@",link.linkValue);
        }];
    }
    return _likeLabel;
}

@end
