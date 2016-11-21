//
//  HUDView.m
//  ProjectTest
//
//  Created by Just-h on 16/11/18.
//  Copyright © 2016年 Just-h. All rights reserved.
//

#import "HUDView.h"
#import <ImageIO/ImageIO.h>

static NSString *const Loading = @"努力加载中";
static NSString *const failure = @"加载失败，请重新加载";

@interface HUDView ()
//动画
@property (nonatomic, strong) UIView *loadingAnimationView;
//图片
@property (nonatomic, strong) UIImageView *customImageView;
//失败
@property (nonatomic, strong) UIImageView *failureImageView;
@property (nonatomic, strong) CABasicAnimation *myAnimation;
@property (nonatomic, strong) CAReplicatorLayer *myRepLayer;
@property (nonatomic, strong) CALayer *myLayer;

@property (nonatomic, assign) YCHUDLoadingType hudType;
@end
@implementation HUDView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupConfig];
        [self setupSubview];
        [self setupConstraints];
    }
    return self;
}

- (void)setupConfig{
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.imageViewSize = CGSizeMake(120, 120);
}

- (void)setupSubview{
    [self addSubview:self.imageView];
    [self addSubview:self.textLabel];
    [self addSubview:self.reloadButton];
    
    [self.imageView addSubview:self.loadingAnimationView];
    [self.imageView addSubview:self.customImageView];
    [self.imageView addSubview:self.failureImageView];
    
    self.defaultBackgroundColor = HUDBackgroungColor;
    self.foregroundColor = HUDForegroundColor;
}

- (void)setupConstraints{
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(120, 120)).priorityMedium();
    }];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(10);
        make.centerX.equalTo(self);
        make.left.equalTo(self).offset(20);
        make.height.equalTo(@20);
    }];
    [self.reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(120, 35));
    }];
    [self.loadingAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.imageView);
        make.center.equalTo(self.imageView);
    }];
    [self.customImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.imageView);
        make.center.equalTo(self.imageView);
    }];
    [self.failureImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.imageView);
        make.center.equalTo(self.imageView);
    }];
}

- (void)setupSubviewWithHudType:(YCHUDLoadingType)hudType{
    self.textLabel.text = hudType == YCHUDLoadingTypeFailure?failure:Loading;
    
    if (hudType < 3) {//图片or图片数组
        if (hudType == 2) {
            self.failureImageView.hidden = NO;
            self.customImageView.hidden = YES;
        }else{
            self.failureImageView.hidden = YES;
            self.customImageView.hidden = NO;
        }
        [self.loadingAnimationView removeFromSuperview];
    }else{//核心动画
        self.failureImageView.hidden = YES;
        self.customImageView.hidden = YES;
        self.imageViewSize = CGSizeMake(120, 120);
        if (!self.loadingAnimationView.superview) {
            [self.imageView addSubview:self.loadingAnimationView];
            [self.loadingAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(self.imageView);
                make.center.equalTo(self.imageView);
            }];
        }
    }
    
    switch (hudType) {
        case YCHUDLoadingTypeImage:
        case YCHUDLoadingTypeGifImage:
        case YCHUDLoadingTypeFailure:
            break;
        case YCHUDLoadingTypeCircle:
        case YCHUDLoadingTypeCirque:
        case YCHUDLoadingTypeDot:
            [self showAnimationWithType:hudType];
            break;
        default:
            break;
    }
}

#pragma mark - 类方法
+ (void)showAtView:(UIView *)view message:(NSString *)message{
    [self showAtView:view message:message hudType:YCHUDLoadingTypeCirque];
}
+ (void)showAtView:(UIView *)view message:(NSString *)message hudType:(YCHUDLoadingType)hudType{
    HUDView *hud = [[HUDView alloc] initWithFrame:view.bounds];
    hud.textLabel.text = message;
    [hud showAtView:view hudType:hudType];
}
+ (void)hideAtView:(UIView *)view{
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            HUDView *hud = (HUDView *)subview;
            [hud hide];
        }
    }
}
#pragma mark - 实例方法
- (void)showAtView:(UIView *)view hudType:(YCHUDLoadingType)hudType{
    NSAssert(![self isEmptyRect:self.frame], @"HUDView frame can not be nil");
    self.hudType = hudType;
    [self hide];
    [self setupSubviewWithHudType:hudType];
    [self addToSuperViewAndBringToFrontWithView:view];
}

- (void)hide{
    [self dispatchMainQueue:^{
        [self removeFromSuperview];
        [self removeSublayer];
    }];
}

- (void)hideAfterDelay:(NSTimeInterval)afterDelay{
    [self performSelector:@selector(hide) withObject:nil afterDelay:afterDelay];
}

#pragma mark - 自定义方法
- (BOOL)isEmptyRect:(CGRect)rect{
    if (rect.size.width > 0 && rect.size.height > 0) {
        return NO;
    }else{
        return YES;
    }
}

- (void)addToSuperViewAndBringToFrontWithView:(UIView *)view{
    [self dispatchMainQueue:^{
        view?[view addSubview:self]:[kTopWindow addSubview:self];
        [self.superview bringSubviewToFront:self];
    }];
}

#pragma mark - 动画
- (void)showAnimationWithType:(YCHUDLoadingType)hudType{
    [self dispatchMainQueue:^{
        [self removeSublayer];
    }];
    self.myRepLayer.frame = self.loadingAnimationView.bounds;
    self.myRepLayer.position = self.loadingAnimationView.center;
    switch (hudType) {
        case YCHUDLoadingTypeCircle:
            self.foregroundColor = HUDForegroundColor;
            self.defaultBackgroundColor = HUDBackgroungColor;
            [self setupCircleWithRepeatCount:10];
            break;
        case YCHUDLoadingTypeCirque:
            self.foregroundColor = HUDCirqueForegroundColor;
            self.defaultBackgroundColor = HUDCirqueBackgroungColor;
            [self setupCircleWithRepeatCount:100];
            break;
        case YCHUDLoadingTypeDot:
            [self setupDotWithRepeatCount:3];
            break;
        default:
            break;
    }
    
    [self dispatchMainQueue:^{
        [self addSublayer];
    }];
}

- (void)setupCircleWithRepeatCount:(NSInteger)count{
    CGFloat width = 11;
    self.myLayer.frame = CGRectMake(0, 0, width, width);
    self.myLayer.cornerRadius = width/2;
    self.myLayer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01);
    self.myRepLayer.instanceCount = count;
    CGFloat angle = 2*M_PI/count;
    self.myRepLayer.instanceTransform = CATransform3DMakeRotation(angle, 0, 0, 1);
    self.myRepLayer.instanceDelay = 1.f/count;
    self.myAnimation.keyPath = @"transform.scale";
    self.myAnimation.duration = 1;
    self.myAnimation.fromValue = @1;
    self.myAnimation.toValue = @0.1;
}

- (void)setupDotWithRepeatCount:(NSInteger)count{
    CGFloat width = 15;
    self.myLayer.frame = CGRectMake(0, 0, width, width);
    self.myLayer.transform = CATransform3DMakeScale(0, 0, 0);
    self.myLayer.cornerRadius = width/2;
    self.myRepLayer.instanceCount = count;
    self.myRepLayer.instanceDelay = 1.f/count;
    self.myRepLayer.instanceTransform = CATransform3DMakeTranslation(120/3, 0, 0);
    self.myAnimation.keyPath = @"transform.scale";
    self.myAnimation.duration = 1.0;
    self.myAnimation.fromValue = @1;
    self.myAnimation.toValue = @0;
}

- (void)addSublayer{
    [self.loadingAnimationView.layer addSublayer:self.myRepLayer];
    [self.myRepLayer addSublayer:self.myLayer];
    [self.myLayer addAnimation:self.myAnimation forKey:@"HUD"];
}

- (void)removeSublayer{
    [self.myRepLayer removeFromSuperlayer];
    [self.myLayer removeFromSuperlayer];
    [self.myLayer removeAnimationForKey:@"HUD"];
}

- (void)updateConstraints{
    self.myRepLayer.frame = self.loadingAnimationView.bounds;
    self.myRepLayer.position = self.loadingAnimationView.center;
    switch (self.hudType) {
        case YCHUDLoadingTypeCircle:
        case YCHUDLoadingTypeCirque:
            self.myLayer.position = CGPointMake(60, 24);
            break;
        case YCHUDLoadingTypeDot:
            self.myLayer.position = CGPointMake(18, 60);
            break;
        default:
            break;
    }
    [super updateConstraints];
}

#pragma mark - 按钮响应
- (void)loadBtnDidClick:(UIButton *)btn{
    if (self.clickBlock) {
        self.clickBlock(btn);
    }
}

#pragma mark - Setter
- (void)setImageViewSize:(CGSize)imageViewSize{
    _imageViewSize = imageViewSize;
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(imageViewSize.width)).priorityHigh();
        make.height.equalTo(@(imageViewSize.height)).priorityHigh();
    }];
}

- (void)setGifImageData:(NSData *)gifImageData{
    _gifImageData = gifImageData;
    UIImage *image = [UIImage YCHUDImageWithSmallGIFData:gifImageData scale:1];
    self.customImageView.image = image;
}

- (void)setCustomImage:(UIImage *)customImage{
    _customImage = customImage;
    if ([self.customImageView isAnimating]) {
        [self.customImageView stopAnimating];
    }
    self.customImageView.image = customImage;
}

- (void)setFailureImage:(UIImage *)failureImage{
    _failureImage = failureImage;
    self.failureImageView.image = failureImage;
}

- (void)setCustomAnimationImages:(NSArray *)customAnimationImages{
    _customAnimationImages = customAnimationImages;
    if (customAnimationImages.count > 1) {
        self.customImageView.animationImages = customAnimationImages;
        [self.customImageView startAnimating];
    }
}

- (void)setForegroundColor:(UIColor *)foregroundColor{
    _foregroundColor = foregroundColor;
    self.myLayer.backgroundColor = foregroundColor.CGColor;
}

- (void)setDefaultBackgroundColor:(UIColor *)defaultBackgroundColor{
    _defaultBackgroundColor = defaultBackgroundColor;
    self.myRepLayer.backgroundColor = defaultBackgroundColor.CGColor;
}

#pragma mark - Getter
- (UIView *)imageView{
    if (!_imageView) {
        _imageView = [[UIView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

- (UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor clearColor];
    }
    return _textLabel;
}

- (UIButton *)reloadButton{
    if (!_reloadButton) {
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reloadButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_reloadButton setTitle:@"加载" forState:UIControlStateNormal];
        [_reloadButton setTitle:@"加载" forState:UIControlStateHighlighted];
        [_reloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_reloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_reloadButton setBackgroundColor:[UIColor lightGrayColor]];
        [_reloadButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_reloadButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        [_reloadButton addTarget:self action:@selector(loadBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadButton;
}

- (UIImageView *)customImageView{
    if (!_customImageView) {
        _customImageView = [[UIImageView alloc] init];
        _customImageView.animationDuration = 0;
        _customImageView.animationRepeatCount = 0;
    }
    return _customImageView;
}

- (UIView *)loadingAnimationView{
    if (!_loadingAnimationView) {
        _loadingAnimationView = [[UIView alloc] init];
        _loadingAnimationView.backgroundColor = [UIColor clearColor];
    }
    return _loadingAnimationView;
}

- (UIImageView *)failureImageView{
    if (!_failureImageView) {
        _failureImageView = [[UIImageView alloc] init];
    }
    return _failureImageView;
}

- (CABasicAnimation *)myAnimation{
    if (!_myAnimation) {
        _myAnimation = [CABasicAnimation animation];
        _myAnimation.repeatCount = NSIntegerMax;
        _myAnimation.removedOnCompletion = NO;
        _myAnimation.fillMode = kCAFillModeForwards;
    }
    return _myAnimation;
}

- (CALayer *)myLayer{
    if (!_myLayer) {
        _myLayer = [CALayer layer];
        _myLayer.masksToBounds = YES;
    }
    return _myLayer;
}

- (CAReplicatorLayer *)myRepLayer{
    if (!_myRepLayer) {
        _myRepLayer = [CAReplicatorLayer layer];
        _myRepLayer.cornerRadius = 10;
    }
    return _myRepLayer;
}

@end

#pragma mark - UIImage(YCHUD)
@implementation UIImage (YCHUD)
// See YYWebImage for details.
+ (UIImage *)YCHUDImageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFTypeRef)(data), NULL);
    if (!source) return nil;
    
    size_t count = CGImageSourceGetCount(source);
    if (count <= 1) {
        CFRelease(source);
        return [self.class imageWithData:data scale:scale];
    }
    
    NSUInteger frames[count];
    double oneFrameTime = 1 / 50.0; // 50 fps
    NSTimeInterval totalTime = 0;
    NSUInteger totalFrame = 0;
    NSUInteger gcdFrame = 0;
    for (size_t i = 0; i < count; i++) {
        NSTimeInterval delay = YCHUDCGImageSourceGetGIFFrameDelayAtIndex(source, i);
        totalTime += delay;
        NSInteger frame = lrint(delay / oneFrameTime);
        if (frame < 1) frame = 1;
        frames[i] = frame;
        totalFrame += frames[i];
        if (i == 0) gcdFrame = frames[i];
        else {
            NSUInteger frame = frames[i], tmp;
            if (frame < gcdFrame) {
                tmp = frame; frame = gcdFrame; gcdFrame = tmp;
            }
            while (true) {
                tmp = frame % gcdFrame;
                if (tmp == 0) break;
                frame = gcdFrame;
                gcdFrame = tmp;
            }
        }
    }
    NSMutableArray *array = [NSMutableArray new];
    for (size_t i = 0; i < count; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!imageRef) {
            CFRelease(source);
            return nil;
        }
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        if (width == 0 || height == 0) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        // BGRA8888 (premultiplied) or BGRX8888
        // same as UIGraphicsBeginImageContext() and -[UIView drawRect:]
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, space, bitmapInfo);
        CGColorSpaceRelease(space);
        if (!context) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // decode
        CGImageRef decoded = CGBitmapContextCreateImage(context);
        CFRelease(context);
        if (!decoded) {
            CFRelease(source);
            CFRelease(imageRef);
            return nil;
        }
        UIImage *image = [UIImage imageWithCGImage:decoded scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(imageRef);
        CGImageRelease(decoded);
        if (!image) {
            CFRelease(source);
            return nil;
        }
        for (size_t j = 0, max = frames[i] / gcdFrame; j < max; j++) {
            [array addObject:image];
        }
    }
    CFRelease(source);
    UIImage *image = [self.class animatedImageWithImages:array duration:totalTime];
    return image;
}

static NSTimeInterval YCHUDCGImageSourceGetGIFFrameDelayAtIndex(CGImageSourceRef source, size_t index) {
    NSTimeInterval delay = 0;
    CFDictionaryRef dic = CGImageSourceCopyPropertiesAtIndex(source, index, NULL);
    if (dic) {
        CFDictionaryRef dicGIF = CFDictionaryGetValue(dic, kCGImagePropertyGIFDictionary);
        if (dicGIF) {
            NSNumber *num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFUnclampedDelayTime);
            if (num.doubleValue <= __FLT_EPSILON__) {
                num = CFDictionaryGetValue(dicGIF, kCGImagePropertyGIFDelayTime);
            }
            delay = num.doubleValue;
        }
        CFRelease(dic);
    }
    
    if (delay < 0.02) delay = 0.1;
    return delay;
}
@end

@implementation UIView (MainQueue)
-(void)dispatchMainQueue:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}
@end
