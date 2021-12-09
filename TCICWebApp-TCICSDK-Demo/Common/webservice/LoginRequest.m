//
//  LoginRequest.m
//  TIC_Web_SaaS
//
//  Created by AlexiChen on 2020/5/14.
//  Copyright © 2020 AlexiChen. All rights reserved.
//

#import "LoginRequest.h"
#import <YYModel/YYModel.h>




@implementation SignLoginRequest

- (NSString *)url {
    return @"https://tcic-demo.qcloudtiw.com/api/signLogin";
}

- (BOOL)needSign {
    return NO;
}


- (BOOL)needRandom {
    return NO;
}

- (NSDictionary *)packageParams {
    
    NSDate *date = [NSDate date];
    date = [date dateByAddingTimeInterval:10];
    NSDate *endData = [date dateByAddingTimeInterval:3600*3];

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.uid.length > 0) {
        [dic setValue:self.uid forKey:@"user_id"];
        [dic setValue:self.uid forKey:@"nickname"];
}

    if (self.cid.length > 0) {
        [dic setValue:self.cid forKey:@"class_id"];
        }
    [dic setValue:self.env.length > 0 ? self.env : @"prod" forKey:@"env"];
    [dic setValue:@(@(date.timeIntervalSince1970).longValue) forKey:@"start_time"];
    [dic setValue:@(@(endData.timeIntervalSince1970).longValue) forKey:@"end_time"];
    [dic setValue:self.role?@(1):@(0) forKey:@"role"];
        
    if (self.role == 1) {
        [dic setValue:@(1) forKey:@"auto_open_mic"];
        [dic setValue:self.classType forKey:@"class_sub_type"];
        if ([self.classType.lowercaseString isEqual:@"live"]) {
            [dic setValue:@(1) forKey:@"class_type"];
            [dic setValue:@"1" forKey:@"max_rtc_member"];
        } else {
        [dic setValue:@"10" forKey:@"max_rtc_member"];
        }
        [dic setValue:@(self.audioLevel) forKey:@"audio_quality"];
    }
        
    return dic;
    
}

- (Class)responseClass {
    return [SignLoginResponse class];
}

- (void)parseResponseInner:(NSString *)respJsonString {
    if (respJsonString.length >0 ) {
        NSDictionary *dic = nil;
        NSData *jsonData =  [respJsonString dataUsingEncoding : NSUTF8StringEncoding];
        if (jsonData) {
            dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
            if (![dic isKindOfClass:[NSDictionary class]]) dic = nil;
        }
        
        if (dic[@"res"]) {
            BaseResponse *resp = [[self responseClass] yy_modelWithJSON:dic[@"res"]];
            self.response = resp;
        } else {
            self.response = [[self responseClass] yy_modelWithJSON:dic];
        }
    }
}

@end


@implementation SignLoginResponse



@end
