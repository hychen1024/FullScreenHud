//
//  ViewController.m
//  FullScreenHUD
//
//  Created by Just-h on 16/11/21.
//  Copyright © 2016年 Just-h. All rights reserved.
//

#import "ViewController.h"
#import "HUDView.h"
@interface ViewController ()
@property (nonatomic, strong) HUDView *hudView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    HUDView *hudView = [[HUDView alloc] initWithFrame:self.view.bounds];
    //失败图片
    hudView.failureImage = [UIImage imageNamed:@"1"];
    
    //自定义图片
//    hudView.customImage = [UIImage imageNamed:@"2"];
    
    
    //GIF图片
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loadinggif3" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.hudView.gifImageData = data;
    
    //图片数组
//    NSMutableArray * images = [NSMutableArray array];
//    for (int index = 0; index<=19; index++) {
//        NSString * imageName = [NSString stringWithFormat:@"%d.png",index];
//        UIImage *image = [UIImage imageNamed:imageName];
//        [images addObject:image];
//    }
//    self.hudView.imageViewSize = CGSizeMake(80, 80);
//    self.hudView.customAnimationImages = images;
    
    //加载Block回调
    hudView.clickBlock = ^(UIButton *btn){
//        [self.tableView.mj_header beginRefreshing];
    };
    [self.view addSubview:hudView];
    self.hudView = hudView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
