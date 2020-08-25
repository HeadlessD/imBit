//
//  QuotationView.h
//  BiChat
//
//  Created by worm_kc on 2018/4/12.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuotationOperationDelegate <NSObject>
- (void)enterShowQuotationSelectionMode:(NSNumber *)quotation atTime:(NSDate *)time;
- (void)exitShowQuotationSelectionMode;
- (void)quotationSelected:(NSNumber *)quotaion atTime:(NSDate *)time;
@end


@interface QuotationView : UIView
{
    double maxQuotition;
    double minQuotition;
    
    //touch 处理
    BOOL touchMode;
    BOOL selectMode;
    CGPoint selectPoint;
}

@property (nonatomic, retain) id <QuotationOperationDelegate>delegate;
@property (nonatomic, retain) NSArray *quotationData;
@property (nonatomic) BOOL showTime;

@end
