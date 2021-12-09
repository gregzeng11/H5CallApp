//
//  TICPrivacyViewController.h
//  TIC_SaaS
//
//  Created by jameskhdeng(邓凯辉) on 2019/9/11.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TICVoidBlock)(void);
@interface TICPrivacyViewController : UIViewController

@property (nonatomic, copy) NSString *loadUrl;
@property (nonatomic, copy) TICVoidBlock completionBlock;

- (instancetype)initWithCompletion:(TICVoidBlock)completion;
@end

NS_ASSUME_NONNULL_END
