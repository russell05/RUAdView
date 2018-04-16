//
//  RUAdWindow.h
//  RUAdView
//
//  Created by russ on 2018/4/12.
//  Copyright © 2018年 russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RUAdView.h"

@interface RUAdWindow : UIWindow <AdViewDelegate> {
    RUAdView *adView;
}

- (void) show;
- (void) dismiss;

@end
