//
//  TICPrivacyViewController.m
//  TIC_SaaS
//
//  Created by jameskhdeng(邓凯辉) on 2019/9/11.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TICPrivacyViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>

@interface TICPrivacyViewController ()
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *backButton;    
@end

@implementation TICPrivacyViewController

- (instancetype)init {
    if (self = [super init]) {
        self.loadUrl = @"https://www.qq.com/privacy.htm";
    }
    return self;
}

- (instancetype)initWithCompletion:(TICVoidBlock)completion {
    if (self = [super init]) {
        self.loadUrl = @"https://www.qq.com/privacy.htm";
        self.completionBlock = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    [self.view addSubview:self.webView];
    [self.view addSubview:self.backButton];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30.f);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(15.f);
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(15.f);
        } else {
            make.left.equalTo(self.view).offset(15.f);
            make.top.equalTo(self.view).offset(15.f);
        }
    }];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)onBack {
    [self dismissViewControllerAnimated:YES completion:self.completionBlock];
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        NSURL *url = [NSURL URLWithString:self.loadUrl];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    return _webView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:[UIImage imageNamed:@"about_quit"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"about_quit"] forState:UIControlStateSelected];
    }
    return _backButton;
}

@end
