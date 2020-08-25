//
//  WPBiddingHistoryModel.h
//  BiChat
//
//  Created by iMac on 2019/3/20.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WPBiddingHistoryModel : NSObject

@property (nonatomic,strong)NSString *batchName;                        //活动名称
@property (nonatomic,strong)NSString *coinType;                         //分配币类型
@property (nonatomic,strong)NSString *resultTime;                       //结果公布时间
@property (nonatomic,strong)NSString *submitStartTime;                  //提交密钥开始时间
@property (nonatomic,strong)NSString *userMaxAmount;                    //用户最大可投标份数
@property (nonatomic,strong)NSString *batchNo;                          //批次名
@property (nonatomic,strong)NSString *amount;                           //分配份数
@property (nonatomic,strong)NSString *orderCount;                       //下单数
@property (nonatomic,strong)NSString *allotAmount;
@property (nonatomic,strong)NSString *chainEndTime;                     //加密数据上链结束时间
@property (nonatomic,strong)NSString *bidPrice;
@property (nonatomic,strong)NSString *userMaxCoinTypePercentage;        //用户最大可使用持币百分比
@property (nonatomic,strong)NSString *volume;                           //分配总额
@property (nonatomic,strong)NSString *totalAmount;                      //投标总数
@property (nonatomic,strong)NSString *publicityEndTime;                 //公示结束时间
@property (nonatomic,strong)NSString *submitEndTime;                    //提交密钥结束时间
@property (nonatomic,strong)NSString *bidStartTime;                     //竞价开始时间
@property (nonatomic,strong)NSString *userCount;                        //投票用户
@property (nonatomic,strong)NSString *createTime;                       //创建时间
@property (nonatomic,strong)NSString *publicityStartTime;               //公示开始时间
@property (nonatomic,strong)NSString *bidEndTime;                       //竞价结束时间
@property (nonatomic,strong)NSString *chainStartTime;                   //加密数据上链开始时间
@property (nonatomic,strong)NSString *status;

@property (nonatomic,strong)NSString *castCoinType;
@property (nonatomic,strong)NSString *maxBidOrderCount;
@property (nonatomic,strong)NSString *winningOrderCount;
@property (nonatomic,strong)NSString *winningTotalAmount;
@property (nonatomic,strong)NSString *winningUserCount;


@end
