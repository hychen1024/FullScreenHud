//
//  HUDView.h
//  ProjectTest
//
//  Created by Just-h on 16/11/18.
//  Copyright © 2016年 Just-h. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"

#define kTopWindow [[UIApplication sharedApplication].windows lastObject]
#define HUDForegroundColor [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.6]
#define HUDBackgroungColor [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.2]

#define HUDCirqueForegroundColor [UIColor colorWithRed:60/255.0f green:139/255.0f blue:246/255.0f alpha:0.5]
#define HUDCirqueBackgroungColor [UIColor colorWithRed:185/255.0f green:186/255.0f blue:200/255.0f alpha:0.3]

typedef NS_ENUM(NSInteger,YCHUDLoadingType){
    YCHUDLoadingTypeImage               = 0,//自定义图片
    YCHUDLoadingTypeGifImage            = 1,//GIF动图
    YCHUDLoadingTypeFailure             = 2,//加载失败
    YCHUDLoadingTypeCircle              = 3,//圆圈动画
    YCHUDLoadingTypeCirque              = 4,//圆环动画
    YCHUDLoadingTypeDot                 = 5,//水平点动画
};

typedef void(^ClickBlock)(UIButton *btn);

@interface HUDView : UIView
    /*! 控件 */
@property (nonatomic, strong)   UIView        *imageView;
@property (nonatomic, copy)     UILabel       *textLabel;
@property (nonatomic, strong)   UIButton      *reloadButton;
    /*! 属性 */
@property (nonatomic, strong) NSData    *gifImageData;// GIF动图
@property (nonatomic, strong) NSArray   *customAnimationImages;// 图片数组
@property (nonatomic, strong) UIImage   *failureImage;// 失败图片
@property (nonatomic, strong) UIImage   *customImage;// 自定义静态图片
@property (nonatomic, strong) UIColor   *foregroundColor;//动画前景颜色
@property (nonatomic, strong) UIColor   *defaultBackgroundColor;//动画背景颜色

@property (nonatomic, assign) CGSize    imageViewSize;// 图片尺寸

    /*! Block回调 */
@property (nonatomic, copy) ClickBlock clickBlock;
    /*! 类方法 */
+ (void)showAtView:(UIView *)view message:(NSString *)message;
+ (void)showAtView:(UIView *)view message:(NSString *)message hudType:(YCHUDLoadingType)hudType;
+ (void)hideAtView:(UIView *)view;
    /*! 对象方法 */
- (void)showAtView:(UIView *)view hudType:(YCHUDLoadingType)hudType;
- (void)hide;
- (void)hideAfterDelay:(NSTimeInterval)afterDelay;

@end


@interface UIImage (YCHUD)
+ (UIImage *)YCHUDImageWithSmallGIFData:(NSData *)data scale:(CGFloat)scale;
@end

@interface UIView (MainQueue)
-(void)dispatchMainQueue:(dispatch_block_t)block;
@end
