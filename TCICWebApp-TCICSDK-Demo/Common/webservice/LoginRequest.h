//
//  LoginRequest.h
//  TIC_Web_SaaS
//
//  Created by AlexiChen on 2020/5/14.
//  Copyright © 2020 AlexiChen. All rights reserved.
//

#import "BaseRequest.h"

NS_ASSUME_NONNULL_BEGIN



@interface SignLoginRequest : BaseRequest

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *cid;
@property (nonatomic,assign) bool role;
@property (nonatomic, copy) NSString *env;
@property (nonatomic, copy) NSString *classType;
@property (nonatomic, assign) NSInteger audioLevel;

@end

@interface SignLoginResponse : BaseResponse

@property (nonatomic, copy) NSString *sign;

@end

NS_ASSUME_NONNULL_END
