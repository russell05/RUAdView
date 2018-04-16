//
//  RUAdView.m
//  RUAdView
//
//  Created by russ on 2018/4/12.
//  Copyright © 2018年 russell. All rights reserved.
//

#import "RUAdView.h"
#import "UIImageView+WebCache.h"

#define RU_AD_IMAGE_URL     @"ad_image_url"

@implementation RUAdView

#pragma mark -
#pragma mark Object initialization

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _count = 0;
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"ad_bg"];
        [self addSubview:imageView];
        [self configImage];
        
        jump = [UIButton buttonWithType:UIButtonTypeCustom];
        jump.backgroundColor = [UIColor lightGrayColor];
        jump.frame = CGRectMake(self.bounds.size.width-15-100, 30, 100, 40);
        jump.titleLabel.font = [UIFont systemFontOfSize:18];
        [jump addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
        [jump setTitle:@"跳过(5秒)" forState:UIControlStateNormal];
        [self addSubview:jump];
        
        roundProgress = [CAShapeLayer layer];
        roundProgress.backgroundColor = [UIColor clearColor].CGColor;
        roundProgress.frame = CGRectMake(self.bounds.size.width-50-30, CGRectGetMaxY(jump.frame)+20, 40, 40);
        roundProgress.fillColor = [UIColor lightGrayColor].CGColor;
        roundProgress.strokeColor = [UIColor yellowColor].CGColor;
        roundProgress.lineCap = kCALineCapRound;
        roundProgress.lineJoin = kCALineJoinRound;
        roundProgress.lineWidth = 2.0f;
        roundProgress.strokeStart = 0;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(20, 20) radius:20.0f startAngle:-M_PI_2 endAngle:M_PI*3/2 clockwise:YES];
        roundProgress.path = path.CGPath;
        [self.layer addSublayer:roundProgress];
        
        progressJump = [UIButton buttonWithType:UIButtonTypeCustom];
        progressJump.backgroundColor = [UIColor clearColor];
        progressJump.frame = CGRectMake(self.bounds.size.width-50-30, CGRectGetMaxY(jump.frame)+20, 40, 40);
        progressJump.titleLabel.font = [UIFont systemFontOfSize:16];
        [progressJump addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
        [progressJump setTitle:@"跳过" forState:UIControlStateNormal];
        [self addSubview:progressJump];
    }
    return self;
}

#pragma mark -
#pragma mark overwrite method

- (void) setCount:(NSInteger)count
{

    if (roundProgress.strokeStart > 0) {
        roundProgress.strokeStart = 0;
    }
    _count = count;
    [jump setTitle:@"跳过(5秒)" forState:UIControlStateNormal];
    [progressJump setTitle:@"跳过" forState:UIControlStateNormal];
    [self configTimer];
    [self configProgressTimer];
}

- (void) setUrl:(NSString *)url
{
    _url = url;
    if (url && url.length > 0) {
        [self catchImage];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:url forKey:RU_AD_IMAGE_URL];
        [ud synchronize];
    }
}

#pragma mark -
#pragma mark Private method

- (void) action
{
    switch (_startUpType) {
        case RUAdViewStartUpTypeCold:{
            void (^animation)(void) = ^(){
                self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                self.alpha = .5f;
            };
            void (^finished)(BOOL) = ^(BOOL result){
                [self removeFromSuperview];
            };
            [UIView animateWithDuration:.5f animations:animation completion:finished];
            break;
        }
        case RUAdViewStartUpTypeHot:
            if (_delegate && [_delegate respondsToSelector:@selector(adViewClickAction)]) {
                [_delegate adViewClickAction];
            }
            break;
        default:
            break;
    }

}

- (void) configTimer
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [jump setTitle:[NSString stringWithFormat:@"跳过:%ld秒", _count] forState:UIControlStateNormal];
            if (_count <= 0) {
                dispatch_source_cancel(timer);
                [self action];
            }
            else {
                _count--;
            }
        });
    });
    dispatch_resume(timer);
}

- (void) configProgressTimer
{
    __block CGFloat allTime = (CGFloat)_count;
    CGFloat interval = allTime/100;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (allTime > 0) {
                allTime -= interval;
                roundProgress.strokeStart += 0.01f;
            }
            else {
                dispatch_source_cancel(timer);
            }
        });
    });
    dispatch_resume(timer);
}

#pragma mark -
#pragma mark Get image

- (void) configImage
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:RU_AD_IMAGE_URL]) {
        NSString *catchUrl = [ud objectForKey:RU_AD_IMAGE_URL];
        UIImage *imageCatch = [[SDImageCache sharedImageCache] imageFromCacheForKey:catchUrl];
        if (imageCatch) {
            imageView.image = imageCatch;
        }
    }
}

- (void) catchImage
{
    SDWebImageManager *shareManager = [SDWebImageManager sharedManager];
    [shareManager loadImageWithURL:[NSURL URLWithString:_url] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:_url toDisk:YES completion:nil];
        }
    }];
}

@end
