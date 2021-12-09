//
//  CustomMgr.h
//  TYIC_Web_Demo
//
//  Created by 陈耀武 on 2021/1/1.
//  Copyright © 2021 陈耀武. All rights reserved.
//

#define kSelfImplementTCICUICustomMgr 0

#if kSelfImplementTCICUICustomMgr
#import <TCICSDK/TCICUICustomMgr.h>
#else
#import <TCICSDK/TCICVideoContainerMgr.h>
#endif

NS_ASSUME_NONNULL_BEGIN


#if kSelfImplementTCICUICustomMgr
@interface CustomMgr : NSObject<TCICUICustomMgr>
#else
@interface CustomMgr : TCICVideoContainerMgr
#endif

@end

NS_ASSUME_NONNULL_END
