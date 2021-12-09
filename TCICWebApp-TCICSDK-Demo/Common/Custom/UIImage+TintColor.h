//
//  UIImage+TintColor.h
//  TintColor
//
//  Created by Alexi on 13-9-23.
//  Copyright (c) 2013年 ywchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TintColor)

+ (UIImage *)imageOfColor:(UIColor *)color;
+ (UIImage *)imageOfColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageOfRandomColor:(CGSize)size;

// tint只对里面的图案作更改颜色操作
- (UIImage *)imageOfTintColor:(UIColor *)tintColor;
- (UIImage *)imageOfTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;
- (UIImage *)imageOfGradientTintColor:(UIColor *)tintColor;


@end
