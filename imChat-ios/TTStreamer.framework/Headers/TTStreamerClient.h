//
//  PokerStream.h
//  PokerStream
//
//  Created by Apple on 5/6/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#define streamer_version 2.0

#import <UIKit/UIKit.h>

//! Project version number for PokerStream.
FOUNDATION_EXPORT double PokerStreamVersionNumber;

//! Project version string for PokerStream.
FOUNDATION_EXPORT const unsigned char PokerStreamVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PokerStream/PublicHeader.h>

typedef enum
{
    STREAM_PIPE_OK          = 200,
    STREAM_PIPE_CONNECTING  = 300,
    STREAM_PIPE_HALF        = 400,
    STREAM_PIPE_BROKEN      = 500,
    STREAM_PIPE_NONE        = 600,
    STREAM_BAD_TOKEN        = 700 //TODO
} streamStateCode;

typedef void(^RequestCompletedBlock)(NSData * _Nullable data, Boolean isTimeOut);

@protocol TTStreamingDelegate <NSObject>

@required

- (void)onTextData:(NSString * _Nonnull)text;

- (void)onBinaryData:(NSData * _Nonnull)data;

- (void)onPipeState:(streamStateCode)state;

- (void)onBadToken;

@optional

//type = 1, tcp packets
//type = 2, one full data frame
//type = other, not defined
- (void)onLogData:(NSData * _Nonnull)logData type:(int)type;

@end


@interface PokerStreamClient : NSObject

+(void)init:(NSArray *_Nonnull)servers port:(int)port delegate:(id<TTStreamingDelegate> _Nonnull) delegate;

//by default, it's off;
//ture to turn on, false to turn off
+(void)turnStreamingOnOff:(Boolean)on;

+(Boolean)send:(NSString * _Nullable)token text:(NSString *_Nonnull)text;

+(Boolean)send:(NSString * _Nullable)token binary:(NSData *_Nonnull)data;

+(Boolean)sendRequest:(NSString * _Nullable)token binary:data completed:(RequestCompletedBlock _Nonnull )completedBlock;

+(Boolean)disconect;

+(void)enableDebug;

@end
