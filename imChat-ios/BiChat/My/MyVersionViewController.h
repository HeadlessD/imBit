//
//  MyVersionViewController.h
//  BiChat Dev
//
//  Created by imac2 on 2018/11/12.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyVersionViewController : UITableViewController<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

NS_ASSUME_NONNULL_END
