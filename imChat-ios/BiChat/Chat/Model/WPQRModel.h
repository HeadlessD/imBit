//
//  WPQRModel.h
//  BiChat
//
//  Created by iMac on 2018/11/22.
//  Copyright © 2018 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPQRModel : NSObject

@property (nonatomic,strong)NSString *backgroundColor;
@property (nonatomic,strong)NSString *displayNameColor;
@property (nonatomic,strong)NSString *displayNameBackgroundColorSlide;
@property (nonatomic,strong)NSString *displayNameBackgroundColor;
@property (nonatomic,strong)NSString *QRId;
@property (nonatomic,strong)NSString *displayName;
@property (nonatomic,strong)NSString *bigImage;
@property (nonatomic,strong)NSString *smallImage;
@property (nonatomic,strong)NSString *sort;
@property (nonatomic,strong)NSString *status;
@property (nonatomic,strong)NSString *qrcodeUrl;
@property (nonatomic,assign)NSInteger width;
@property (nonatomic,assign)NSInteger height;
@property (nonatomic,strong)NSString *qrcodeUrlDescColor;

@property (nonatomic,assign)NSInteger avatarPositionX;
@property (nonatomic,assign)NSInteger avatarPositionY;
@property (nonatomic,assign)NSInteger avatarWidth;


@property (nonatomic,strong)NSString *inviteCodeColor;
@property (nonatomic,assign)NSInteger inviteCodePositionX;
@property (nonatomic,assign)NSInteger inviteCodePositionY;

@property (nonatomic,strong)NSString *nickNameColor;
@property (nonatomic,assign)NSInteger nickNamePositionX;
@property (nonatomic,assign)NSInteger nickNamePositionY;

@property (nonatomic,assign)NSInteger qrcodePositionX;
@property (nonatomic,assign)NSInteger qrcodePositionY;
@property (nonatomic,assign)NSInteger qrcodeWidth;


@end

NS_ASSUME_NONNULL_END
