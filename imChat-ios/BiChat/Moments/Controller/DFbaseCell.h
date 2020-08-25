//
//  DFbaseCell.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/27.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "DFBaseMomentModel.h"
#import "DFGridImageView.h"
#import "DFLikeCommentToolbar.h"

#define Margin 10
#define Padding 5
#define UserAvatarSize 40

#define  BodyMaxWidth [UIScreen mainScreen].bounds.size.width - UserAvatarSize - 3*Margin

@interface DFbaseCell : UITableViewCell
@property (nonatomic, strong) UIView *bodyView;
@property (strong, nonatomic) DFGridImageView *gridImageView;
@property (nonatomic, strong) DFLikeCommentToolbar *likeCommentToolbar;

-(NSInteger) getIndexFromPoint:(CGPoint) point;
-(void) updateWithItem:(DFBaseMomentModel *) item;
+(CGFloat) getCellHeight:(DFBaseMomentModel *) item;
+(CGFloat)getReuseableCellHeight:(DFBaseMomentModel *)item;
-(void) hideLikeCommentToolbar;
-(UINavigationController *) getController;
@end
