//
//  VirtualGroupAssistAdminViewController.h
//  BiChat Dev
//
//  Created by imac2 on 2018/11/22.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VirtualGroupAssistAdminViewController : UITableViewController<ContactSelectDelegate>
{
    
}

@property (nonatomic, retain) NSString *groupId;
@property (nonatomic, retain) NSMutableDictionary *groupProperty;

@end

NS_ASSUME_NONNULL_END
