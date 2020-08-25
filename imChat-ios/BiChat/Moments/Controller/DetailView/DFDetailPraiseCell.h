//
//  DFDetailPraiseCell.h
//  BiChat Dev
//
//  Created by chat on 2018/9/4.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DFDetailPraiseCellDelegate <NSObject>
-(void)clickPraiseCellOnDFDetailPraiseCellWithId:(NSString *)userId;
@end

@interface DFDetailPraiseCell : UITableViewCell

@property (nonatomic,weak) id<DFDetailPraiseCellDelegate> delegate;

@property (nonatomic,strong) UIImageView * backView;
@property (nonatomic,strong) UIImageView * praiseView;

+(CGFloat)getCollectionHeightWithModel:(DFBaseMomentModel *)model;
-(void)updatePraiseWithModel:(DFBaseMomentModel*)momentModel;

@end
