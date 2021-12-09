//
//  RenderView.m
//  TYIC_Web_Demo
//
//  Created by 陈耀武 on 2021/1/1.
//  Copyright © 2021 陈耀武. All rights reserved.
//

#import "RenderView.h"
#import <Masonry/Masonry.h>
#import "UIImage+TintColor.h"
#import "UIColor+MLPFlatColors.h"
#import <YYModel/YYModel.h>

@interface RenderView ()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIView  *floatBgView;

@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) UIButton *muteAudioBtn;
@property (nonatomic, strong) UIButton *muteVideoBtn;

@property (nonatomic, strong) UIButton *subFullBtn;


@end

@implementation RenderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:12.f];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.backgroundColor = [UIColor lightGrayColor];
        _nameLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_nameLabel];
        
        [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom);
            make.left.equalTo(self.mas_left).offset(5);
            make.width.equalTo(self.mas_width).offset(-10);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
        [pan requireGestureRecognizerToFail:tap];
        [self addGestureRecognizer:pan];
        
        _floatBgView = [[UIView alloc] init];
        _floatBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _floatBgView.hidden = YES;
        [self addSubview:_floatBgView];
        
        CGSize imgSize = CGSizeMake(16, 16);
        self.resetBtn = [self createBtn:@selector(onRestore:) image:[UIImage imageOfColor:[UIColor flatRedColor] size:imgSize] title:@"RE" selectedImg:nil selectedTitle:nil];
        [_floatBgView addSubview:self.resetBtn];
        
        self.muteAudioBtn = [self createBtn:@selector(onMuteAudio:) image:[UIImage imageOfColor:[UIColor flatGreenColor] size:imgSize] title:@"MA" selectedImg:[UIImage imageOfColor:[UIColor flatDarkGreenColor] size:imgSize] selectedTitle:@"EA"];
        [_floatBgView addSubview:self.muteAudioBtn];
        
        self.muteVideoBtn = [self createBtn:@selector(onMuteVideo:) image:[UIImage imageOfColor:[UIColor flatBlueColor] size:imgSize] title:@"MV" selectedImg:[UIImage imageOfColor:[UIColor flatDarkBlueColor] size:imgSize] selectedTitle:@"EV"];
        [_floatBgView addSubview:self.muteVideoBtn];
        
       
        
        
        [_floatBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.center);
        }];
        
        CGSize size = CGSizeMake(32, 32);
           NSInteger spacing = 3;
        [self.muteVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(size);
            make.top.equalTo(self.floatBgView.mas_top).offset(spacing);
            make.bottom.equalTo(self.floatBgView.mas_bottom).offset(-spacing);
            make.trailing.equalTo(self.floatBgView.mas_trailing).offset(-spacing);
        }];
        
        [self.muteAudioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(size);
            make.top.equalTo(self.floatBgView.mas_top).offset(spacing);
            make.bottom.equalTo(self.floatBgView.mas_bottom).offset(-spacing);
            make.right.equalTo(self.muteVideoBtn.mas_left).offset(-spacing);
        }];
        
        self.resetBtn.hidden = YES;
        [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.top.equalTo(self.floatBgView.mas_top).offset(spacing);
            make.bottom.equalTo(self.floatBgView.mas_bottom).offset(-spacing);
            make.right.equalTo(self.muteAudioBtn.mas_left).offset(-spacing);
            make.left.equalTo(self.floatBgView.mas_left).offset(spacing);
        }];
        
        self.subFullBtn = [[UIButton alloc] init];
        [self.subFullBtn setBackgroundImage:[UIImage imageOfColor:[UIColor flatYellowColor] size:imgSize] forState:UIControlStateNormal];
        [self.subFullBtn setTitle:@"F" forState:UIControlStateNormal];
        [self.subFullBtn setTitle:@"f" forState:UIControlStateSelected];
        [self.subFullBtn addTarget:self action:@selector(onSubFull:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.subFullBtn];
        
        [self.subFullBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(size);
            make.bottom.equalTo(self.mas_bottom).offset(-20);
            make.right.equalTo(self.mas_right);
        }];
        
    }
    return self;
}

- (void)setViewType:(TCICUIRenderType)viewType {
    [super setViewType:viewType];
    self.subFullBtn.hidden = viewType != TCICUIRender_Sub;
}

- (void)onSubFull:(UIButton *)btn {
    btn.selected = !btn.selected;
    NSNotification *notify = [NSNotification notificationWithName:@"SubRenderToFull" object:@(btn.selected)];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
}


- (void)onTapGesture:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateRecognized) {
        if (self.floatBgView.hidden) {
            self.floatBgView.hidden = NO;
            [self relayoutFloatView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.floatBgView.hidden = YES;
            });
        }
    }
}

- (void)onPanGesture:(UIPanGestureRecognizer *)pan {
    if (self.viewType != TCICUIRender_Sub) {
        if (pan.state == UIGestureRecognizerStateBegan) {
               self.isDraged = YES;
               if (!self.floatBgView.hidden) {
                   [self relayoutFloatView];
               }
               NSNotification *notify = [NSNotification notificationWithName:@"RenderViewDraging" object:nil];
               [[NSNotificationCenter defaultCenter] postNotification:notify];
           } else if (pan.state == UIGestureRecognizerStateChanged) {
               CGPoint point = [pan locationInView:self.superview];
               UIScreen *screen = [UIScreen mainScreen];
               if ((screen.bounds.size.width - point.x) < self.bounds.size.width/2) {
                   point.x = screen.bounds.size.width - self.bounds.size.width/2;
               } else if (point.x < self.bounds.size.width/2) {
                   point.x  = self.bounds.size.width/2;
               }
               
               if ((screen.bounds.size.height - point.y) < self.bounds.size.height/2) {
                   point.y = screen.bounds.size.height - self.bounds.size.height/2;
               } else if (point.y < self.bounds.size.height/2) {
                   point.y = self.bounds.size.height/2;
               }
               self.center = point;
           }
    }
   
}

- (void)relayoutFloatView {
    CGSize size = CGSizeMake(32, 32);
    self.resetBtn.hidden = !self.isDraged;

    [self.resetBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        if (self.isDraged) {
            make.width.mas_equalTo(size.width);
        } else {
            make.width.mas_equalTo(0);
        }
    }];
    
    
}

- (void)onRestore:(UIButton *)btn {
    self.isDraged = !self.isDraged;
    if (!self.floatBgView.hidden) {
        [self relayoutFloatView];
    }
    NSNotification *notify = [NSNotification notificationWithName:@"RenderViewDraging" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
}

- (void)onMuteAudio:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    NSDictionary *dic = @{
        @"userId" : self.userId,
        @"viewType" : @(self.viewType),
        @"isDraged" : @(self.isDraged),
        @"muteAudio" : @(btn.selected),
    };
    
    NSNotification *notify = [NSNotification notificationWithName:@"RenderViewSendMsg" object:[dic yy_modelToJSONString]];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
    
}

- (void)onMuteVideo:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    NSDictionary *dic = @{
        @"userId" : self.userId,
        @"viewType" : @(self.viewType),
        @"isDraged" : @(self.isDraged),
        @"muteVideo" : @(btn.selected),
    };
    
    NSNotification *notify = [NSNotification notificationWithName:@"RenderViewSendMsg" object:[dic yy_modelToJSONString]];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
}

- (UIButton *)createBtn:(SEL)selector image:(UIImage *)normalImg title:(NSString *)normalTitle selectedImg:(UIImage *)selImg selectedTitle:(NSString *)selectedTitle {
    
    UIButton *btn = [[UIButton alloc] init];
    if (selector) {
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (normalImg) {
        [btn setImage:normalImg forState:UIControlStateNormal];
    }
    if (normalTitle) {
        [btn setTitle:normalTitle forState:UIControlStateNormal];
    }
    
    if (selImg) {
        [btn setImage:selImg forState:UIControlStateSelected];
    }
    if (selectedTitle) {
        [btn setTitle:selectedTitle forState:UIControlStateSelected];
    }
    
    btn.titleLabel.font = [UIFont systemFontOfSize:10];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    //使图片和文字水平居中显示
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    //文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0 , 8, 16, 0.0)];
    
    //图片距离右边框距离减少图片的宽度，其它不边
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(16, -16, 0, 0)];
    
    NSLog(@"%@", btn);
    return btn;
}

- (void)setUserId:(NSString *)userId {
    [super setUserId:userId];
    _nameLabel.text = userId;
}

@end
