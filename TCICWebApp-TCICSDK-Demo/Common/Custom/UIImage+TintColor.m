//
//  UIImage+TintColor.m
//  TintColor
//
//  Created by Alexi on 13-9-23.
//  Copyright (c) 2013年 ywchen. All rights reserved.
//

#import "UIImage+TintColor.h"
#import "UIColor+MLPFlatColors.h"

@implementation UIImage (TintColor)


- (UIImage *)imageOfTintColor:(UIColor *)tintColor
{
    return [self imageOfTintColor:tintColor blendMode:kCGBlendModeDestinationIn];
}

- (UIImage *)imageOfGradientTintColor:(UIColor *)tintColor
{
    return [self imageOfTintColor:tintColor blendMode:kCGBlendModeOverlay];
}

- (UIImage *)imageOfTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode
{
    if (!tintColor) {
        return self;
    }
    
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn)
    {
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (UIImage *)imageOfColor:(UIColor *)color
{
    return [UIImage imageOfColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageOfColor:(UIColor *)color size:(CGSize)size
{
    if (color == nil) {
        return nil;
    }
    
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)imageOfRandomColor:(CGSize)size
{
    UIColor *randomColor = [UIColor randomFlatColor];
    return [UIImage imageOfColor:randomColor size:size];
}




@end
