//
//  NextViewController.m
//  相机自定义
//
//  Created by Union blue on 2017/8/30.
//  Copyright © 2017年 Union blue Snap. All rights reserved.
//

#import "NextViewController.h"

@interface NextViewController (){
    UIImageView *imageView;
}

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:imageView];
    imageView.image = _imageUrl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setImageArray:(NSMutableArray *)imageArray
{

}

@end
