//
//  AddFriendFromLocalContactViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/21.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AddMemoViewController.h"

@interface AddFriendFromLocalContactViewController : UITableViewController<UITextFieldDelegate, MFMessageComposeViewControllerDelegate, addFriendDelegate>
{
    //界面相关
    UIView *view4SearchPanel;
    UITextField *input4Search;
    NSString *str4SearchKey;
    UIView *view4SearchFrame;
    UIButton *button4CancelSearch;
    
    //所有本地通讯录内容
    NSInteger allContactCount;
    NSMutableArray *array4Contact;
    
    //本地通讯录中已经在imChat系统中注册过的信息
    NSMutableArray *array4CanAddFriend;
    NSMutableArray *array4ContactInImChatSystem;
}

@end
