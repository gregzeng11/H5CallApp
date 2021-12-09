//
//  ComMarco.h
//  TIC_Web_SaaS
//
//  Created by AlexiChen on 2020/4/23.
//  Copyright © 2020 AlexiChen. All rights reserved.
//

#ifndef ComMarco_h
#define ComMarco_h

#define WEAKIFY(x) __weak __typeof(x) weak_##x = x
#define STRONGIFY_OR_RETURN(x) __strong __typeof(weak_##x) x = weak_##x; if (x == nil) {return;};

#define SAFE_RUN_IN_MAIN(block, ...) \
if(block){ \
if([NSThread isMainThread]){ \
block(__VA_ARGS__); \
} \
else{ \
dispatch_async(dispatch_get_main_queue(), ^{ \
block(__VA_ARGS__); \
}); \
} \
}

// 颜色相关宏
#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HexRGBA(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF000000) >> 24))/255.0 green:((float)((rgbValue & 0x00FF0000) >> 16))/255.0 blue:((float)((rgbValue & 0x0000FF00) >> 8))/255.0 alpha:((float)(rgbValue & 0x000000FF))/255.0]
#define UIColorRGB(r,g,b) [UIColor colorWithRed:(float)(r/255.0) green:(float)(g/255.0) blue:(float)(b/255.0) alpha:1.0]
#define UIColorRGBA(r,g,b,a) [UIColor colorWithRed:(float)(r/255.0) green:(float)(g/255.0) blue:(float)(b/255.0) alpha:a]

#ifndef kIsIPhone
#define kIsIPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define kIsIPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#endif

//#define kErrorTip(fmt, ...) [NSString stringWithFormat:@"%s Line %d"fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]
//#define kErrorTip2(msg) [NSString stringWithFormat:@"%s Line %d : %@", __PRETTY_FUNCTION__, __LINE__, msg]


#if DEBUG
#define DebugLog(fmt, ...) NSLog((@"applog : [%p] %s Line %d : " fmt), [NSThread currentThread], __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DebugLog(fmt, ...) // NSLog((@"web_apilog : [%p] %s Line %d : " fmt), [NSThread currentThread], __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#endif


#define kDefaultEnvNameKey       @"PRE"

// AppStore发布时，改成1
#define AppStoreRelease 0

#if AppStoreRelease

#undef kDefaultEnvNameKey
#define kDefaultEnvNameKey       @"PRE"

#endif

#define kAppGroup @"group.com.tencent.screenshare"

//#define kAppGroup @"group.com.tencent.tic.courseinair"

#define TCIC_DEVOPS_BUILD_NO 0


#endif /* ComMarco_h */
