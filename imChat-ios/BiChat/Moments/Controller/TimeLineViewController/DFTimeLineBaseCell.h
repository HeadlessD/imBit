//
//  DFTimeLineBaseCell.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/10/15.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "DFBaseMomentModel.h"
#import "UIImageView+WebCache.h"

@protocol DFTimeLineBaseCellDelegate <NSObject>
@required
-(void) onClickItem:(DFBaseMomentModel *) item;
@end


@interface DFTimeLineBaseCell : UITableViewCell

@property (nonatomic, weak) id<DFTimeLineBaseCellDelegate> delegate;
@property (nonatomic, strong) UIButton *bodyView;

-(void) updateWithItem:(DFBaseMomentModel *) item;
-(CGFloat) getCellHeight:(DFBaseMomentModel *) item;
-(void) updateBodyWithHeight:(CGFloat)height;

@end
