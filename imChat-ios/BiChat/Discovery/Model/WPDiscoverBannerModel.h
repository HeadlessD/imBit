//
//  WPDiscoverBannerModel.h
//  BiChat
//
//  Created by iMac on 2018/12/26.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPDiscoverBannerModel : NSObject

@property (nonatomic,strong)NSString *action;
@property (nonatomic,strong)NSArray *actionContent;
@property (nonatomic,strong)NSString *ctime;
@property (nonatomic,strong)NSString *dataId;
@property (nonatomic,strong)NSString *image;
@property (nonatomic,strong)NSString *socialType;
@property (nonatomic,strong)NSString *subTitle;
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *typeName;

@end

NS_ASSUME_NONNULL_END
