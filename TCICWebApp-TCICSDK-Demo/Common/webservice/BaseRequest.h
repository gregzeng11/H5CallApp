//
//  BaseRequest.h
//  
//
//  Created by Alexi on 14-8-4.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//

#import <Foundation/Foundation.h>



// =========================================

@class BaseRequest;
@class BaseResponse;


typedef void (^RequestSuccHandler)(BaseRequest *request);
typedef void (^RequestFailHandler)(BaseRequest *request, NSInteger code, NSString *errMsg);

@interface BaseRequest : NSObject
{
@protected
    BaseResponse            *_response;
}

@property (nonatomic, strong) BaseResponse *response;
@property (nonatomic, strong) RequestSuccHandler succHandler;
@property (nonatomic, strong) RequestFailHandler failHandler;


- (instancetype)initWithHandler:(RequestSuccHandler)succHandler;

- (instancetype)initWithHandler:(RequestSuccHandler)succHandler failHandler:(RequestFailHandler)fail;

- (NSString *)url;

- (BOOL)needRandom;
- (BOOL)needSign;

- (NSDictionary *)packageParams;

- (NSData *)toPostJsonData;

- (void)parseResponse:(NSString *)respJsonString;

// override by subclass
// 配置_response对应的类
- (Class)responseClass;
- (void)parseResponseInner:(NSString *)respJsonString;

@end



@interface BaseResponse : NSObject<NSObject>

// 对应json中返回的字段
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *message;

// 请求是否成功
- (BOOL)success;

// 请求失败时对应的提示语
- (NSInteger)errorCode;
- (NSString *)errorMessage;

@end

// =========================================
