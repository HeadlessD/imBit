//
//  DFLikeCommentView.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/28.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFBaseMomentModel.h"

@protocol DFLikeCommentViewDelegate <NSObject>
@required
-(void) clickCommentViewOne:(CommentModel *)commentModel;

-(void)pushWithUrlFromeDFLikeCommentView:(NSString *)url;

@end


@interface DFLikeCommentView : UIView

@property (nonatomic, weak) id<DFLikeCommentViewDelegate> delegate;

-(void) updateLikeCommentWithItem:(DFBaseMomentModel *) item;
+(CGFloat) getHeight:(DFBaseMomentModel *) item maxWidth:(CGFloat)maxWidth;

@end
