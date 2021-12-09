//
//  ClassViewController.m
//  TYIC_Web_Demo
//
//  Created by 陈耀武 on 2021/1/1.
//  Copyright © 2021 陈耀武. All rights reserved.
//

#import "ClassViewController.h"
#import "ToolPanel.h"
#import <Masonry/Masonry.h>

@interface ClassViewController ()

@property (nonatomic, strong) ToolPanel *toolPanel;

@end

@implementation ClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.toolPanel = [[ToolPanel alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.toolPanel.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.toolPanel];
    
    [self.toolPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}



@end
