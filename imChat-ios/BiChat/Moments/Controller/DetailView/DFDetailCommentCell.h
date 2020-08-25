//
//  DFDetailCommentCell.h
//  BiChat Dev
//
//  Created by chat on 2018/9/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DFDetailCommentCellDelegate <NSObject>
-(void)clickNameAndAvavtarWithId:(NSString *)userId;
-(void)pushWithUrlFromeDFDetailCommentCell:(NSString *)url;

-(void)clickCommentViewTwoOnDFDetailCommentCell:(CommentModel *)commentModel;

@end


@interface DFDetailCommentCell : UITableViewCell
@property (nonatomic,weak) id<DFDetailCommentCellDelegate> delegate;
@property (nonatomic,strong) UIImageView * commentIcon;

-(CGFloat)getCommentHeightWithModel:(CommentModel *)model;

-(void)updateCommentWithModel:(CommentModel*)commentModel;

@end
