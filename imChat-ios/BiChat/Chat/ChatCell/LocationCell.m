//
//  LocationCell.m
//  BiChat
//
//  Created by imac2 on 2019/1/23.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import "LocationCell.h"
#import "JSONKit.h"

@implementation LocationCell

+ (CGFloat)getCellHeight:(NSDictionary *)message
                 peerUid:(NSString *)peerUid
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
{
    if (![[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid] && showNickName)
        return 170;
    else
        return 150;
}

+ (void)renderCellInView:(UIView *)contentView
                 peerUid:(NSString *)peerUid
                 message:(NSMutableDictionary *)message
                   width:(CGFloat)cellWidth
            showNickName:(BOOL)showNickName
       inMultiSelectMode:(BOOL)inMultiSelectMode
               indexPath:(NSIndexPath *)indexPath
         longPressTarget:(id)longPressTarget
         longPressAction:(SEL)longPressAction
               tapTarget:(id)tapTarget
               tapAction:(SEL)tapAction
     tapUserAvatarTarget:(id)tapUserAvatarTarget
     tapUserAvatarAction:(SEL)tapUserAvatarAction
longPressUserAvatarTarget:(id)longPressUserAvatarTarget
longPressUserAvatarAction:(SEL)longPressUserAvatarAction
            remarkTarget:(id)remarkTarget
            remarkAction:(SEL)remarkAction
            resendTarget:(id)resendTarget
            resendAction:(SEL)resendAction
{
    //解析名片内容
    JSONDecoder *dec = [JSONDecoder new];
    NSDictionary *locationInfo = [dec objectWithData:[[message objectForKey:@"content"]dataUsingEncoding:NSUTF8StringEncoding]];
    
    //是否自己发言
    NSMutableDictionary *groupProperty = [[BiChatDataModule sharedDataModule]getGroupProperty:peerUid];
    if ([[message objectForKey:@"sender"]isEqualToString:[BiChatGlobal sharedManager].uid])
    {
        //头像
        UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[BiChatGlobal sharedManager].uid nickName:[BiChatGlobal sharedManager].nickName avatar:[BiChatGlobal sharedManager].avatar frame:CGRectMake(cellWidth - 50, 0, 40, 40)];
        [self bundleView:view4Avatar
                WithUser:[message objectForKey:@"sender"]
                userName:[message objectForKey:@"senderUserName"]
                nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                  avatar:[message objectForKey:@"senderAvatar"]
                isPublic:[[message objectForKey:@"isPublic"]boolValue]
               tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
         longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
        [contentView addSubview:view4Avatar];
        
        //内容框
        UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(cellWidth - 290,
                                                                                       0,
                                                                                       235,
                                                                                       140)];
        image4ContentFrame.image = [UIImage imageNamed:@"bubbleMine_light"];
        [contentView addSubview:image4ContentFrame];
        
        if (!inMultiSelectMode)
        {
            //给图片增加长按手势
            image4ContentFrame.userInteractionEnabled = YES;
            UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
            objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4ContentFrame addGestureRecognizer:longPressGest];
            
            //给图片增加轻点手势
            UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
            objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
            [image4ContentFrame addGestureRecognizer:tapGest];
            
            //是否发送成功
            if ([[BiChatDataModule sharedDataModule]isMessageUnSent:[message objectForKey:@"msgId"]])
            {
                UIButton *button4Resend = [[UIButton alloc]initWithFrame:CGRectMake(cellWidth - 335, 50, 40, 40)];
                [button4Resend setImage:[UIImage imageNamed:@"failure"] forState:UIControlStateNormal];
                [button4Resend addTarget:resendTarget action:resendAction forControlEvents:UIControlEventTouchUpInside];
                objc_setAssociatedObject(button4Resend, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4Resend, @"targetView", contentView, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(button4Resend, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [contentView addSubview:button4Resend];
            }
        }
        
        //内容
        //Name
        UILabel *label4LocationName = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 280, 10, 210, 18)];
        label4LocationName.text = [locationInfo objectForKey:@"name"];
        label4LocationName.font = [UIFont systemFontOfSize:16];
        [contentView addSubview:label4LocationName];
        
        //Address
        UILabel *label4LocationAddress = [[UILabel alloc]initWithFrame:CGRectMake(cellWidth - 280, 28, 210, 16)];
        label4LocationAddress.text = [locationInfo objectForKey:@"address"];
        label4LocationAddress.font = [UIFont systemFontOfSize:12];
        label4LocationAddress.textColor = [UIColor grayColor];
        [contentView addSubview:label4LocationAddress];
        
        //container
        UIView *view4MapContainer = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 289.5, 0.5, 229.5, 139)];
        view4MapContainer.layer.cornerRadius = 5;
        view4MapContainer.clipsToBounds = YES;
        view4MapContainer.userInteractionEnabled = NO;
        [contentView addSubview:view4MapContainer];
        
        //MAMapView *mapView = [self createMapView:CGRectMake(0, 50, 229.5, 90) locationInfo:locationInfo];
        //[view4MapContainer addSubview:mapView];
        UIImageView *image4Map = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 229.5, 90)];
        [image4Map sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [locationInfo objectForKey:@"image"]]]];
        image4Map.contentMode = UIViewContentModeScaleAspectFill;
        image4Map.clipsToBounds = YES;
        [view4MapContainer addSubview:image4Map];
    }
    else
    {
        if (inMultiSelectMode)  //是多重选择模式
        {
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[message objectForKey:@"sender"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                                                      avatar:[message objectForKey:@"senderAvatar"]
                                                       width:40 height:40];
            view4Avatar.center = CGPointMake(70, 20);
            [self bundleView:view4Avatar
                    WithUser:[message objectForKey:@"sender"]
                    userName:[message objectForKey:@"senderUserName"]
                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                      avatar:[message objectForKey:@"senderAvatar"]
                    isPublic:[[message objectForKey:@"isPublic"]boolValue]
                   tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
             longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
            [contentView addSubview:view4Avatar];
            
            if (showNickName)
            {
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(100, 0, cellWidth - 150, 20)];
                label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95,
                                                                                               20,
                                                                                               235,
                                                                                               140)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //内容
                //Name
                UILabel *label4LocationName = [[UILabel alloc]initWithFrame:CGRectMake(110, 30, 210, 18)];
                label4LocationName.text = [locationInfo objectForKey:@"name"];
                label4LocationName.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4LocationName];
                
                //Address
                UILabel *label4LocationAddress = [[UILabel alloc]initWithFrame:CGRectMake(110, 48, 210, 16)];
                label4LocationAddress.text = [locationInfo objectForKey:@"address"];
                label4LocationAddress.font = [UIFont systemFontOfSize:12];
                label4LocationAddress.textColor = [UIColor grayColor];
                [contentView addSubview:label4LocationAddress];
                
                //container
                UIView *view4MapContainer = [[UIView alloc]initWithFrame:CGRectMake(100, 20.5, 229.5, 139)];
                view4MapContainer.layer.cornerRadius = 5;
                view4MapContainer.clipsToBounds = YES;
                view4MapContainer.userInteractionEnabled = NO;
                [contentView addSubview:view4MapContainer];
                
                //MAMapView *mapView = [self createMapView:CGRectMake(0, 50, 229.5, 90) locationInfo:locationInfo];
                //[view4MapContainer addSubview:mapView];
                UIImageView *image4Map = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 229.5, 90)];
                [image4Map sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [locationInfo objectForKey:@"image"]]]];
                image4Map.contentMode = UIViewContentModeScaleAspectFill;
                image4Map.clipsToBounds = YES;
                [view4MapContainer addSubview:image4Map];
            }
            else
            {
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(95,
                                                                                               0,
                                                                                               235,
                                                                                               140)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //内容
                //Name
                UILabel *label4LocationName = [[UILabel alloc]initWithFrame:CGRectMake(110, 10, 210, 18)];
                label4LocationName.text = [locationInfo objectForKey:@"name"];
                label4LocationName.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4LocationName];
                
                //Address
                UILabel *label4LocationAddress = [[UILabel alloc]initWithFrame:CGRectMake(110, 28, 210, 16)];
                label4LocationAddress.text = [locationInfo objectForKey:@"address"];
                label4LocationAddress.font = [UIFont systemFontOfSize:12];
                label4LocationAddress.textColor = [UIColor grayColor];
                [contentView addSubview:label4LocationAddress];
                
                //container
                UIView *view4MapContainer = [[UIView alloc]initWithFrame:CGRectMake(100, 0.5, 229.5, 139)];
                view4MapContainer.layer.cornerRadius = 5;
                view4MapContainer.clipsToBounds = YES;
                view4MapContainer.userInteractionEnabled = NO;
                [contentView addSubview:view4MapContainer];
                
                //MAMapView *mapView = [self createMapView:CGRectMake(0, 50, 229.5, 90) locationInfo:locationInfo];
                //[view4MapContainer addSubview:mapView];
                UIImageView *image4Map = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 229.5, 90)];
                [image4Map sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [locationInfo objectForKey:@"image"]]]];
                image4Map.contentMode = UIViewContentModeScaleAspectFill;
                image4Map.clipsToBounds = YES;
                [view4MapContainer addSubview:image4Map];
            }
        }
        else
        {
            //头像
            UIView *view4Avatar = [BiChatGlobal getAvatarWnd:[message objectForKey:@"sender"]
                                                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                                                      avatar:[message objectForKey:@"senderAvatar"]
                                                       width:40 height:40];
            view4Avatar.center = CGPointMake(30, 20);
            [self bundleView:view4Avatar
                    WithUser:[message objectForKey:@"sender"]
                    userName:[message objectForKey:@"senderUserName"]
                    nickName:[[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]]
                      avatar:[message objectForKey:@"senderAvatar"]
                    isPublic:[[message objectForKey:@"isPublic"]boolValue]
                   tapTarget:tapUserAvatarTarget tapAction:tapUserAvatarAction
             longPressTarget:longPressUserAvatarTarget longPressAction:longPressUserAvatarAction];
            [contentView addSubview:view4Avatar];
            
            if (showNickName)
            {
                UILabel *label4NickName = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, cellWidth - 150, 20)];
                label4NickName.text = [[BiChatGlobal sharedManager]adjustFriendNickName4Display:[message objectForKey:@"sender"] groupProperty:groupProperty nickName:[message objectForKey:@"senderNickName"]];
                label4NickName.font = [UIFont systemFontOfSize:12];
                label4NickName.textColor = [UIColor grayColor];
                [contentView addSubview:label4NickName];
                
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55,
                                                                                               20,
                                                                                               235,
                                                                                               140)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //给图片增加长按手势
                image4ContentFrame.userInteractionEnabled = YES;
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:longPressGest];
                
                //给图片增加轻点手势
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
                objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:tapGest];
                
                //内容
                //Name
                UILabel *label4LocationName = [[UILabel alloc]initWithFrame:CGRectMake(70, 30, 210, 18)];
                label4LocationName.text = [locationInfo objectForKey:@"name"];
                label4LocationName.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4LocationName];
                
                //Address
                UILabel *label4LocationAddress = [[UILabel alloc]initWithFrame:CGRectMake(70, 48, 210, 16)];
                label4LocationAddress.text = [locationInfo objectForKey:@"address"];
                label4LocationAddress.font = [UIFont systemFontOfSize:12];
                label4LocationAddress.textColor = [UIColor grayColor];
                [contentView addSubview:label4LocationAddress];
                
                //container
                UIView *view4MapContainer = [[UIView alloc]initWithFrame:CGRectMake(60, 20.5, 229.5, 139)];
                view4MapContainer.layer.cornerRadius = 5;
                view4MapContainer.clipsToBounds = YES;
                view4MapContainer.userInteractionEnabled = NO;
                [contentView addSubview:view4MapContainer];
                
                //MAMapView *mapView = [self createMapView:CGRectMake(0, 50, 229.5, 90) locationInfo:locationInfo];
                //[view4MapContainer addSubview:mapView];
                UIImageView *image4Map = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 229.5, 90)];
                [image4Map sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [locationInfo objectForKey:@"image"]]]];
                image4Map.contentMode = UIViewContentModeScaleAspectFill;
                image4Map.clipsToBounds = YES;
                [view4MapContainer addSubview:image4Map];
            }
            else
            {
                //内容框
                UIImageView *image4ContentFrame = [[UIImageView alloc]initWithFrame:CGRectMake(55,
                                                                                               0,
                                                                                               235,
                                                                                               140)];
                image4ContentFrame.image = [UIImage imageNamed:@"bubbleSomeone"];
                [contentView addSubview:image4ContentFrame];
                
                //给图片增加长按手势
                image4ContentFrame.userInteractionEnabled = YES;
                UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:longPressTarget action:longPressAction];
                objc_setAssociatedObject(longPressGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(longPressGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:longPressGest];
                
                //给图片增加轻点手势
                UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:tapTarget action:tapAction];
                objc_setAssociatedObject(tapGest, @"indexPath", indexPath, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetView", image4ContentFrame, OBJC_ASSOCIATION_ASSIGN);
                objc_setAssociatedObject(tapGest, @"targetData", message, OBJC_ASSOCIATION_ASSIGN);
                [image4ContentFrame addGestureRecognizer:tapGest];
                
                //内容
                //Name
                UILabel *label4LocationName = [[UILabel alloc]initWithFrame:CGRectMake(70, 10, 210, 18)];
                label4LocationName.text = [locationInfo objectForKey:@"name"];
                label4LocationName.font = [UIFont systemFontOfSize:16];
                [contentView addSubview:label4LocationName];
                
                //Address
                UILabel *label4LocationAddress = [[UILabel alloc]initWithFrame:CGRectMake(70, 28, 210, 16)];
                label4LocationAddress.text = [locationInfo objectForKey:@"address"];
                label4LocationAddress.font = [UIFont systemFontOfSize:12];
                label4LocationAddress.textColor = [UIColor grayColor];
                [contentView addSubview:label4LocationAddress];
                
                //container
                UIView *view4MapContainer = [[UIView alloc]initWithFrame:CGRectMake(60, 0.5, 229.5, 139)];
                view4MapContainer.layer.cornerRadius = 5;
                view4MapContainer.clipsToBounds = YES;
                view4MapContainer.userInteractionEnabled = NO;
                [contentView addSubview:view4MapContainer];
                
                //MAMapView *mapView = [self createMapView:CGRectMake(0, 50, 229.5, 90) locationInfo:locationInfo];
                //[view4MapContainer addSubview:mapView];
                UIImageView *image4Map = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 229.5, 90)];
                [image4Map sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [BiChatGlobal sharedManager].S3URL, [locationInfo objectForKey:@"image"]]]];
                image4Map.contentMode = UIViewContentModeScaleAspectFill;
                image4Map.clipsToBounds = YES;
                [view4MapContainer addSubview:image4Map];
            }
        }
    }
}

+ (MAMapView *)createMapView:(CGRect)frame locationInfo:(NSDictionary *)locationInfo
{
    MAMapView *mapView = [[MAMapView alloc] initWithFrame:frame];
    mapView.mapType = MAMapTypeStandard;
    mapView.showsScale = NO;
    mapView.showsCompass = NO;
    mapView.showsUserLocation = NO;
    mapView.scrollEnabled = NO;
    mapView.zoomEnabled = NO;
    mapView.backgroundColor = DFCOLOR_Arc;
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    CGFloat lolongitude;
    CGFloat lolatitude;
    lolongitude = [[locationInfo objectForKey:@"longitude"]floatValue];
    lolatitude = [[locationInfo objectForKey:@"latitude"]floatValue];
    
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(lolatitude,lolongitude);
    pointAnnotation.title = [locationInfo objectForKey:@"name"];
    pointAnnotation.subtitle = [locationInfo objectForKey:@"address"];
    NSMutableArray * locaArr = [NSMutableArray array];
    [locaArr addObject:pointAnnotation];
    [mapView addAnnotation:pointAnnotation];
    [mapView showAnnotations:locaArr animated:YES];
    [mapView setZoomLevel:14];
    
    return mapView;
}

@end
