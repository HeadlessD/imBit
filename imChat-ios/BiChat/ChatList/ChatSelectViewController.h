//
//  ChatSelectViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatSelectDelegate <NSObject>
@optional
- (void)chatSelected:(NSArray *)chats withCookie:(NSInteger)cookie andTarget:(id)target;
@end

typedef BOOL(^canShow)(NSString *groupId);

@interface ChatSelectViewController : UITableViewController
{
    NSMutableArray *array4ChatList;
}

@property (nonatomic, retain) NSString *defaultTitle;
@property (nonatomic, weak) id<ChatSelectDelegate>delegate;
@property (nonatomic) BOOL hidePublicAccount;
@property (nonatomic) BOOL showGroupOnly;
@property (nonatomic) BOOL showUserOnly;
@property (nonatomic) BOOL hideVirtualManageGroup;
@property (nonatomic) BOOL hideChargeGroup;
//4:分享给好友、群
@property (nonatomic) NSInteger cookie;
@property (nonatomic, retain) id target;
@property (nonatomic, assign) BOOL canPop;
@property (nonatomic) canShow canShowBlock;

@end
