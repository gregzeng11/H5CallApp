//
//  ToolPanel.m
//  TYIC_Web_Demo
//
//  Created by 陈耀武 on 2021/1/1.
//  Copyright © 2021 陈耀武. All rights reserved.
//

#import "ToolPanel.h"


@interface ToolPanel ()
@property (nonatomic, weak) UIButton *resetAll;
@end

@implementation ToolPanel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIButton *btn = [[UIButton alloc] init];
        btn.backgroundColor = [UIColor blueColor];
        [btn setTitle:@"All" forState:UIControlStateNormal];
        [self addSubview:btn];
        self.resetAll = btn;
    
        [btn addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)onClick:(UIButton *)btn {
    // NSLog(@"ToolPanel->onClick");
    NSNotification *notify = [NSNotification notificationWithName:@"ResetAllRenderView" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.resetAll.frame = CGRectInset(self.bounds, 5, 5);
}
@end
