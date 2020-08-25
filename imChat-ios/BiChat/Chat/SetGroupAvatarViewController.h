//
//  SetGroupAvatarViewController.h
//  BiChat
//
//  Created by worm_kc on 2018/3/25.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetGroupAvatarViewController : UITableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImage *image4CurrentSelectedAvatar_Big;
    UIImage *image4CurrentSelectedAvatar;
    
    //显示头像
    UIImage *image4CurrentAvatar;
    UIImageView *image4ShowAvatar;
    UIButton *button4LocalSave;
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end
