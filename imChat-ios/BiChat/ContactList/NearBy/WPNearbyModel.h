//
//  WPNearbyModel.h
//  BiChat
//
//  Created by iMac on 2018/11/7.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPNearbyModel : NSObject

@property (nonatomic,strong)NSString *avatar;
@property (nonatomic,strong)NSString *createdTime;
@property (nonatomic,strong)NSString *distance;
@property (nonatomic,strong)NSString *gender;
@property (nonatomic,strong)NSString *latitude;
@property (nonatomic,strong)NSString *longitude;
@property (nonatomic,strong)NSString *nickName;
@property (nonatomic,strong)NSString *uid;
@property (nonatomic,strong)NSString *sign;

@end

NS_ASSUME_NONNULL_END
