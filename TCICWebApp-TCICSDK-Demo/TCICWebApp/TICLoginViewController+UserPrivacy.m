//
//  TICLoginViewController+UserPrivacy.m
//  TYICWebApp
//
//  Created by 陈耀武 on 2021/2/24.
//  Copyright © 2021 陈耀武. All rights reserved.
//

#import "TICLoginViewController+UserPrivacy.h"
#import "TICPrivacyViewController.h"
#import "ComMarco.h"
@implementation TICLoginViewController (UserPrivacy)

#define kTCICClassUserPrivacy @"kTCICClassUserPrivacy"

- (void)setAcceptPrivacy:(BOOL)acceptPrivacy {
    [[NSUserDefaults standardUserDefaults] setValue:@(acceptPrivacy) forKey:kTCICClassUserPrivacy];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)acceptPrivacy {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:kTCICClassUserPrivacy];
    if (num) {
        return num.boolValue;
    }
    return NO;
}

static UIAlertController *userPrivacyAlert = nil;

- (void)showUserAlert {
    
    BOOL accept = [self acceptPrivacy];
    if (accept) {
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"服务协议和隐私政策" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController *controller = [[UIViewController alloc] init];
    UITextView *textView = [[UITextView alloc] init];
    textView.delegate = self;
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.backgroundColor = [UIColor clearColor];
    textView.frame = CGRectInset(controller.view.bounds, 4, 2);
    [controller.view addSubview:textView];
    textView.scrollEnabled = NO;

    [alert setValue:controller forKey:@"contentViewController"];

    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320];
    [alert.view addConstraint:height];
    
    
    const int fsize = 14;
    UIColor *acceptColor = HexRGB(0x0A818C);
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *messageAttr = @{
        NSFontAttributeName:[UIFont systemFontOfSize:fsize],
        NSParagraphStyleAttributeName:paraStyle,
    };
    
    NSMutableAttributedString *attMessage = [[NSMutableAttributedString alloc] initWithString:@"欢迎您使用腾云课堂！请您务必审慎阅读、充分理解\"服务协议\"和\"隐私政策\"各条款，帮助您了解我们收集、使用、存储和共享个人信息情况，以及您所享有的相关权利。您可以在\"设置\"中查看、变更、删除个人信息并管理您的授权。\n\n您可阅读《服务协议》和《隐私政策》了解详细信息。如您同意，请点击\"同意\"开始接受我们的服务" attributes:messageAttr];
    
    [attMessage addAttribute:NSLinkAttributeName value:@"tcic-service://" range:[[attMessage string] rangeOfString:@"《服务协议》"]];
    [attMessage addAttribute:NSLinkAttributeName value:@"tcic-privacy://" range:[[attMessage string] rangeOfString:@"《隐私政策》"]];
    
    textView.attributedText = attMessage;
    textView.userInteractionEnabled = YES;
    textView.editable = NO;
    textView.linkTextAttributes = @{
        NSForegroundColorAttributeName:acceptColor,
        NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)
    };

    UIAlertAction *notAcceptAction = [UIAlertAction actionWithTitle:@"暂不使用" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setAcceptPrivacy:NO];
        UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(suspend)];
        
        //wait 2 seconds while app is going background
        [NSThread sleepForTimeInterval:2.0];
        
        //exit app when app is in background
        exit(0);
    }];
    [notAcceptAction setValue:[UIColor grayColor] forKey:@"titleTextColor"];
    [alert addAction:notAcceptAction];
    
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDestructive  handler:^(UIAlertAction * _Nonnull action) {
        [self setAcceptPrivacy:YES];
    }];
    [acceptAction setValue:acceptColor forKey:@"titleTextColor"];
    [alert addAction:acceptAction];
    
    userPrivacyAlert = alert;
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"tcic-service"]) {
        NSLog(@"服务协议");
        if (userPrivacyAlert) {
            [userPrivacyAlert dismissViewControllerAnimated:YES completion:nil];
            userPrivacyAlert = nil;
        }
        WEAKIFY(self);
        TICPrivacyViewController *vc = [[TICPrivacyViewController alloc] initWithCompletion:^{
            STRONGIFY_OR_RETURN(self);
            [self showUserAlert];
        }];
        vc.loadUrl = @"https://tcic-resources-1304753050.file.myqcloud.com/ServiceProtocol/tcic/service.html";
        [self presentViewController:vc animated:YES completion:nil];
        return NO;
    } else if ([[URL scheme] isEqualToString:@"tcic-privacy"]) {
        NSLog(@"隐私政策");
        if (userPrivacyAlert) {
            [userPrivacyAlert dismissViewControllerAnimated:YES completion:nil];
            userPrivacyAlert = nil;
        }
        WEAKIFY(self);
        TICPrivacyViewController *vc = [[TICPrivacyViewController alloc] initWithCompletion:^{
            STRONGIFY_OR_RETURN(self);
            [self showUserAlert];
        }];
        vc.loadUrl = @"https://tcic-resources-1304753050.file.myqcloud.com/ServiceProtocol/tcic/privacy.html";
        [self presentViewController:vc animated:YES completion:nil];
    
        return NO;
    }
    return YES;
}
@end
