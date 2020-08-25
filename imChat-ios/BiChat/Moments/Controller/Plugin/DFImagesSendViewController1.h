//
//  DFImagesSendViewController1.h
//  DFTimelineView
//
//  Created by 豆凯强 on 16/2/15.
//  Copyright © 2016年 Datafans, Inc. All rights reserved.
//

//#import <DFCommon/DFCommon.h>
#import "DFBaseMomentModel.h"
#import "DFBaseViewController.h"

@protocol DFImagesSendViewController1Delegate <NSObject>
@optional
-(void) onSendTextImage:(NSString *) text images:(NSArray *)images;
@end

@interface DFImagesSendViewController1 : DFBaseViewController

@property (nonatomic, weak) id<DFImagesSendViewController1Delegate> delegate;

@property (nonatomic, strong) NSDictionary * shareDic;
@property (nonatomic, strong) NSArray * outImages;

//- (instancetype)initWithImages:(NSArray *) images;

@end
