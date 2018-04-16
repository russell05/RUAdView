//
//  RUAdView.h
//  RUAdView
//
//  Created by russ on 2018/4/12.
//  Copyright © 2018年 russell. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    RUAdViewClockTypeButton = 0,
    RUAdViewClockTypeCircle,
}RUAdViewClockType;

typedef enum {
    RUAdViewStartUpTypeCold,
    RUAdViewStartUpTypeHot,
}RUAdViewStartUpType;

@protocol AdViewDelegate <NSObject>

- (void) adViewClickAction;

@end

@interface RUAdView : UIView {
    UIImageView *imageView;
    UIButton *jump;
    CAShapeLayer *roundProgress;
    UIButton *progressJump;
}

@property (nonatomic, weak) id<AdViewDelegate> delegate;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) RUAdViewClockType clockType;
@property (nonatomic, assign) RUAdViewStartUpType startUpType;
@property (nonatomic, copy) NSString *url;

@end
