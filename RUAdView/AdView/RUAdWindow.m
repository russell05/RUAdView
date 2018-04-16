//
//  RUAdWindow.m
//  RUAdView
//
//  Created by russ on 2018/4/12.
//  Copyright © 2018年 russell. All rights reserved.
//

#import "RUAdWindow.h"

@implementation RUAdWindow

#pragma mark Public method

- (void) show
{
    adView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    adView.alpha = 1.0f;
    adView.count = 5;
    self.hidden = NO;
    [self makeKeyWindow];
}

- (void) dismiss
{
    adView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    void (^animation)(void) = ^() {
        adView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        adView.alpha = .5f;
    };
    void (^finish)(BOOL) = ^(BOOL result) {
        self.hidden = YES;
    };
    [UIView animateWithDuration:.5f animations:animation completion:finish];
}

#pragma mark -
#pragma mark Object initialization

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.windowLevel = UIWindowLevelNormal+10;
        
        adView = [[RUAdView alloc] initWithFrame:self.bounds];
        adView.delegate = self;
        adView.startUpType = RUAdViewStartUpTypeHot;
        [self addSubview:adView];
    }
    return self;
}

#pragma mark -
#pragma mark RUAdViewDelegate

- (void) adViewClickAction
{
    [self dismiss];
}

@end
