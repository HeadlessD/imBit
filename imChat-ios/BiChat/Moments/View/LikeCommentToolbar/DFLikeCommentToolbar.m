//
//  DFLikeCommentToolbar.m
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/29.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFLikeCommentToolbar.h"

@interface DFLikeCommentToolbar()


@end

@implementation DFLikeCommentToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
    }
    return self;
}

-(void) initView
{
    
    self.userInteractionEnabled = YES;
    
    UIImage *image = [UIImage imageNamed:@"AlbumOperateMoreViewBkg"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    self.image = image;
    
    CGFloat width;
    width = self.frame.size.width/2;
    
    CGSize likeSize = [LLSTR(@"104002") boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:DFFont_Comment_14} context:nil].size;
 
    CGSize commSize = [LLSTR(@"104003") boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:DFFont_Comment_14} context:nil].size;
    
    CGFloat jg = (self.frame.size.width - likeSize.width - commSize.width)/4;
    
    
    _likeButton = [self getButton:CGRectMake(0, 0, likeSize.width + jg*2, self.frame.size.height) title:LLSTR(@"104002") image:@"AlbumLike"];
    [_likeButton addTarget:self action:@selector(onLikeClick:) forControlEvents:UIControlEventTouchUpInside];
//    [_likeButton setBackgroundColor:[UIColor redColor]];
    [self addSubview:_likeButton];
    
    
    _commentButton = [self getButton:CGRectMake(_likeButton.mj_w, 0, commSize.width + jg*2, self.frame.size.height) title:LLSTR(@"104003") image:@"AlbumComment"];
    [_commentButton addTarget:self action:@selector(onCommentBtnTarget:) forControlEvents:UIControlEventTouchUpInside];
//    [_commentButton setBackgroundColor:[UIColor blueColor]];
    [self addSubview:_commentButton];
    
    //分割线
    _divider = [[UIView alloc] initWithFrame:CGRectMake(_likeButton.mj_w, 8, 1, self.frame.size.height - 16)];
    _divider.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_divider];
}

-(void)changeWidth{
    CGFloat width;
    width = self.frame.size.width/2;
    
    CGSize likeSize = [_likeButton.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:DFFont_Comment_14} context:nil].size;
    
    CGSize commSize = [_commentButton.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:DFFont_Comment_14} context:nil].size;
    
    CGFloat jg = (self.frame.size.width - likeSize.width - commSize.width)/4;
    
    [_likeButton setFrame:CGRectMake(0, 0, likeSize.width + jg*2, self.frame.size.height)];
    
    [_commentButton setFrame:CGRectMake(_likeButton.mj_w, 0, commSize.width + jg*2, self.frame.size.height)];
    
    //分割线
    [_divider setFrame:CGRectMake(_likeButton.mj_w, 8, 1, self.frame.size.height - 16)];

}

-(UIButton *) getButton:(CGRect) frame title:(NSString *) title image:(NSString *) image
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    //btn.backgroundColor = [UIColor redColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    btn.titleLabel.font = DFFont_Comment_14;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return btn;
}

-(void) onLikeClick:(id) sender
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(on2LikeFromCommentTool)]) {
        [_delegate on2LikeFromCommentTool];
    }
}
//点击评论btn
-(void)onCommentBtnTarget:(id) sender
{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(clickCommentButtonOne)]) {
        [_delegate clickCommentButtonOne];
    }
}
@end
