//
//  DFShareNewsView.h
//  BiChat Dev
//
//  Created by chat on 2018/9/28.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DFShareNewsViewDelegate <NSObject>
@required
-(void)shareNewsClickWithModel;
@end


@interface DFShareNewsView : UIView

@property (nonatomic, weak) id<DFShareNewsViewDelegate> delegate;

@property (nonatomic, strong) UIImageView * shareView;
@property (nonatomic, strong) UIImageView * shareImgView;
@property (nonatomic, strong) UILabel * shareLabel;

@end
