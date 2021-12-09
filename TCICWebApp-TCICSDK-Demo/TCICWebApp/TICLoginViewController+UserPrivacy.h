//
//  TICLoginViewController+UserPrivacy.h
//  TYICWebApp
//
//  Created by 陈耀武 on 2021/2/24.
//  Copyright © 2021 陈耀武. All rights reserved.
//

#import "TICLoginViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TCICUserPrivacyBlock)(void);

@interface TICLoginViewController (UserPrivacy)<UITextViewDelegate>

- (void)showUserAlert;

@end

NS_ASSUME_NONNULL_END
