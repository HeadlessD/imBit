//
//  DFPublicBaseViewController.h
//  DFTimelineView
//
//  Created by 豆凯强 on 17/10/15.
//  Copyright (c) 2017年 Datafans, Inc. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "DFBaseViewController.h"


@interface DFPublicBaseViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView * mewMomentMessageView;

@property (nonatomic, strong) UIButton * rightButton;

@property (nonatomic, assign) NSUInteger coverWidth;
@property (nonatomic, assign) NSUInteger coverHeight;
@property (nonatomic, assign) NSUInteger userAvatarSize;

//-(void)loadNewData;
-(void)endLoadNew;

//-(void)loadMoreData;
-(void)endLoadMore;

//点击封面上的用户头像
//-(void) onClickHeaderUserAvatar;

//设置封面
-(void)setOwnCover:(NSString *)url;
-(void)setOtherCover:(NSString *)url;
-(void)setCoverWithImage:(UIImage *)img;

//设置封面上的用户头像
-(void) setUserAvatar:(NSString *) url withName:(NSString *)userName;

//设置封面上的昵称
-(void) setUserNick:(NSString *)nick;

//设置用户签名
-(void) setUserSign:(NSString *)sign;

@end
