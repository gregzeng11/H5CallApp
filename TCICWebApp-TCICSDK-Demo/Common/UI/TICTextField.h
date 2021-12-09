//
//  TICTextField.h
//  TIC_SaaS
//
//  Created by jameskhdeng(邓凯辉) on 2019/7/19.
//  Copyright © 2019 Tencent. All rights reserved.
//  自定义带下划线的 TextField

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TICTextField : UITextField
@property (nonatomic, assign) BOOL isHighlight;     //!< 是否高亮

- (void)setLeftImage:(UIImage *)image;
@end

//@interface TXTextField : UITextField
//
//@end

NS_ASSUME_NONNULL_END
