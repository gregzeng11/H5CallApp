//
//  CustomMsgHandler.h
//  TYICWebApp
//
//  Created by 陈耀武 on 2021/1/22.
//  Copyright © 2021 陈耀武. All rights reserved.
//

#define kSelfImplementTCICCustomMsg 1

#if kSelfImplementTCICCustomMsg
#import <Foundation/Foundation.h>
#include <TCICSDK/TCICCustomDef.h>
#else
#include <TCICSDK/TCICCustomMsgMgr.h>
#endif

NS_ASSUME_NONNULL_BEGIN


#if kSelfImplementTCICCustomMsg
@interface CustomMsgHandler : NSObject<TCICCustomMsgSender, TCICCustomMsgRecver>
#else
@interface CustomMsgHandler : TCICCustomMsgMgr
#endif

@end

NS_ASSUME_NONNULL_END
