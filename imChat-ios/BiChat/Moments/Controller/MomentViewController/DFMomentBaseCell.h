//
//  DFMomentBaseCell.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/27.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "DFBaseMomentModel.h"
#import "DFGridImageView.h"
#import "DFLikeCommentToolbar.h"
#import "DFLikeCommentView.h"


@class DFMomentBaseCell;

@protocol DFMomentBaseCellDelegate <NSObject>
@optional
-(void) on3LikeFromeLineCell:(DFBaseMomentModel *) baseModel;
-(void) onClickAvatarOnCellLeftBtn:(NSString *) userId;
-(void) clickCommentViewTwo:(CommentModel *)commentModel momentId:(NSString *)momentId;
-(void) clickCommentButtonTwo:(DFBaseMomentModel *)momentModel;
-(void) deleteMomentWithMoment:(DFBaseMomentModel*)moment;
-(void) clickImgOnDFMomentBaseCellWithThumbImgArr:(NSArray *)thumbImgArr displayImgArr:(NSArray *)displayImgArr withTag:(NSInteger)tag withBaseModel:(DFBaseMomentModel *)baseModel;
-(void)pushWithUrlFromeDFMomentBaseCell:(NSString *)url;


-(void)clickOpenContentWithMoment:(DFMomentBaseCell *)baseCell;

-(void)DFMomentBaseCellToClickShareNewsWithMoment:(DFBaseMomentModel*)moment;

-(void)DFMomentBaseCellToClickLocation:(DFBaseMomentModel*)moment;

-(void)momentViewClickLikeCommentBtn:(DFBaseMomentModel*)moment momCell:(DFMomentBaseCell *)momCell;

-(void)DFMomentBaseCellToPlayVideoWithMoment:(DFBaseMomentModel*)moment;

@end

@interface DFMomentBaseCell : UITableViewCell
@property (nonatomic, strong) UIView *bodyView;
@property (nonatomic, weak) id<DFMomentBaseCellDelegate> delegate;
@property (strong, nonatomic) DFGridImageView *gridImageView;
@property (nonatomic, strong) DFLikeCommentView *likeCommentView;
@property (nonatomic, strong) DFLikeCommentToolbar *likeCommentToolbar;

@property (nonatomic, strong) NSString * cellIndexStr;

-(NSInteger) getIndexFromPoint:(CGPoint) point;
-(void) updateWithItem:(DFBaseMomentModel *) item;
+(CGFloat) getCellHeight:(DFBaseMomentModel *) item;
+(CGFloat)getMomentBaseCellHeight:(DFBaseMomentModel *)item isSaveH:(BOOL)isSaveH;
-(void) hideLikeCommentToolbar;
-(UINavigationController *) getController;
@end
