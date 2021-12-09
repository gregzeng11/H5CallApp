//
//  TICAboutViewController.m
//  TIC_SaaS
//
//  Created by jameskhdeng(邓凯辉) on 2019/9/10.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TICAboutViewController.h"
#import "TICPrivacyViewController.h"
#import "ComMarco.h"
//#import <Photos/Photos.h>

@interface TICAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *quitButton;


@end

@implementation TICAboutViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *buildStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    self.versionLabel.text = [NSString stringWithFormat:@"v %@.%@.%d", versionStr, buildStr, TCIC_DEVOPS_BUILD_NO];
    
    self.quitButton.imageView.image = [self.quitButton.imageView.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];

    self.quitButton.imageView.tintColor = [UIColor lightGrayColor];
}


//返回支持的方向
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}

- (IBAction)onUserPrivacy:(id)sender {
    TICPrivacyViewController *vc = [[TICPrivacyViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)onQuit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
