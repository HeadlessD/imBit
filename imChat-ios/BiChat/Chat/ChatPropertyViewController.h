//
//  ChatPropertyViewController.h
//  BiChat
//
//  Created by Admin on 2018/4/20.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactListViewController.h"

@interface ChatPropertyViewController : UITableViewController<ContactSelectDelegate>

@property (nonatomic, retain) NSString *peerUid;
@property (nonatomic, retain) NSString *peerAvatar;
@property (nonatomic, retain) NSString *peerNickName;
@property (nonatomic, retain) NSString *peerUserName;

@end
