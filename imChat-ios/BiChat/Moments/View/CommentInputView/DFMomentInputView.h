//
//  DFMomentInputView.h
//  BiChat Dev
//
//  Created by chat on 2018/9/3.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DFMomentInputViewDelegate <NSObject>
@required
-(void) sendCommentWithReReplyIdOne:(Commentuser *)replyUser momentModel:(DFBaseMomentModel *)momentModel text:(NSString *) text;
@end

@interface DFMomentInputView : UIView

@property (nonatomic, weak) id<DFMomentInputViewDelegate> delegate;
@property (nonatomic, strong) Commentuser * replyUser;
@property (nonatomic, copy) NSString * momentId;
@property (nonatomic, strong) DFBaseMomentModel * momentModel;


-(void)setPlaceHolder:(NSString *)text;

-(void)setReturn:(NSString *)text;

-(void)momentInputViewShow;

@end
