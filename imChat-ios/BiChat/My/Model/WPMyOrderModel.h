//
//  WPMyOrderModel.h
//  BiChat
//
//  Created by iMac on 2019/1/21.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPMyOrderModel : NSObject

@property (nonatomic,strong)NSString *_id;
@property (nonatomic,strong)NSString *appid;
@property (nonatomic,strong)NSString *auto_confirm_time;
@property (nonatomic,strong)NSString *avatar;
@property (nonatomic,strong)NSString *body;
@property (nonatomic,strong)NSString *cash_fee;
@property (nonatomic,strong)NSString *cash_fee_type;
@property (nonatomic,strong)NSString *ctime;
@property (nonatomic,strong)NSString *device_info;
@property (nonatomic,strong)NSString *fee_type;
@property (nonatomic,strong)NSString *mch_id;
@property (nonatomic,strong)NSString *nickName;
@property (nonatomic,strong)NSString *nonce_str;
@property (nonatomic,strong)NSString *notify_url;
@property (nonatomic,strong)NSString *openid;
@property (nonatomic,strong)NSString *out_trade_no;
@property (nonatomic,strong)NSString *product_id;
@property (nonatomic,strong)NSString *sign;
@property (nonatomic,strong)NSString *sign_type;
@property (nonatomic,strong)NSString *spbill_create_ip;
@property (nonatomic,strong)NSString *time_end;
@property (nonatomic,strong)NSString *total_fee;
@property (nonatomic,strong)NSString *trade_state;
@property (nonatomic,strong)NSString *trade_type;
@property (nonatomic,strong)NSString *transaction_id;
@property (nonatomic,strong)NSString *transfer_type;
@property (nonatomic,strong)NSString *uId;
@property (nonatomic,strong)NSString *utime;

@end

NS_ASSUME_NONNULL_END
