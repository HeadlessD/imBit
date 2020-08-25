//
//  MessageHelper.h
//  BiChat
//
//  Created by imac2 on 2018/7/2.
//  Copyright © 2018年 worm_kc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageHelper : NSObject

//发送一条群组消息到目的地
+ (BOOL)sendGroupMessageTo:(NSString *_Nonnull)peerUid
                      type:(NSInteger)type
                   content:(NSString *_Nonnull)content
                  needSave:(BOOL)needSave
                  needSend:(BOOL)needSend
            completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;

//发送一条群组消息到群组管理员
+ (BOOL)sendGroupMessageToOperator:(NSString *_Nonnull)peerUid
                              type:(NSInteger)type
                           content:(NSString *_Nonnull)content
                          needSave:(BOOL)needSave
                          needSend:(BOOL)needSend
                    completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;

//检查是否可以发送一条消息到某群
+ (BOOL)checkCanMessageIntoGroup:(NSDictionary *_Nullable)message
                         toGroup:(NSString *_Nonnull)groupId;

//发送一条点对点消息到目的地
+ (BOOL)sendUserMessageTo:(NSString *_Nonnull)peerUid
             peerNickName:(NSString *_Nonnull)peerNickName
               peerAvatar:(NSString *_Nullable)peerAvatar
             peerUserName:(NSString *_Nullable)peerUserName
                     type:(NSInteger)type
                  content:(NSString *_Nonnull)content
                 needSave:(BOOL)needSave
                 needSend:(BOOL)needSend
           completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;

//发送一条群组消息到一个群成员
+ (BOOL)sendGroupMessageToUser:(NSString *_Nonnull)peerUid
                       groupId:(NSString *_Nonnull)groupId
                          type:(NSInteger)type
                       content:(NSString *_Nonnull)content
                      needSave:(BOOL)needSave
                      needSend:(BOOL)needSend
                completedBlock:(NetworkCompletedBlock _Nonnull)completedBlock;

@end
