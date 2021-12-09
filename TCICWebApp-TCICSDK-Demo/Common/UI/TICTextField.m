//
//  TICTextField.m
//  TIC_SaaS
//
//  Created by jameskhdeng(邓凯辉) on 2019/7/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TICTextField.h"
#import "ComMarco.h"

@implementation TICTextField

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    if (self.isHighlight) {
        CGContextSetFillColorWithColor(context, HexRGB(0x0A818C).CGColor);
    } else {
        CGContextSetFillColorWithColor(context, HexRGB(0x4B505A).CGColor);
    }
    CGContextFillRect(context, CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1));
    if (self.enabled) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.5].CGColor);
    }
    CGRect drawrect = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 2);
    if (self.leftView != nil) {
        drawrect.origin.x += self.leftView.frame.origin.x + self.leftView.frame.size.width - 8;
        drawrect.size.width -= self.leftView.frame.origin.x + self.leftView.bounds.size.width - 8;
    }
    
    CGContextFillRect(context, drawrect);
    UIGraphicsPopContext();
    
    
}

- (void)setIsHighlight:(BOOL)isHighlight {
    _isHighlight = isHighlight;
    [self setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self setNeedsDisplay];
}

- (void)setLeftImage:(UIImage *)image {
    if (image) {
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, self.bounds.size.height)];
        UIImageView *leftImg = [[UIImageView alloc] init];
        leftImg.image = image;
        CGRect rect = leftView.bounds;
        rect = CGRectInset(rect, (rect.size.width - image.size.width/2)/2, (rect.size.height - image.size.height/2)/2);
        rect.origin.x = 0;
        leftImg.frame = rect;
        [leftView addSubview:leftImg];
        leftImg.center = leftImg.center;
        self.leftView = leftView;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
    
}

- (BOOL)becomeFirstResponder {
    BOOL ret = [super becomeFirstResponder];
    self.isHighlight = YES;
    return ret;
}

- (BOOL)resignFirstResponder{
    BOOL ret = [super resignFirstResponder];
    self.isHighlight = NO;
    return ret;
}

@end

//@implementation TXTextField
//
//- (CGRect)textRectForBounds:(CGRect)bounds {
//    if (!self.isFirstResponder) {
//        return bounds;
//    }
//    return CGRectInset(bounds, 8, 0);
//}
//- (CGRect)editingRectForBounds:(CGRect)bounds {
//    return CGRectInset(bounds, 8, 0);
//}
//
//- (CGRect)placeholderRectForBounds:(CGRect)bounds {
//    return CGRectInset(bounds, 8, 0);
//}
//
//- (CGRect)rightViewRectForBounds:(CGRect)bounds{
//
//    CGRect rect = CGRectInset(bounds, 0, 0);
//    rect.origin.x += rect.size.width - rect.size.height;
//    rect.size.width = rect.size.height;
//    return rect;
//}
//
//@end
