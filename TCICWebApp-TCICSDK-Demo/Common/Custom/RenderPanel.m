//
//  RenderPanel.m
//  TYIC_Web_Demo
//
//  Created by 陈耀武 on 2021/1/1.
//  Copyright © 2021 陈耀武. All rights reserved.
//

#import "RenderPanel.h"

@implementation RenderPanel

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if(hitView == self){
        
        return nil;
        
    }
    
    return hitView;
    
}



@end
