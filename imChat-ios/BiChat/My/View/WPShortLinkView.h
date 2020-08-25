//
//  WPShortLinkView.h
//  BiChat
//
//  Created by iMac on 2019/5/6.
//  Copyright © 2019 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WPShortLinkView : UIView

@property (nonatomic,strong)UIView *backView;

@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *subTitleLabel;
@property (nonatomic,strong)UIImageView *senderIV;
@property (nonatomic,strong)UIImageView *headIV;
@property (nonatomic,strong)UIImageView *payIV;
@property (nonatomic,strong)UIImageView *typeIV;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *countLabel;
@property (nonatomic,strong)UITextView *desTV;
@property (nonatomic,strong)UIButton *functionButton;

@property (nonatomic,strong)NSString *type;
@property (nonatomic,strong)NSDictionary *data;
@property (nonatomic,strong)NSDictionary *groupProperty;
@property (nonatomic,strong)NSDictionary *urlData;
@property (nonatomic,assign)BOOL inGroup;

@property (nonatomic,copy)void (^CloseBlock)(void);
@property (nonatomic,copy)void (^OpenBlock)(UIViewController *vc);

@property (nonatomic,strong)NSString *joinGorupId;
@property (nonatomic,strong)NSDictionary *groupHome;

- (void)show;
- (void)fillData:(NSDictionary *)data type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
