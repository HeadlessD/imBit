//
//  MyWeChatBindingViewController.h
//  BiChat
//
//  Created by Admin on 2018/3/30.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyWeChatBindingViewController : UITableViewController<WeChatBindingNotify>
{
    NSMutableArray *array4WeChatBinding;
}

- (void)freshGUI;

@end
