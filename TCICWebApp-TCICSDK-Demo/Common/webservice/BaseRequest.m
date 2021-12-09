//
//  BaseRequest.m
//
//
//  Created by Alexi on 14-8-4.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//

#import "BaseRequest.h"
#import "ComMarco.h"
#import "HUDHelper.h"
#import <YYModel/YYModel.h>


// =========================================

@implementation BaseRequest

- (void)dealloc
{
    DebugLog(@"=========[%@] release成功>>>>>>>>>", NSStringFromClass([self class]));
}

- (instancetype)initWithHandler:(RequestSuccHandler)succHandler
{
    if (self = [self init])
    {
        self.succHandler = succHandler;
    }
    return self;
}

- (instancetype)initWithHandler:(RequestSuccHandler)succHandler failHandler:(RequestFailHandler)fail
{
    if (self = [self initWithHandler:succHandler]) {
        self.failHandler = fail;
    }
    return self;
}

- (NSString *)url
{
    return @"";
}

- (BOOL)needSign {
    return YES;
}


- (BOOL)needRandom {
    return YES;
}

- (NSDictionary *)packageParams
{
    return nil;
}

- (NSData *)toPostJsonData
{
    NSDictionary *dic = [self packageParams];
    // 转成Json数据
    if ([NSJSONSerialization isValidJSONObject:dic])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        if(error) {
            DebugLog(@"[%@] Post Json Error: %@", [self class], dic);
        } else {
            DebugLog(@"[%@] Post Json : %@", [self class], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
        return data;
    } else {
        DebugLog(@"[%@] Post Json is not valid: %@", [self class], dic);
    }
    return nil;
}

- (void)parseResponseInner:(NSString *)respJsonString {
    if (respJsonString.length >0 ) {
        BaseResponse *resp = [[self responseClass] yy_modelWithJSON:respJsonString];
        self.response = resp;
    }
}


- (void)parseResponse:(NSString *)respJsonString;
{
    if (self.succHandler || self.failHandler) {
        if (respJsonString) {
            DebugLog(@"==========[%@]开始解析响应>>>>>>>>>", self);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                // 子线程解析数据
                if (self->_succHandler) {
                    [self parseResponseInner:respJsonString];
                    if (self.response) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([self->_response success]) {
                                if (self->_succHandler) {
                                    self->_succHandler(self);
                                }
                            } else {
                                if (self->_failHandler) {
                                    self->_failHandler(self, [self->_response errorCode], [self->_response errorMessage]);
                                } else {
                                    [[HUDHelper sharedInstance] tipMessage:[self->_response errorMessage]];
                                }
                            }
                            DebugLog(@"==========[%@]开始解析响应完成>>>>>>>>>", self);
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // 说明返回内容有问题
                            if (self->_failHandler) {
                                self->_failHandler(self, -4, @"返回数据有误");
                            } else {
                                [[HUDHelper sharedInstance] tipMessage:@"返回数据有误"];
                            }
                            DebugLog(@"==========[%@]开始解析响应完成>>>>>>>>>", self);
                        });
                    }
                } else {
                    DebugLog(@"_succHandler 为空, 不解析");
                }
            });
        } else {
            DebugLog(@"[%@]返回数据为空", [self class]);
            dispatch_async(dispatch_get_main_queue(), ^{
               
                // 说明返回内容有问题
                if (self->_failHandler) {
                    self->_failHandler(self, -4, @"返回数据为空");
                } else {
                    [[HUDHelper sharedInstance] tipMessage:@"返回数据为空"];
                }
            });
        }
    }
}

- (Class)responseClass;
{
    return [BaseResponse class];
}

- (void)parseArrayResponse:(NSArray *)bodyDic
{
    
}

@end

// =========================================


@implementation BaseResponse

- (instancetype)init {
    if (self = [super init]) {
        // 默认成功
        _code = 0;
    }
    return self;
}

- (BOOL)success {
    return _code == 0;
}


- (NSInteger)errorCode {
    return _code;
}
- (NSString *)errorMessage {
    return _message;
}

@end

// =========================================
