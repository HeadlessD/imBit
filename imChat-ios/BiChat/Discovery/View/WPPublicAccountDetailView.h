//
//  WPPublicAccountDetailView.h
//  BiChat
//
//  Created by 张迅 on 2018/4/18.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
//    单行文本，只包含标题
    DetailViewTypeNormal = 0,
//    包含标题和一个switch
    DetailViewTypeSwitch,
//    包含标题、右箭头、副标题
    DetailViewTypeDetail
    
}DetailViewType;
@interface WPPublicAccountDetailView : UIView
//view类型
@property (nonatomic,assign)DetailViewType viewType;
//标题部分
@property (nonatomic,strong)UILabel *titlelabel;
//副标题部分
//@property (nonatomic,strong)UITextField *subTF;
@property (nonatomic,strong)UILabel *subLabel;
//右侧箭头部分
@property (nonatomic,strong)UIImageView *accessoryImageView;
@property (nonatomic,strong)UIImage *accessoryImage;
//分割线部分
@property (nonatomic,strong)UIView *topLineV;
@property (nonatomic,strong)UIView *bottomLineV;
//switch
@property (nonatomic,strong)UISwitch *mySwitch;

@property (nonatomic,copy)void (^SwitchBlock)(UISwitch *mSwitch);
//添加点击事件
- (void)addTarget:(id)target selector:(SEL)selector;

@end
