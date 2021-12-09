//
//  TICWebServiceEngine.m
//
//
//  Created by Alexi on 14-8-5.
//  Copyright (c) 2014年 Alexi Chen. All rights reserved.
//
#import "TICWebServiceEngine.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>
#import <CommonCrypto/CommonDigest.h>
#import "BaseRequest.h"
#import "ComMarco.h"
#import "HUDHelper.h"



#define kRequestTimeOutTime 30
#define kRequestError_Str @"请求出错"



@interface TICWebServiceEngine ()
{
    SCNetworkReachabilityRef _reachabilityRef;
    NSURLSession *_sharedSession;
}
@end


@implementation TICWebServiceEngine

static TICWebServiceEngine *_sharedEngine = nil;



+ (instancetype)sharedEngine
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedEngine = [[TICWebServiceEngine alloc] init];
    });
    return _sharedEngine;
}

- (void)dealloc
{
    [self stopNotifier];
    if (_reachabilityRef != NULL)
    {
        CFRelease(_reachabilityRef);
    }
}


- (instancetype)init
{
    if (self = [super init])
    {
        _sharedSession = [NSURLSession sharedSession];
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "www.qq.com");
        if (reachability != NULL) {
            _reachabilityRef = reachability;
            [self startNotifier];
        }
        
    }
    return self;
}

#define kShouldPrintReachabilityFlags 0

static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment)
{
#if kShouldPrintReachabilityFlags
    
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)                ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}

NSString * kReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [TICWebServiceEngine class]], @"info was wrong class in ReachabilityCallback");
    
    TICWebServiceEngine* noteObject = (__bridge TICWebServiceEngine *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification object: noteObject];
}


- (BOOL)startNotifier
{
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context))
    {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            returnValue = YES;
        }
    }
    
    return returnValue;
}

- (void)stopNotifier
{
    if (_reachabilityRef != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
    PrintReachabilityFlags(flags, "networkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // The target host is not reachable.
        return NotReachable;
    }
    
    NetworkStatus returnValue = NotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = ReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = ReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = ReachableViaWWAN;
    }
    
    return returnValue;
}

- (NetworkStatus)currentReachabilityStatus
{
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    NetworkStatus returnValue = NotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
    {
        returnValue = [self networkStatusForFlags:flags];
    }
    
    return returnValue;
}

- (BOOL)isNetworkReachable {
    NetworkStatus net = [self currentReachabilityStatus];
    return net != NotReachable;
}

//===================================

+(NSString *)getMD5String:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}


+ (NSString *)calculateSign:(NSData *)data {
    if (data == nil) {
        return nil;
    }
    // 计算Sign
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *sign = [self getMD5String:jsonStr];
    return sign;
}


//===================================

- (void)asyncRequest:(BaseRequest *)req
{
    [self asyncRequest:req wait:YES];
}

- (void)asyncRequest:(BaseRequest *)req wait:(BOOL)wait
{
    [self asyncRequest:req loadingMessage:nil wait:wait];
}


- (void)asyncRequest:(BaseRequest *)req loadingMessage:(NSString *)msg wait:(BOOL)wait
{
    
    if (!req) {
        return;
    }
    
    WEAKIFY(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        STRONGIFY_OR_RETURN(self);
        
        if (![self isNetworkReachable]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (req.failHandler) {
                    req.failHandler(req, -1, @"网络异常");
                } else {
                    [[HUDHelper sharedInstance] tipMessage:@"网络异常"];
                }
            });
            return;
        }
        
        NSMutableString *url = [NSMutableString stringWithString:[req url]];
        if (url.length == 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (req.failHandler) {
                    req.failHandler(req, -2, @"URL地址为空");
                } else {
                    [[HUDHelper sharedInstance] tipMessage:@"URL地址为空"];
                }
            });
            return;
        }
        
        if ([req needRandom]) {
            [url appendFormat:@"&random=%d",(int)(arc4random() % 100000)];
        }
        
        NSData *data = [req toPostJsonData];
        if ([req needSign] && data) {
            [url appendFormat:@"&sign=%@", [TICWebServiceEngine calculateSign:data]];
        }
        
        DebugLog(@"reqest url = %@", url);
        
        NSURL *URL = [NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        
        if (data)
        {
            [request setValue:[NSString stringWithFormat:@"%ld",(long)[data length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            
            [request setHTTPBody:data];
        }
        
        [request setTimeoutInterval:kRequestTimeOutTime];
        
        if (wait) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                if (msg.length > 0) {
                    [[HUDHelper sharedInstance] syncLoading:msg];
                }  else {
                    [[HUDHelper sharedInstance] syncLoading];
                }
            });
            
        }
        
        NSURLSessionDataTask *task = [self->_sharedSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (wait) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    if (msg.length > 0) {
                        [[HUDHelper sharedInstance] syncStopLoading];
                    } else {
                        [[HUDHelper sharedInstance] syncStopLoading];
                    }
                });
            }
            
            
            if (error != nil) {
                DebugLog(@"Request = %@, Error = %@", req, error);
                if (req.failHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        req.failHandler(req, error.code, [NSString stringWithFormat:@"网络错误（%d）", (int)error.code]);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[HUDHelper sharedInstance] tipMessage:[NSString stringWithFormat:@"网络错误（%d）", (int)error.code]];
                    });
                }
            } else {
                
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                DebugLog(@"[%@] request's responseString is :\n================================\n %@ \n================================" , [req class], responseString);
                if (req.succHandler || req.failHandler) {
                    [req parseResponse:responseString];
                }
            }
        }];
        
        [task resume];
    });
}

@end

