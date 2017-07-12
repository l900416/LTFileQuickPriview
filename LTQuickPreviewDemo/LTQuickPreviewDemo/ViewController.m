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
    [self.navigationController pushViewController:[self filePreviewVCWithURL:[NSURL URLWithString:@"https://www.github.com/"]] animated:true];
}

-(IBAction)quickPreviewLocalQuickLook:(id)sender{
    NSURL* localPath = [[NSBundle mainBundle] URLForResource:@"Getting-Started-with-iBeacon" withExtension:@"pdf"];
    [self.navigationController pushViewController:[self filePreviewVCWithURL:localPath] animated:true];
}
- (IBAction)quickPreviewLocalVideo:(UIButton *)sender {
    NSURL* localPath = [[NSBundle mainBundle] URLForResource:@"bunny" withExtension:@"mp4"];
    [self.navigationController pushViewController:[self filePreviewVCWithURL:localPath] animated:true];
}

-(IBAction)quickPreviewWebQuickLook:(id)sender{
    NSURL* fileURL = [NSURL URLWithString:@"https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/LocationAwarenessPG/Art/sphere_to_cylinder.jpg"];
    [self.navigationController pushViewController:[self filePreviewVCWithURL:fileURL] animated:true];
}
-(IBAction)quickPreviewWebQuickLookWithoutCache:(id)sender{
    NSURL* fileURL = [NSURL URLWithString:@"https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Art/remote_notif_multiple_2x.png"];
    LTQuickPreviewViewController* filePreviewVC = [self filePreviewVCWithURL:fileURL];
    filePreviewVC.useCache = NO;
    [self.navigationController pushViewController:filePreviewVC animated:true];
}

- (IBAction)quickPreviewWebVideo:(UIButton *)sender {
    NSURL* fileURL = [NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
    [self.navigationController pushViewController:[self filePreviewVCWithURL:fileURL] animated:true];

}

-(LTQuickPreviewViewController*)filePreviewVCWithURL:(NSURL*)url{
    return [LTQuickPreviewViewController instanceWithURL:url];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
