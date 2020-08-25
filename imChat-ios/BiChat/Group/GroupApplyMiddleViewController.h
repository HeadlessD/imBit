//
//  GroupApplyMiddleViewController.h
//  BiChat
//
//  Created by imac2 on 2019/4/15.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupApplyMiddleViewController : UIViewController
{
    long long joinTime;
    NSString *source;
}

@property (nonatomic, retain) NSMutableDictionary *groupProperty;
@property (nonatomic, retain) NSString *inviterUid;
@property (nonatomic, retain) NSString *inviterNickName;
@property (nonatomic, retain) NSString *inviterAvatar;

@end

NS_ASSUME_NONNULL_END
