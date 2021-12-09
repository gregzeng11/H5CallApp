//
//  TICLoginViewController.m
//  TICWebApp
//
//  Created by AlexiChen on 2020/5/11.
//  Copyright © 2020 AlexiChen. All rights reserved.
//

#import "TICLoginViewController.h"
#import "TICWebServiceEngine.h"
#import "LoginRequest.h"
#import "ComMarco.h"
#import <TCICSDK/TCICClassController.h>
#import <Masonry/Masonry.h>
#import <YYModel/YYModel.h>
#import "TICTextField.h"
#import "TICAboutViewController.h"
#import "TICNavigationController.h"
#import "AppDelegate.h"


#define kCustomLayout 0

#if kCustomLayout
#import "ClassViewController.h"
#import "CustomMgr.h"
#import "CustomMsgHandler.h"
#endif

#import "TICLoginViewController+UserPrivacy.h"

typedef NS_ENUM(NSInteger, TICEnvType) {
    TCIENV_Release,
    TCIENV_Dev,
    TCIENV_Test,
    TCIENV_Demo,
};

typedef NS_ENUM(NSInteger, TCICClassType) {
    TCICClassType_Interactive,
    TCICClassType_Live
};

@interface TICUserInfo : NSObject

@property (nonatomic, assign) BOOL isTeacher;
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, assign) NSString *classIdString;
@property (nonatomic, assign) UInt32 schoolId;
@property (nonatomic, assign) long classEndTime;
@property (nonatomic, assign) TCICClassType classType;   // 课程类型
@property (nonatomic, assign) NSInteger audioLevel;         // 0 : 普通， 1 : 高音质


@end

@implementation TICUserInfo



@end

// 蓝盾流水线构建号

@interface TICLoginViewController ()

@property (nonatomic, weak) IBOutlet UIView         *containerView;
@property (nonatomic, weak) IBOutlet UIImageView    *bgView;
@property (nonatomic, weak) IBOutlet UILabel        *verTip;
@property (nonatomic, weak) IBOutlet UILabel        *errTip;
@property (nonatomic, weak) IBOutlet UIButton       *enterButton;
@property (nonatomic, weak) IBOutlet UIButton       *aboutButton;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer  *singleTapGesture;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer  *switchEnvTapGesture;

@property (nonatomic, weak) IBOutlet UILabel *classTypeTip;
@property (nonatomic, weak) IBOutlet UISegmentedControl *classTypeSeg;

@property (nonatomic, weak) IBOutlet UILabel *audioTip;
@property (nonatomic, weak) IBOutlet UISegmentedControl *audioTypeSeg;

@property (nonatomic, weak) IBOutlet UITextView *userPrivacy;

//@property (nonatomic, assign) BOOL isTeacher;
@property (nonatomic, strong) TICUserInfo           *loginUser;

@end

@implementation TICLoginViewController

#define kTICLoginUserInfo @"kTICLoginUserInfo"

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //监听事件键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.hasJoinedClassRoom = NO;
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

    

- (UIImage *)color2Image:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)switchUserRole:(BOOL)needSync {
    BOOL isTeacher = self.loginUser.isTeacher;
    self.verTip.text = isTeacher ? @"老师版" : @"学生版";
    self.classRoomTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入课堂编号" attributes: @{NSForegroundColorAttributeName:HexRGB(0x4B505A), NSFontAttributeName:self.classRoomTF.font }];
    [self.enterButton setTitle:isTeacher ? @"创建并加入课堂" : @"加入课堂" forState:UIControlStateNormal];
    
      self.userIdTF.text = self.loginUser.uid;
    self.classRoomTF.text = self.loginUser.cid;
    
    self.classTypeTip.hidden = !isTeacher;
    self.classTypeSeg.hidden = !isTeacher;
    
    self.audioTip.hidden = !isTeacher;
    self.audioTypeSeg.hidden = !isTeacher;
    
    
    if (needSync) {
        if (self.loginUser.uid.length > 0) {
            NSDictionary *dic = [self.loginUser yy_modelToJSONObject];
            [[NSUserDefaults standardUserDefaults] setValue:dic forKey:kTICLoginUserInfo];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTICLoginUserInfo];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    self.view.backgroundColor = [UIColor redColor];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
    }];
    self.bgView.frame = self.view.bounds;
    
    self.classRoomTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入课堂编号" attributes: @{NSForegroundColorAttributeName:HexRGB(0x4B505A), NSFontAttributeName:self.classRoomTF.font }];
    self.userIdTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入帐号" attributes: @{NSForegroundColorAttributeName:HexRGB(0x4B505A), NSFontAttributeName:self.classRoomTF.font }];
    
    
    NSDictionary *userInfoDic = [[NSUserDefaults standardUserDefaults] valueForKey:kTICLoginUserInfo];
    if (userInfoDic) {
        self.loginUser = [TICUserInfo yy_modelWithJSON:userInfoDic];
    }
    
    if (self.loginUser == nil) {
        self.loginUser = [[TICUserInfo alloc] init];
        self.loginUser.isTeacher = kIsIPad;
    }
    
    [self switchUserRole:NO];
    
    
    [self.classRoomTF setLeftImage:[UIImage imageNamed:@"login_room"]];
    [self.userIdTF setLeftImage:[UIImage imageNamed:@"login_user"]];
    
    [self.classRoomTF addTarget:self action:@selector(onInputBegin) forControlEvents:UIControlEventEditingDidBegin];
    [self.userIdTF addTarget:self action:@selector(onInputBegin) forControlEvents:UIControlEventEditingDidBegin];
    
    [self.enterButton setBackgroundImage:[self color2Image:HexRGB(0x0A818C)] forState:UIControlStateNormal];
    [self.enterButton setBackgroundImage:[self color2Image:HexRGB(0x0A919C)] forState:UIControlStateHighlighted];
    [self.enterButton setBackgroundImage:[self color2Image:HexRGB(0x0A717C)] forState:UIControlStateDisabled];
    
    [self.errTip setTextColor:HexRGB(0xFF6863)];
    [self.aboutButton setTitleColor:HexRGB(0x4B505A) forState:UIControlStateNormal];
    
    if (kIsIPad) {
        self.containerView.backgroundColor = HexRGB(0x34363b);
    }
    
        
#if AppStoreRelease
    [self.view removeGestureRecognizer:self.switchEnvTapGesture];
    self.switchEnvTapGesture = nil;
#else
    
    if (TCIC_DEVOPS_BUILD_NO > 0) {
        NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *buildStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *aboutTitle = [NSString stringWithFormat:@"关于腾云课堂-%@.%@.%d", versionStr, buildStr, TCIC_DEVOPS_BUILD_NO];
        [self.aboutButton setTitle:aboutTitle forState:UIControlStateNormal];
    }
    
    {
        self.classTypeSeg.selectedSegmentIndex = self.loginUser.classType;
        
        self.classTypeSeg.backgroundColor = HexRGB(0x333639);
        if (@available(iOS 13.0, *)) {
            self.classTypeSeg.selectedSegmentTintColor = HexRGB(0x95A5A6);
        }
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont boldSystemFontOfSize:14], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
        [self.classTypeSeg setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        
        NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:HexRGB(0x387A85) forKey:NSForegroundColorAttributeName];
        [self.classTypeSeg setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    }

    {
        self.audioTypeSeg.selectedSegmentIndex = self.loginUser.audioLevel;
        
        self.audioTypeSeg.backgroundColor = HexRGB(0x333639);
        if (@available(iOS 13.0, *)) {
            self.audioTypeSeg.selectedSegmentTintColor = HexRGB(0x95A5A6);
        }
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont boldSystemFontOfSize:14], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
        [self.audioTypeSeg setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        
        NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:HexRGB(0x387A85) forKey:NSForegroundColorAttributeName];
        [self.audioTypeSeg setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    }
#endif
    
    {
        self.userPrivacy.delegate = self;
        self.userPrivacy.scrollEnabled = NO;
        self.userPrivacy.userInteractionEnabled = YES;
        self.userPrivacy.editable = NO;
        const int fsize = 14;
        UIColor *acceptColor = HexRGB(0x0A818C);
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *messageAttr = @{
            NSFontAttributeName:[UIFont systemFontOfSize:fsize],
            NSParagraphStyleAttributeName:paraStyle,
            NSForegroundColorAttributeName : [UIColor lightGrayColor]
        };
        
        NSMutableAttributedString *attMessage = [[NSMutableAttributedString alloc] initWithString:@"《服务协议》｜《隐私政策》" attributes:messageAttr];
        
        [attMessage addAttribute:NSLinkAttributeName value:@"tcic-service://" range:[[attMessage string] rangeOfString:@"《服务协议》"]];
        [attMessage addAttribute:NSLinkAttributeName value:@"tcic-privacy://" range:[[attMessage string] rangeOfString:@"《隐私政策》"]];
        
        self.userPrivacy.attributedText = attMessage;
        self.userPrivacy.userInteractionEnabled = YES;
        self.userPrivacy.editable = NO;
        self.userPrivacy.linkTextAttributes = @{
            NSForegroundColorAttributeName:acceptColor,
            NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)
        };
    }
    [self showUserAlert];
}

- (void)onInputBegin{
    if (self.errTip.text > 0) {
        self.errTip.text = nil;
    }
}

- (IBAction)onAbout {
    TICAboutViewController *vc = [[TICAboutViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSString *)getClassTypeString {
    TCICClassType type = self.classTypeSeg.selectedSegmentIndex;
    NSArray *typeStrs = @[@"interactive", @"live"];
    NSString *typeStr = typeStrs[type];
    return typeStr;
}

- (NSString *)getAudioLevelString {
    NSInteger level = self.audioTypeSeg.selectedSegmentIndex;
    NSArray  *typeStrs = @[@"interactive", @"live"];
    NSString *typeStr = typeStrs[level];
    return typeStr;
}

- (void)shakeTip:(UIView *)view
{
    CGFloat t =4.0;
    CGAffineTransform translateRight = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
    CGAffineTransform translateLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);
    view.transform = translateLeft;
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        view.transform = translateRight;
    } completion:^(BOOL finished) {
        if(finished)
        {
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                view.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}

- (IBAction)onLogin:(UIButton *)btn {
    self.errTip.text = nil;
    
    if (!self.loginUser.isTeacher && self.classRoomTF.text.length == 0) {
        self.errTip.text = @"请输入课堂编号";
        [self shakeTip:self.classRoomTF];
        return;
    }
    
    if (self.userIdTF.text.length == 0) {
        self.errTip.text = @"请输入帐号";
        [self shakeTip:self.userIdTF];
        return;
    }
    
    if (self.userIdTF.text.length > 0 && (self.loginUser.isTeacher || (!self.loginUser.isTeacher && self.classRoomTF.text.length > 0))) {
        btn.userInteractionEnabled = NO;
        self.loginUser.userName = self.userIdTF.text;
        
        if (!self.loginUser.isTeacher) {
            self.loginUser.classIdString = self.classRoomTF.text;
        }
        [self login:self.userIdTF.text classId:self.classRoomTF.text completion:^(BOOL succ, NSString *msg) {
            btn.userInteractionEnabled = YES;
            if (!succ) {
                self.errTip.text = msg;
            }
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.hasJoinedClassRoom = succ;
        }];
        
    }
    
    
}

- (void)login:(NSString *)userid classId:(NSString *)classId completion:(void(^)(BOOL succ, NSString *msg))block {
    
    WEAKIFY(self);
    SignLoginRequest *logreq = [[SignLoginRequest alloc] initWithHandler:^(BaseRequest *request) {
        STRONGIFY_OR_RETURN(self);
        SignLoginResponse *resp = (SignLoginResponse *)request.response;
        
        self.loginUser.uid = userid;
        self.loginUser.cid = classId;
        [self enterRoomWithSign:resp.sign completion:block];
        
    } failHandler:^(BaseRequest *request, NSInteger code, NSString *errMsg) {
        
        if (block) {
            block(NO, errMsg);
        }

    }];
    logreq.uid = userid;
    logreq.cid = classId;
    
    logreq.role = self.loginUser.isTeacher;
    
    if (self.loginUser.isTeacher) {
        logreq.classType = [self getClassTypeString];
        logreq.audioLevel = self.audioTypeSeg.selectedSegmentIndex;
    }
    
    [[TICWebServiceEngine sharedEngine] asyncRequest:logreq wait:NO];

}

- (void)enterRoomWithSign:(NSString *_Nonnull)sign completion:(void(^)(BOOL succ, NSString *msg))block {
    // 可以复用
    [self switchUserRole:YES];
    
    TCICClassConfig *roomConfig = [TCICClassConfig configWithSign:sign];
    if (roomConfig) {
        
        self.loginUser.userId = roomConfig.userId;
        self.loginUser.userToken = roomConfig.token;
        self.loginUser.classIdString = @(roomConfig.classId).stringValue;
        self.loginUser.schoolId = (UInt32)roomConfig.schoolId;
        self.loginUser.classEndTime = (long)([[NSDate date] dateByAddingTimeInterval:3600*3].timeIntervalSince1970);
        
        
        
        [roomConfig setValue:kAppGroup forKey:@"appGroup"];
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        
        TCICClassController *vc = [TCICClassController classRoomWithConfig:roomConfig];
        if (vc) {
            [self.navigationController pushViewController:vc animated:YES];
            if (block) {
                block(YES, nil);
            }
        } else {
            if (block) {
                block(NO, @"参数错误");
            }
        }
    } else {
        if (block) {
            block(NO, @"参数错误");
        }
    }
    
    
}

- (IBAction)onTapToSwitchEnv:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
#if AppStoreRelease
        
#else
        BOOL isTeacher = self.loginUser.isTeacher;
        self.loginUser = [[TICUserInfo alloc] init];
        self.loginUser.isTeacher = !isTeacher;
        [self switchUserRole:YES];
        
#endif
    }
}


- (void)clearUserInfoOnSwitchEnv {
    BOOL isTeacher = self.loginUser.isTeacher;
    self.verTip.text = isTeacher ? @"老师版" : @"学生版";
    self.classRoomTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:(@"输入课堂编号") attributes: @{NSForegroundColorAttributeName:HexRGB(0x4B505A), NSFontAttributeName:self.classRoomTF.font }];
    [self.enterButton setTitle:isTeacher ? @"创建并加入课堂" : @"加入课堂" forState:UIControlStateNormal];
    
    self.userIdTF.text = @"";
    self.classRoomTF.text = @"";
    
    self.loginUser = [[TICUserInfo alloc] init];
    self.loginUser.isTeacher = isTeacher;
    self.loginUser.classType = self.classTypeSeg.selectedSegmentIndex;
    
}

- (IBAction)onClassTypeChanged:(UISegmentedControl *)sender {
    self.loginUser.classType = sender.selectedSegmentIndex;
}

- (IBAction)onAudioLevelChanged:(UISegmentedControl *)sender {
    self.loginUser.audioLevel = sender.selectedSegmentIndex;
}

- (IBAction)onTapBlank:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    }
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)note {
//    if (_containerView) {
//
//        NSDictionary *info = note.userInfo;
//        CGSize keyboardSize = [[info objectForKeyedSubscript:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//        CGRect frame = _containerView.frame;
//        CGRect enterFrame = _enterButton.frame;
//
//        CGFloat offset = (frame.origin.y + enterFrame.origin.y + enterFrame.size.height) - (self.view.bounds.size.height - keyboardSize.height);
//        if (offset > 0) {
//            CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
//            if (kIsIPad) {
//                [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
//                    make.centerY.mas_equalTo(self.view.mas_centerY).offset(-offset-20);
//                }];
//            } else {
//                // iPhone
//                [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
//                    if (@available(iOS 11.0, *)) {
//                        make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
//                    } else {
//                        make.top.mas_equalTo(self.view.mas_top).offset(20);
//                    }
//
//                }];
//            }
//            [UIView animateWithDuration:duration animations:^{
//                [self.containerView layoutIfNeeded];
//            }];
//
//        }
//
//    }
    
}

//当键盘消失时调用
- (void)keyboardWillHide:(NSNotification *)note {
//    if (_containerView ) {
//        NSDictionary *info = note.userInfo;
//        CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
//        if (kIsIPad) {
//            [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.centerY.mas_equalTo(self.view.mas_centerY);
//            }];
//        } else {
//            // iPhone
//            [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
//                if (@available(iOS 11.0, *)) {
//                    make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(100);
//                } else {
//                    make.top.mas_equalTo(self.view.mas_top).offset(100);
//                }
//                
//            }];
//        }
//        
//        [UIView animateWithDuration:duration animations:^{
//            [self.containerView layoutIfNeeded];
//        }];
//    }
    
}


@end
