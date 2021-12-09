//
//  HUDHelper.m
//  
//
//  Created by Alexi on 12-11-28.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "HUDHelper.h"
#import "ComMarco.h"

//#import "NSString+Common.h"

//#import <BlocksKit/BlocksKit.h>
@implementation HUDHelper

static HUDHelper *_instance = nil;


+ (HUDHelper *)sharedInstance
{
    @synchronized(_instance)
    {
        if (_instance == nil)
        {
            _instance = [[HUDHelper alloc] init];
        }
        return _instance;
    }
}

//+ (void)alert:(NSString *)msg
//{
//    [HUDHelper alert:msg cancel:@"确定"];
//}
//+ (void)alert:(NSString *)msg action:(CommonVoidBlock)action
//{
//    [HUDHelper alert:msg cancel:@"确定" action:action];
//}
//+ (void)alert:(NSString *)msg cancel:(NSString *)cancel
//{
//    [HUDHelper alertTitle:@"提示" message:msg cancel:cancel];
//}
//+ (void)alert:(NSString *)msg cancel:(NSString *)cancel action:(CommonVoidBlock)action
//{
//    [HUDHelper alertTitle:@"提示" message:msg cancel:cancel action:action];
//}
//+ (void)alertTitle:(NSString *)title message:(NSString *)msg cancel:(NSString *)cancel
//{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil, nil];
//    [alert show];
//}
//
//+ (void)alertTitle:(NSString *)title message:(NSString *)msg cancel:(NSString *)cancel action:(CommonVoidBlock)action
//{
//    UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:title message:msg cancelButtonTitle:cancel otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        if (action)
//        {
//            action();
//        }
//    }];
//    [alert show];
//}

- (MBProgressHUD *)loading
{
    return [self loading:nil];
}

- (MBProgressHUD *)loading:(NSString *)msg
{
    return [self loading:msg inView:nil];
}

- (MBProgressHUD *)loading:(NSString *)msg inView:(UIView *)view {
    UIView *inView = view ? view : [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:inView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (msg.length > 0)
        {
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.label.text = msg;
            hud.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        }
        [inView addSubview:hud];
        [hud showAnimated:YES];
        // 超时自动消失
        // [hud hide:YES afterDelay:kRequestTimeOutTime];
    });
    return hud;
}

- (void)loading:(NSString *)msg delay:(CGFloat)seconds execute:(void (^)(void))exec completion:(void (^)(void))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *inView = [UIApplication sharedApplication].keyWindow;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:inView];
        if (msg.length > 0)
        {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = msg;
        }
        
        [inView addSubview:hud];
        [hud showAnimated:YES];
        if (exec) {
            exec();
        }
        
        // 超时自动消失
        [hud hideAnimated:YES afterDelay:seconds];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion();
            }
        });
    });
}


- (void)stopLoading:(MBProgressHUD *)hud {
    [self stopLoading:hud message:nil];
}

- (void)stopLoading:(MBProgressHUD *)hud message:(NSString *)msg {
    [self stopLoading:hud message:msg delay:0 completion:nil];
}
- (void)stopLoading:(MBProgressHUD *)hud message:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)(void))completion
{
    if (hud && hud.superview)
    {
        WEAKIFY(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONGIFY_OR_RETURN(self);
            if (msg.length > 0)
            {
                hud.label.text = msg;
                hud.mode = MBProgressHUDModeText;
            }
            
            [hud hideAnimated:YES afterDelay:seconds];
            self->_syncHUD = nil;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion();
                }
            });
        });
    }
    else
    {
        if (completion)
        {
            completion();
        }
    }
    
}


- (void)tipMessage:(NSString *)msg
{
    [self tipMessage:msg delay:2];
}

- (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds
{
    [self tipMessage:msg delay:seconds completion:nil];
    
}

- (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)(void))completion
{
    if (msg.length == 0)
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:window];
        [window addSubview:hud];
        hud.removeFromSuperViewOnHide = YES;
        hud.mode = MBProgressHUDModeText;
        hud.label.text = msg;
        [hud showAnimated:YES];
        [hud hideAnimated:YES afterDelay:seconds];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion();
            }
        });
    });
}


#define kSyncHUDStartTag  100000

// 网络请求
- (void)syncLoading
{
    [self syncLoading:nil];
}
- (void)syncLoading:(NSString *)msg
{
    [self syncLoading:msg inView:nil];
}
- (void)syncLoading:(NSString *)msg inView:(UIView *)view
{
    if (_syncHUD) {
        _syncHUD.tag++;
        
        if (msg.length > 0) {
            _syncHUD.label.text = msg;
            _syncHUD.mode = MBProgressHUDModeText;
        } else {
            _syncHUD.label.text = nil;
            _syncHUD.mode = MBProgressHUDModeIndeterminate;
        }
        return;
    }
    _syncHUD = [self loading:msg inView:view];
    _syncHUD.tag = kSyncHUDStartTag;
}

- (void)syncStopLoading
{
    [self syncStopLoadingMessage:nil delay:0 completion:nil];
}
- (void)syncStopLoadingMessage:(NSString *)msg
{
    [self syncStopLoadingMessage:msg delay:1 completion:nil];
}
- (void)syncStopLoadingMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)(void))completion
{
    _syncHUD.tag--;
    if (_syncHUD.tag > kSyncHUDStartTag) {
        if (msg.length > 0) {
            _syncHUD.label.text = msg;
            _syncHUD.mode = MBProgressHUDModeText;
        } else {
            _syncHUD.label.text = nil;
            _syncHUD.mode = MBProgressHUDModeIndeterminate;
        }
    } else {
        [self stopLoading:_syncHUD message:msg delay:seconds completion:completion];
    }
}



@end
