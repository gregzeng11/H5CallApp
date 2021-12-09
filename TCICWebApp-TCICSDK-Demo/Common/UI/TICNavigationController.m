//
//  TICNavigationController.m
//  TICWebApp
//
//  Created by AlexiChen on 2020/5/11.
//  Copyright © 2020 AlexiChen. All rights reserved.
//

#import "TICNavigationController.h"

@interface TICNavigationController ()

@end

@implementation TICNavigationController

- (BOOL)shouldAutorotate
{
    BOOL rorate = [self.viewControllers.lastObject shouldAutorotate];
    return rorate;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}


////ios5.0 横竖屏
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return [self shouldAutorotate];
//}

@end
