//
//  WPCoinDetailModel.h
//  BiChat
//
//  Created by iMac on 2018/8/1.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPCoinDetailModel : NSObject
//流通量
@property (nonatomic,assign)NSInteger circulationTotal;
@property (nonatomic,assign)NSInteger code;
//描述
@property (nonatomic,strong)NSString *desc;
@property (nonatomic,assign)NSInteger exchangeBtcAmount;
//全网均价
@property (nonatomic,assign)double exchangeUsdAmount;
//市值排名
@property (nonatomic,assign)NSInteger position;
//网站
@property (nonatomic,strong)NSArray *sites;
//发行时间
@property (nonatomic,assign)NSInteger time;
//总发行量
@property (nonatomic,assign)NSInteger total;
//流通市值
@property (nonatomic,assign)NSInteger totalUsdAmount;
//币图标
@property (nonatomic,strong)NSString *imgColor;
//中+英文 名
@property (nonatomic,strong)NSArray *name;
//24小时成交额
@property (nonatomic,assign)NSInteger turnover_24;
//24小时成交量
@property (nonatomic,assign)NSInteger volume_24;
//上架交易所数量
@property (nonatomic,assign)NSInteger tickerNum;
//白皮书地址
@property (nonatomic,strong)NSString *whitePaper;

@end
