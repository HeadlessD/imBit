//
//  DFImagesSendViewController.h
//  DFTimelineView
//
//  Created by 豆凯强 on 16/2/15.
//  Copyright © 2016年 Datafans, Inc. All rights reserved.
//

#import "DFBaseMomentModel.h"
#import "DFBaseViewController.h"

@protocol DFImagesSendViewControllerDelegate <NSObject>
@optional
-(void)sendMomentWithText:(NSString *)text images:(NSArray *)images videoUrl:(NSString *)videoUrl videoImg:(UIImage *)videoImg location:(AMapPOI *)location;
@end

@interface DFImagesSendViewController : DFBaseViewController

@property (nonatomic, weak) id<DFImagesSendViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary * sendNewsDic;

@property (nonatomic, strong) NSArray * sendImagesArr;

@property (nonatomic, copy) NSString * sendVideoUrl;
@property (nonatomic, copy) UIImage * sendVideoImg;

@end
