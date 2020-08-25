//
//  WPRedPacketSendCoinModel.h
//  BiChat
//
//  Created by 张迅 on 2018/5/8.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPRedPacketSendCoinModel : NSObject

@property (nonatomic,strong)NSString *symbol;
@property (nonatomic,strong)NSString *amount;
@property (nonatomic,strong)NSString *code;
@property (nonatomic,strong)NSString *imgWhite;
@property (nonatomic,strong)NSString *imgWechat;
@property (nonatomic,strong)NSString *imgGold;
@property (nonatomic,strong)NSString *sort;
@property (nonatomic,strong)NSString *bit;
@property (nonatomic,strong)NSString *dSymbol;
@property (nonatomic,strong)NSString *imgColor;
@property (nonatomic,strong)NSArray *name;


//bit = 4;
//code = 100002;
//dSymbol = ETH;
//imgColor = "token/eth/eth_color.png";
//imgGold = "token/eth/eth_gold.png";
//imgWechat = "token/eth/eth_wechat.png";
//imgWhite = "token/eth/eth_white.png";
//name =             (
//                    "\U4ee5\U592a\U574a",
//                    Ethereum
//                    );
//price = "478.43";
//"price_time" = 1530605906143;
//sort = 2;
//source = 1;
//symbol = ETH;

@end
