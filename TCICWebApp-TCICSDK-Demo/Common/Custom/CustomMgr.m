//
//  CustomMgr.m
//  TYIC_Web_Demo
//
//  Created by 陈耀武 on 2021/1/1.
//  Copyright © 2021 陈耀武. All rights reserved.
//

#import "CustomMgr.h"
#import <TCICSDK/TCICTRTCVideoView.h>
#import "RenderPanel.h"
#import "RenderView.h"

#import <Masonry/Masonry.h>
@interface CustomMgr ()

@property (nonatomic, strong) RenderPanel *videoPanel;
@property (nonatomic, strong) RenderPanel *screenPanel;
@property (nonatomic, assign) CGRect videoPanelRect;

@end

#define kVideoTop 50
#define kVPadding 5
#define kVideoPanelHeight 130

@implementation CustomMgr

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (Class)renderViewClass {
    return [RenderView class];
}

/// onKeyboardWillShow and onKeyBoardHidden 为 TCICVideoContainerMgr 内部方法，此处可直接重写
- (void)onKeyboardWillShow:(NSNotification *)note {
    
    //    NSLog(@"onKeyboardWillShow : %@", note);
    NSDictionary *info = note.userInfo;
    CGSize keyboardSize = [[info objectForKeyedSubscript:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat height = keyboardSize.height;
    
    for (UIView<TCICUIRenderView> *item in self.videoPanel.subviews) {
        if ([item isKindOfClass:[TCICTRTCVideoView class]]) {
            TCICTRTCVideoView *view = (TCICTRTCVideoView *)item;
            if (CGRectIsEmpty(view.rectWithoutKeyboard)) {
                CGRect rect = item.frame;
                view.rectWithoutKeyboard = rect;
                rect.origin.y -= height;
                item.frame = rect;
            }
        }
    }
    
    for (UIView<TCICUIRenderView> *item in self.screenPanel.subviews) {
        if ([item isKindOfClass:[TCICTRTCVideoView class]]) {
            TCICTRTCVideoView *view = (TCICTRTCVideoView *)item;
            if (CGRectIsEmpty(view.rectWithoutKeyboard)) {
                CGRect rect = item.frame;
                view.rectWithoutKeyboard = rect;
                rect.origin.y -= height;
                item.frame = rect;
            }
        }
    }
    
}

/// 键盘将要隐藏
- (void)onKeyBoardHidden:(NSNotification *)note {
    //    NSLog(@"onKeyboardWillShow Hidden  : %@", note);
    for (UIView<TCICUIRenderView> *item in self.videoPanel.subviews) {
        if ([item isKindOfClass:[TCICTRTCVideoView class]]) {
            TCICTRTCVideoView *view = (TCICTRTCVideoView *)item;
            if (!CGRectIsNull(view.rectWithoutKeyboard)) {
                view.frame = view.rectWithoutKeyboard;
                view.rectWithoutKeyboard = CGRectZero;
            }
        }
    }
    
    for (UIView<TCICUIRenderView> *item in self.screenPanel.subviews) {
        if ([item isKindOfClass:[TCICTRTCVideoView class]]) {
            TCICTRTCVideoView *view = (TCICTRTCVideoView *)item;
            if (!CGRectIsNull(view.rectWithoutKeyboard)) {
                view.frame = view.rectWithoutKeyboard;
                view.rectWithoutKeyboard = CGRectZero;
            }
        }
    }
}


- (instancetype)init {
    if (self = [super init]) {
        self.screenPanel = [[RenderPanel alloc] init];
        self.videoPanel = [[RenderPanel alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDragingRenderView) name:@"RenderViewDraging" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResetAllRenderView) name:@"ResetAllRenderView" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSubRenderToFull:) name:@"SubRenderToFull" object:nil];
    }
    return self;
}
- (void)onDragingRenderView {
    [self dyncRelayoutVideoPanel];
}

- (void)onResetAllRenderView {
    for (RenderView *view in self.videoPanel.subviews) {
        view.isDraged = NO;
    }
    [self dyncRelayoutVideoPanel];
}

- (void)onSubRenderToFull:(NSNotification *)notify {
    NSNumber *number = (NSNumber *)notify.object;
    
    if (number.boolValue) {
        self.screenPanel.frame = self.screenPanel.superview.bounds;
    } else {
        CGRect rect = self.screenPanel.superview.bounds;
        rect.origin.y += kVideoTop;
        rect.size.height -= kVideoTop;
        rect.size.width -= kVideoPanelHeight + 50;
        self.screenPanel.frame = rect;
    }
}

- (void)onInitUserLayout:(NSDictionary *_Nullable)allInfo controllerView:(UIView *_Nonnull)view {
    NSDictionary *extInfo = allInfo[@"extInfo"];
    if (extInfo) {
        
        CGRect bounds = view.bounds;
        
        {
            if (self.screenPanel == nil) {
                self.screenPanel = [[RenderPanel alloc] init];
                self.screenPanel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
#if DEBUG
#else
                self.screenPanel.alpha = 0;
#endif
            }
            
            if (view && self.screenPanel.superview == nil) {
                [view addSubview:self.screenPanel];
            }
            self.screenPanel.frame = bounds;
            
        }
        
        {
            CGRect rect = view.bounds;
            rect.origin.y = kVideoTop;
            rect.size.height = kVideoPanelHeight;
            if (self.videoPanel == nil) {
                self.videoPanel = [[RenderPanel alloc] init];
                self.videoPanel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
#if DEBUG
#else
                self.videoPanel.alpha = 0;
#endif
            }
            if (view && self.videoPanel.superview == nil) {
                [view addSubview:self.videoPanel];
            }
            
            self.videoPanel.frame = bounds;
            self.videoPanelRect = rect;
        }
        
    }
}


- (UIView<TCICUIRenderView> *_Nullable)renderViewOf:(NSString * _Nullable)userid viewType:(TCICUIRenderType)avType {
    if (avType == TCICUIRender_Sub) {
        for (TCICTRTCVideoView *item in self.screenPanel.subviews) {
            if ([item.userId isEqualToString:userid]) {
                return item;
            }
        }
    } else {
        for (TCICTRTCVideoView *item in self.videoPanel.subviews) {
            if ([item.userId isEqualToString:userid]) {
                return item;
            }
        }
    }
    
    return nil;
}

- (void)onAddOrUpdateUserLayout:(NSString *_Nullable)userId viewType:(TCICUIRenderType)avType extInfo:(NSDictionary *_Nullable)allInfo offset:(CGPoint)offset controllerView:(UIView *_Nonnull)view stubView:(UIView *_Nonnull)stubView{
    UIView<TCICUIRenderView> *renderView = (UIView<TCICUIRenderView> *)[self renderViewOf:userId viewType:avType];
    if (renderView == nil) {
        Class cls = self.renderViewClass;
        renderView = [[cls alloc] init];
        // 辅路
        if (avType == TCICUIRender_Sub) {
            if (self.screenPanel.superview == nil) {
                CGRect rect = view.bounds;
                rect.origin.y += kVideoTop;
                rect.size.height -= kVideoTop;
                rect.size.width -= kVideoPanelHeight + 50;
                self.screenPanel.frame = rect;
                if (self.videoPanel.superview != nil) {
                    [view insertSubview:self.screenPanel belowSubview:self.videoPanel];
                } else {
                    [view insertSubview:self.screenPanel belowSubview:stubView];
                }
            }
            [self.screenPanel addSubview:renderView];
            [renderView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.screenPanel.mas_left);
                make.right.equalTo(self.screenPanel.mas_right);
                make.top.equalTo(self.screenPanel.mas_top);
                make.bottom.equalTo(self.screenPanel.mas_bottom);
            }];
        } else {
            if (self.videoPanel.superview == nil) {
                CGRect rect = view.bounds;
                rect.origin.y += kVideoTop;
                rect.size.height = kVideoPanelHeight;
                self.videoPanelRect = rect;
                self.videoPanel.frame = view.bounds;
                
                if (self.screenPanel.superview != nil) {
                    [view insertSubview:self.screenPanel aboveSubview:self.screenPanel];
                } else {
                    [view insertSubview:self.videoPanel belowSubview:stubView];
                }
            }
            [self.videoPanel addSubview:renderView];
        }
        
    }
    
    renderView.userId = userId;
    renderView.viewType = avType;
    
    if (avType == TCICUIRender_Sub) {
        renderView.frame = self.screenPanel.bounds;
    } else {
        [self dyncRelayoutVideoPanel];
    }
}

- (NSInteger)notDragedViewCount {
    NSInteger count = 0;
    for (RenderView *view in self.videoPanel.subviews) {
        if (!view.isDraged) {
            count++;
        }
    }
    return count;
}

- (RenderView *)firstNotDragView {
    RenderView *retView = nil;
    for (RenderView *view in self.videoPanel.subviews) {
        if (!view.isDraged) {
            retView = view;
            break;
        }
    }
    return retView;
}

- (void)dyncRelayoutVideoPanel {
    CGRect panelRect = self.videoPanelRect;
    CGFloat height = panelRect.size.height - 2*kVPadding;
    CGSize itemSize = CGSizeMake(height * 4/3, height);
    
    NSInteger size = [self notDragedViewCount];
    
    CGFloat hor = (panelRect.size.width - size * itemSize.width)/(size + 1);
    if (hor < kVPadding) {
        hor = 2*kVPadding;
        CGRect rect = CGRectMake(hor, panelRect.origin.y + kVPadding, itemSize.width, itemSize.height);
        
        UIView *view = [self firstNotDragView];
        view.frame = rect;
        
        rect.origin.x += rect.size.width + hor;
        panelRect.origin.x = rect.origin.x;
        panelRect.size.width -= rect.origin.x;
        
        CGRect itemRect = rect;
        height = (panelRect.size.height - 3*kVPadding)/2;
        itemSize = CGSizeMake(height * 4/3, height);
        itemRect.size = itemSize;
        
        int count = panelRect.size.width/itemSize.width;
        hor = (panelRect.size.width - count*itemSize.width)/count;
        
        hor = (hor*count + 4*kVPadding)/(count + 2);
        CGFloat offset = (4*kVPadding - 2*hor);
        panelRect.origin.x -= offset;
        panelRect.size.width += offset;
        itemRect.origin.x -= offset;
        
        CGRect frect = view.frame;
        frect.origin.x -= offset/2;
        rect.origin.x -= offset;
        view.frame = frect;
        
        for(int i = 1; i < self.videoPanel.subviews.count; i++) {
            RenderView *view = self.videoPanel.subviews[i];
            if (!view.isDraged) {
                if (itemRect.origin.x + itemSize.width > panelRect.origin.x + panelRect.size.width) {
                    itemRect.origin.y += itemRect.size.height + kVPadding;
                    itemRect.origin.x = rect.origin.x;
                }
                
                view.frame = itemRect;
                itemRect.origin.x += itemRect.size.width + hor;
            }
        }
        
        
    } else {
        CGRect rect = CGRectMake(hor, panelRect.origin.y + kVPadding, itemSize.width, itemSize.height);
        for (RenderView *view in self.videoPanel.subviews) {
            if (!view.isDraged) {
                view.frame = rect;
                rect.origin.x += rect.size.width + hor;
            }
        }
    }
    [self.videoPanel layoutSubviews];
    
}

- (void)onRemoveUserLayout:(NSString *)userId viewType:(TCICUIRenderType)avType extInfo:(NSDictionary *)extInfo controllerView:(UIView *)view {
    
    UIView *renderView = [self renderViewOf:userId viewType:avType];
    if (renderView) {
        [renderView removeFromSuperview];
    }
    
    if (avType == TCICUIRender_Sub) {
        
    } else {
        [self dyncRelayoutVideoPanel];
    }
}



- (void)safeRunInMain:(void (^)(CustomMgr *mgr))block {
    if (block) {
        if ([NSThread isMainThread]) {
            block(self);
        } else {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf == nil) {
                    return;
                }
                block(weakSelf);
            });
        }
    }
}

@end
