//
//  AddMemoViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/2/27.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol addFriendDelegate <NSObject>
- (void)addFriendSucess:(NSString *)mobile;
@end


@interface AddMemoViewController : UIViewController
{
    UITextField *input4Memo;
}

@property (nonatomic, weak) id<addFriendDelegate> delegate;
@property (nonatomic) BOOL canCancel;
@property (nonatomic, retain) NSString *userMobile;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, retain) NSString *source;

@end
