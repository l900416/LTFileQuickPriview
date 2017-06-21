//
//  ViewController.m
//  LTQuickPreview
//
//  Created by 梁通 on 2017/6/21.
//  Copyright © 2017年 liangtong. All rights reserved.
//

#import "ViewController.h"
#import "LTQuickPreviewViewController.h"

/**
 *  文件预览
 *  网页预览
 *  第三方应用打开
 *
 **/
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"LTQuickPreview";
}
- (IBAction)quickPreviewWebURL:(UIButton *)sender {
    LTQuickPreviewViewController* quickVC = [LTQuickPreviewViewController instanceWithFileURL:[NSURL URLWithString:@"https://www.github.com/"]];
    quickVC.progressTintColor = [UIColor redColor];
    [self.navigationController pushViewController:quickVC animated:true];
}

-(IBAction)quickPreviewLocalQuickLook:(id)sender{
    NSURL* localPath = [[NSBundle mainBundle] URLForResource:@"Getting-Started-with-iBeacon" withExtension:@"pdf"];
    LTQuickPreviewViewController* quickVC = [LTQuickPreviewViewController instanceWithFilePath:localPath];
    [self.navigationController pushViewController:quickVC animated:true];
}
- (IBAction)quickPreviewLocalVideo:(UIButton *)sender {
    NSURL* localPath = [[NSBundle mainBundle] URLForResource:@"bunny" withExtension:@"mp4"];
    LTQuickPreviewViewController* quickVC = [LTQuickPreviewViewController instanceWithFilePath:localPath];
    [self.navigationController pushViewController:quickVC animated:true];
}

-(IBAction)quickPreviewWebQuickLook:(id)sender{
    NSURL* fileURL = [NSURL URLWithString:@"https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/Art/sphere_to_cylinder.jpg"];
    LTQuickPreviewViewController* quickVC = [LTQuickPreviewViewController instanceWithFileURL:fileURL];
    [self.navigationController pushViewController:quickVC animated:true];
}

- (IBAction)quickPreviewWebVideo:(UIButton *)sender {
    NSURL* fileURL = [NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
    LTQuickPreviewViewController* quickVC = [LTQuickPreviewViewController instanceWithFileURL:fileURL];
    [self.navigationController pushViewController:quickVC animated:true];

}
- (IBAction)quickPreviewWithoutURL:(UIButton *)sender {
    LTQuickPreviewViewController* quickVC = [[LTQuickPreviewViewController alloc] init];
    [self.navigationController pushViewController:quickVC animated:true];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
