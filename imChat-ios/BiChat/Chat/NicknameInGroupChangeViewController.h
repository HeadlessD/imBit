//
//  NickNameInGroupChangeViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/9.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NickNameInGroupChangeViewController : UIViewController<UITextFieldDelegate>
{
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end
