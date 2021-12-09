//
//  SampleHandler.m
//  ScreenKit
//
//  Created by 陈耀武 on 2020/12/29.
//  Copyright © 2020 陈耀武. All rights reserved.
//


#import "SampleHandler.h"
#import "ComMarco.h"
#import <TXLiteAVSDK_ReplayKitExt/TXLiteAVSDK_ReplayKitExt.h>
#import <TCICScreenKit/TCICScreenKit.h>

#define kAppGroup @"group.com.tencent.screenshare"

#define kSupportSceenShare  @available(iOS 11.0, *)

@interface SampleHandler() <TXReplayKitExtDelegate>
@end
@implementation SampleHandler
// 注意：此处的 APPGROUP 需要改成上文中的创建的 App Group Identifier。

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    if (kSupportSceenShare) {
        [[TXReplayKitExt sharedInstance] setupWithAppGroup:kAppGroup delegate:self];
    
    [[TCICScreenKit sharedScreenKit] onScreenKitStarted];
}
}

- (void)broadcastPaused {
    if (kSupportSceenShare) {
    [[TCICScreenKit sharedScreenKit] onScreenKitPaused];
}
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    if (kSupportSceenShare) {
    [[TCICScreenKit sharedScreenKit] onScreenKitResumed];
}
}

- (void)broadcastFinished {
    if (kSupportSceenShare) {
        [[TXReplayKitExt sharedInstance] broadcastFinished];
    // User has requested to finish the broadcast.
    [[TCICScreenKit sharedScreenKit] onScreenKitFinished];
}
}

#pragma mark - TXReplayKitExtDelegate
- (void)broadcastFinished:(TXReplayKitExt *)broadcast reason:(TXReplayKitExtReason)reason
{
    if (kSupportSceenShare) {
    NSString *tip = @"";
    switch (reason) {
        case TXReplayKitExtReasonRequestedByMain:
            tip = @"屏幕共享已结束";
            break;
        case TXReplayKitExtReasonDisconnected:
            tip = @"应用断开";
            break;
        case TXReplayKitExtReasonVersionMismatch:
            tip = @"集成错误（SDK 版本号不相符合）";
            break;
    }
    NSError *error = [NSError errorWithDomain:NSStringFromClass(self.class) code:0 userInfo:@{
        NSLocalizedFailureReasonErrorKey:tip
    }];
        [[TXReplayKitExt sharedInstance] broadcastFinished];
        // User has requested to finish the broadcast.
        [[TCICScreenKit sharedScreenKit] onScreenKitFinished];
    [self finishBroadcastWithError:error];
        
    }
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    if (kSupportSceenShare) {
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
        case RPSampleBufferTypeAudioApp:
                
                [[TCICScreenKit sharedScreenKit] processSampleBuffer:sampleBuffer withType:sampleBufferType];
                
                [[TXReplayKitExt sharedInstance] sendSampleBuffer:sampleBuffer withType:sampleBufferType];
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}
}
@end
