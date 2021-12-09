//
//  BaseViewController.m
//  TICWebApp
//
//  Created by AlexiChen on 2020/5/11.
//  Copyright © 2020 AlexiChen. All rights reserved.
//

#import "BaseViewController.h"
#import "ComMarco.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (kIsIPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else if (kIsIPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if (kIsIPhone) {
        return UIInterfaceOrientationPortrait;
    } else if (kIsIPad) {
        return [UIApplication sharedApplication].statusBarOrientation;
    } else {
        return UIInterfaceOrientationPortrait;
    }
}
- (BOOL)shouldAutorotate {
    return kIsIPad;
}

@end
