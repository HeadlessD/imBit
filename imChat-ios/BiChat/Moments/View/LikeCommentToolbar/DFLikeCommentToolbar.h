//
//  DFLikeCommentToolbar.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/29.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

@protocol DFLikeCommentToolbarDelegate <NSObject>

@required

-(void) on2LikeFromCommentTool;
-(void) clickCommentButtonOne;

@end

@interface DFLikeCommentToolbar : UIImageView


@property (nonatomic, strong) UIButton *likeButton;

@property (nonatomic, strong) UIButton *commentButton;

@property (nonatomic, strong) UIView *divider;


@property (nonatomic, weak) id<DFLikeCommentToolbarDelegate> delegate;

-(void)changeWidth;

@end
