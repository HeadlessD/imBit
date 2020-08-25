//
//  WPDiscoverBannerView.h
//  BiChat
//
//  Created by iMac on 2019/2/19.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface WPDiscoverBannerView : UIView <UIScrollViewDelegate>

@property (nonatomic,strong)NSArray *listArray;
@property (nonatomic,strong)NSArray *resetListArray;

@property (nonatomic,strong)UIScrollView *scrollV;

@property (nonatomic,strong)UIView *backView;

@property (nonatomic,copy)void (^TapBlock)(NSInteger index);

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
