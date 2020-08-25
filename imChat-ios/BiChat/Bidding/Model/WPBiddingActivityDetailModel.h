//
//  WPBiddingActivityDetailModel.h
//  BiChat
//
//  Created by iMac on 2019/2/28.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPBiddingUserlModel : NSObject

@property (nonatomic,strong)NSString *uId;
@property (nonatomic,strong)NSString *accuVolume;                   //投标次数
@property (nonatomic,strong)NSString *accuAmount;                   //投标份数
@property (nonatomic,strong)NSString *successAmount;                //中标总份数
@property (nonatomic,strong)NSString *allotVolume;                  //中标总份数
@property (nonatomic,strong)NSString *confirmOrder;                 //中标总份数
@property (nonatomic,strong)NSString *orderCount;                   //中标总份数
@property (nonatomic,assign)BOOL isSubmitKey;                       //是否提交了密钥
@property (nonatomic,strong)NSString *successOrder;                 //中标总次数


@end

@interface WPBiddingActivityDetailModel : NSObject

@property (nonatomic,strong)NSString *allotAmount;                  //
@property (nonatomic,strong)NSString *allotVolume;                  //
@property (nonatomic,strong)NSString *amount;                       //活动分配份数
@property (nonatomic,strong)NSString *batchName;                    //活动名称
@property (nonatomic,strong)NSString *batchNo;                      //活动id
@property (nonatomic,strong)NSString *bidEndTime;                   //竞价结束时间
@property (nonatomic,strong)NSString *bidPrice;                     //中标价格
@property (nonatomic,strong)NSString *bidStartTime;                 //竞价开始时间
@property (nonatomic,strong)NSString *chainEndTime;                 //订单上链结束时间
@property (nonatomic,strong)NSString *chainStartTime;               //加密数据上链开始时间
@property (nonatomic,strong)NSString *code;
@property (nonatomic,strong)NSString *coinType;                     //分配币种
@property (nonatomic,strong)NSString *castCoinType;
@property (nonatomic,strong)NSString *createTime;                   //创建时间
@property (nonatomic,strong)NSString *mess;
@property (nonatomic,strong)NSString *orderCount;                   //投标总次数
@property (nonatomic,strong)NSString *publicityEndTime;             //公示结束时间
@property (nonatomic,strong)NSString *publicityStartTime;           //公示开始时间
@property (nonatomic,strong)NSString *resultTime;                   //结果公布时间
@property (nonatomic,strong)NSString *status;                       //活动状态，0未开始，1开始公示，2等待投标，3开始投标，4等待加密数据上链，5加密数据开始上链，6加密数据正在上链，7加密数据完成上链, 8等待提交密钥，9开始提交密钥，10开始分配，11正在分配，12分配完成，13开始结果上链,14正在结果链，15结果链完成，16等待结果公布，17结果开始公布
@property (nonatomic,strong)NSString *submitEndTime;                //用户提交私钥结束时间
@property (nonatomic,strong)NSString *submitStartTime;              //用户提交私钥开始时间
@property (nonatomic,strong)NSString *totalAmount;                  //投标总额
@property (nonatomic,strong)NSString *userCount;                    //投标总人数
@property (nonatomic,strong)NSString *userMaxAmount;                //用户最大可投标份数
@property (nonatomic,strong)NSString *userMaxCoinTypePercentage;    //用户最大可使用持币百分比

@property (nonatomic,strong)NSString *maxBidOrderCount;             //每人有效竞价最大单数
@property (nonatomic,strong)NSDictionary *exchange;                 //汇率

@property (nonatomic,strong)NSString *confirmCount;                 //确认投标数
@property (nonatomic,strong)NSString *confirmUser;                  //确认投标人数
@property (nonatomic,strong)NSString *winningAmount;                //中标总份数
@property (nonatomic,strong)NSString *winningUser;                  //中标总人数
@property (nonatomic,strong)NSString *winningOrder;                 //中标总次数

@property (nonatomic,strong)NSString *volume;                       //分配数量
@property (nonatomic,strong)NSString *userVolume;
@property (nonatomic,strong)NSString *groupVolume;
@property (nonatomic,strong)NSString *nodeVolume;                      
@property (nonatomic,strong)NSString *developerVolume;
@property (nonatomic,strong)WPBiddingUserlModel *userSummary;


@property (nonatomic,strong)NSString *allotVolumeStr;


@end



