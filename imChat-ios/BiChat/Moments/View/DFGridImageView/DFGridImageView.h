//
//  DFGridImageView.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/9/27.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DFGridImageViewDelegate <NSObject>

-(void)clickImgOnDFGridImageViewWithThumbImgArr:(NSArray *)thumbImgArr displayImgArr:(NSArray *)displayImgArr withTag:(NSInteger)tag;

@end


@interface DFGridImageView : UIView

@property (nonatomic , weak) id <DFGridImageViewDelegate> delegate;

@property (nonatomic , copy) void (^saveBlock)(void);

-(void) updateWithImagesForBaseModel:(DFBaseMomentModel *)baseModel;

+(CGFloat) gridGetHeight:(NSMutableArray *) images maxWidth:(CGFloat)maxWidth withModel:(DFBaseMomentModel *)bmModel;

-(NSInteger) getIndexFromPoint: (CGPoint) point;

@end
