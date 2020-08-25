//
//  DFDetailMomentCell.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/27.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "DFBaseMomentModel.h"
#import "DFGridImageView.h"
#import "DFLikeCommentView.h"

#define  BodyMaxWidth [UIScreen mainScreen].bounds.size.width - UserAvatarSize - 3*Margin

@protocol DFDetailMomentCellDelegate <NSObject>
@optional
-(void) on3LikeFromeLineCell:(DFBaseMomentModel *) baseModel;
-(void) onClickAvatarOnCellLeftBtn:(NSString *) userId;
-(void) clickCommentButtonTwo:(DFBaseMomentModel *)momentModel;
-(void)deleteMomentWithMoment:(DFBaseMomentModel*)moment;
-(void) clickImgOnDFDetailMomentCellWithThumbImgArr:(NSArray *)thumbImgArr displayImgArr:(NSArray *)displayImgArr withTag:(NSInteger)tag withBaseModel:(DFBaseMomentModel *)baseModel;

-(void)DFMomentBaseCellToClickShareNewsWithMoment:(DFBaseMomentModel*)moment;

-(void)DFMomentBaseCellToClickLocation:(DFBaseMomentModel*)moment;

-(void)pushWithUrlFromeDFDetailMomentCell:(NSString *)url;

-(void)DFDetailMomentCellToPlayVideoWithMoment:(DFBaseMomentModel*)moment;

@end

@interface DFDetailMomentCell : UITableViewCell
@property (nonatomic, strong) UIView *bodyView;
@property (nonatomic, weak) id<DFDetailMomentCellDelegate> delegate;
@property (strong, nonatomic) DFGridImageView *gridImageView;
@property (nonatomic, strong) DFLikeCommentView *likeCommentView;
@property (nonatomic, strong) DFLikeCommentToolbar *likeCommentToolbar;

-(NSInteger) getIndexFromPoint:(CGPoint) point;
-(void) updateWithItem:(DFBaseMomentModel *) item;
+(CGFloat) getCellHeight:(DFBaseMomentModel *) item;

+(CGFloat)getReuseableCellHeight:(DFBaseMomentModel *)item;
-(void) hideLikeCommentToolbar;
-(UINavigationController *) getController;
@end
