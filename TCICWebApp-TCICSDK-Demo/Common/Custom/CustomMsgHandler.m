//
//  CustomMsgHandler.m
//  TYICWebApp
//
//  Created by 陈耀武 on 2021/1/22.
//  Copyright © 2021 陈耀武. All rights reserved.
//

#import "CustomMsgHandler.h"
#import <YYModel/YYModel.h>

@interface CustomMsgHandler ()
#if kSelfImplementTCICCustomMsg
@property (nonatomic, strong) NSPointerArray *customChannelArray;
#endif
@end

@implementation CustomMsgHandler


- (instancetype)init {
    if (self = [super init]) {
#if kSelfImplementTCICCustomMsg
        self.customChannelArray = [NSPointerArray weakObjectsPointerArray];
#endif
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRenderViewSendMsg:) name:@"RenderViewSendMsg" object:nil];
    }
    return self;
}

- (void)dealloc
{
#if kSelfImplementTCICCustomMsg
    self.customChannelArray = nil;
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)onRenderViewSendMsg:(NSNotification *)notify {
    NSString *msg = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendCustomMsg:msg];
    });
}

- (void)safeRunInMain:(void (^)(CustomMsgHandler *mgr))block {
    if (block) {
        if ([NSThread isMainThread]) {
            block(self);
        } else {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf == nil) {
                    return;
                }
                block(weakSelf);
            });
        }
    }
}

#if kSelfImplementTCICCustomMsg
- (BOOL)sendCustomMsg:(NSString *_Nullable)customMsg {
    __block BOOL sendsucc = NO;
    [self safeRunInMain:^(CustomMsgHandler *mgr) {
        
        BOOL hasNull = NO;
        for (id<TCICCustomMsgSender> sender in mgr.customChannelArray) {
            if (sender == nil) {
                hasNull = YES;
            } else {
                BOOL succ = [sender sendCustomMsg:customMsg];
                if (succ) {
                    sendsucc = YES;
                }
            }
        }
        
        if (hasNull) {
            [mgr.customChannelArray compact];
        }
        
    }];
    return sendsucc;
}


/**
 * H5向Native注册
 * @param sender : H5模块对应Native本地模块；
 */
- (void)onRegistSender:(id<TCICCustomMsgSender> _Nonnull)sender {
    // 收到回调后，才可以发消息
    [self safeRunInMain:^(CustomMsgHandler *mgr) {
        if (sender) {
            NSUInteger idx = [[mgr.customChannelArray allObjects] indexOfObject:sender];
            if (idx >= 0 && idx < mgr.customChannelArray.count) {
                // 避免重复加
                return;
            }
            [mgr.customChannelArray addPointer:(__bridge void * _Nullable)sender];
            [mgr.customChannelArray compact];
        }
    }];
}

/**
 * H5向Native发送消息
 * @param sender : H5模块对应Native本地模块;
 * @param jsonMsg 发送的定制消息;
 * 注意事项：
 *   1. 若业务侧接收到消息后，异步调用sendCustomMsg回复；
 */

- (void)onRecvMsgFrom:(id<TCICCustomMsgSender> _Nonnull)sender customMsg:(NSString *_Nonnull)jsonMsg {
#if DEBUG
    [self safeRunInMain:^(CustomMsgHandler *mgr) {
        NSMutableDictionary *recv = [NSMutableDictionary dictionary];
        [recv setValue:@"消息来自native echo" forKey:@"nativeEcho"];
        [recv setValue:jsonMsg forKey:@"customMsg"];
        [sender sendCustomMsg:[recv yy_modelToJSONString]];
    }];
#endif
}

#endif

@end
