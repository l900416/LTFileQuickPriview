//
//  LTQuickPreviewViewController.m
//  LTQuickPreview
//
//  Created by 梁通 on 2017/6/21.
//  Copyright © 2017年 liangtong. All rights reserved.
//

#import "LTQuickPreviewViewController.h"
#import <QuickLook/QuickLook.h>//文件预览
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>//视频预览
#import <WebKit/WebKit.h>

#import "LTQuckPreviewViewModel.h"

@interface LTQuickPreviewViewController ()<WKNavigationDelegate,QLPreviewControllerDataSource,UIDocumentInteractionControllerDelegate>
//UI
@property (nonatomic, strong) UIButton* shareBtn;
@property (nonatomic, strong) UIButton* dismissBtn;

@property (nonatomic, strong) LTQuckPreviewViewModel* viewModel;
//File
@property (nonatomic, strong) NSURL* filePath;
@property (nonatomic, strong) NSURL* fileURL;

//WebView
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;
//QuickLook
@property (nonatomic, strong) QLPreviewController* qlPreviewVC;
//Video
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerViewController  *playerView;
//Share
@property (nonatomic, strong) UIDocumentInteractionController* docInteractionController;//第三方应用打开



@end

@implementation LTQuickPreviewViewController

#pragma mark - Instance

/**
 *  preview local file
 **/
+(instancetype) instanceWithFilePath:(NSURL*)filePath{
    LTQuickPreviewViewController* instance = [[LTQuickPreviewViewController alloc] init];
    instance.filePath = filePath;
    instance.useCache = YES;
    return instance;
}

/**
 *  preview online file
 **/
+(instancetype) instanceWithFileURL:(NSURL*)fileURL{
    LTQuickPreviewViewController* instance = [[LTQuickPreviewViewController alloc] init];
    instance.fileURL = fileURL;
    instance.useCache = YES;
    return instance;
}

/**
 *  preview file, default cache is used
 **/
+(instancetype) instanceWithURL:(NSURL*)url{
    NSString* absoluteUrl = [url absoluteString];
    if ([absoluteUrl hasPrefix:@"http"]) {
        return [LTQuickPreviewViewController instanceWithFileURL:url];
    }else{
        return [LTQuickPreviewViewController instanceWithFilePath:url];
    }
}

/**
 *  preview file
 **/
+(instancetype) instanceWithURL:(NSURL*)url useCache:(BOOL)useCache{
    LTQuickPreviewViewController* instance = [LTQuickPreviewViewController instanceWithURL:url];
    instance.useCache = useCache;
    return instance;
}

//init method
-(instancetype)init{
    self = [super init];
    if(self){
        
        self.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openWithOtherApp)];
    }
    return self;
}

#pragma mark - setup
- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [[LTQuckPreviewViewModel alloc] init];
    self.viewModel.useCache = self.useCache;
    if (_filePath) {//本地文件
        LTQuickPreviewFileType fileType = [self.viewModel fileTypeWithURL:_filePath];
        if (fileType == LTQuickPreviewFileTypeQuickLook) {
            [self previewLocalQuickLookFile];
        }else if (fileType == LTQuickPreviewFileTypeVideo){
            [self playVideo:_filePath];
        }else{
            [self openWebURL:_filePath];
        }
        
    }else if (_fileURL){
        LTQuickPreviewFileType fileType = [self.viewModel fileTypeWithURL:_fileURL];
        if (fileType == LTQuickPreviewFileTypeQuickLook) {
            
            [self addProgressView];
            self.view.backgroundColor = [UIColor whiteColor];
            
            [self.viewModel downloadFile:_fileURL progress:^(float progress) {
                NSLog(@"下载进度：%.2f",progress);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progress >= 1.0) {
                        self.progressView.hidden = YES;
                    }else{
                        self.progressView.hidden = NO;
                    }
                    self.progressView.progress = progress;
                });
            } destinationPath:^NSURL *{
                return  [self.viewModel filePathWithWebURL:_fileURL];
            } complete:^(NSURL* filePath,NSError *error) {
                self.progressView.hidden = YES;
                if (!error) {
                    self.filePath = filePath;
                    NSLog(@"文件路径：%@",self.filePath);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self previewLocalQuickLookFile];
                    });
                }
            }];
        }else if (fileType == LTQuickPreviewFileTypeVideo){
            [self playVideo:_fileURL];
        }else{
            [self openWebURL:_fileURL];
        }
    }else{
        self.view.backgroundColor = [UIColor whiteColor];
        if (!self.title) {
            self.title = @"The URL is required !";
        }
    }
    
    if (!self.navigationController) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissBtn setImage:[UIImage imageNamed:@"ic_btn_close_black"] forState:UIControlStateNormal];
        _dismissBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_dismissBtn addTarget:self action:@selector(dismissPreviewController) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dismissBtn];
        
        NSLayoutConstraint* dTop = [NSLayoutConstraint constraintWithItem:_dismissBtn attribute:NSLayoutAttributeTopMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTopMargin multiplier:1.f constant:10];
        NSLayoutConstraint* dTrailing = [NSLayoutConstraint constraintWithItem:_dismissBtn attribute:NSLayoutAttributeTrailingMargin relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailingMargin multiplier:1.f constant:-10];
        NSLayoutConstraint* dWidth = [NSLayoutConstraint constraintWithItem:_dismissBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:60];
        NSLayoutConstraint* dHeight = [NSLayoutConstraint constraintWithItem:_dismissBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_dismissBtn attribute:NSLayoutAttributeWidth multiplier:1.f constant:0];
        
        [NSLayoutConstraint activateConstraints: @[dTop,dTrailing,dWidth,dHeight]];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.progressView.hidden = YES;
    
    if (_webView) {
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
    if (_webView) {
        [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_webView removeObserver:self forKeyPath:@"title"];
    }
    
    if (_player) {
        [_player replaceCurrentItemWithPlayerItem:nil];
        _player = nil;
    }
}

-(void)dismissPreviewController{
    [self dismissViewControllerAnimated:true completion:nil];
}
#pragma mark - Action

-(void)openWithOtherApp{
    if(!_filePath) return;
    _docInteractionController = [UIDocumentInteractionController  interactionControllerWithURL:_filePath];
    [_docInteractionController presentOpenInMenuFromRect:self.shareBtn.frame
                                                  inView:self.view
                                                animated:YES];
}


- (void)previewLocalQuickLookFile {
    if (!self.title) {
        self.title = [[[_filePath absoluteString] lastPathComponent] stringByDeletingPathExtension];
    }
    
    if (_qlPreviewVC) {
        [_qlPreviewVC.view removeFromSuperview];
        [_qlPreviewVC removeFromParentViewController];
    }
    
    _qlPreviewVC = [[QLPreviewController alloc] init];
    _qlPreviewVC.dataSource = self;
    
    _qlPreviewVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:_qlPreviewVC];
    [self.view addSubview:_qlPreviewVC.view];
    [self addConstraintOnQuickLook];
}

#pragma mark - Video

-(void)playVideo:(NSURL*)videoURL{
    if (!self.title) {
        self.title = [[[videoURL absoluteString] lastPathComponent] stringByDeletingPathExtension];
    }
    
    self.playerView = [[AVPlayerViewController alloc] init];
    AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:videoURL];
    self.player = [[AVPlayer alloc]initWithPlayerItem:item];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = self.view.bounds;
    layer.videoGravity = AVLayerVideoGravityResize;
    [self.view.layer addSublayer:layer];
    
    //设置AVPlayerViewController内部的AVPlayer为刚创建的AVPlayer
    self.playerView.player = self.player;
    
    self.playerView.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:self.playerView];
    [self.view addSubview:self.playerView.view];
    [self addConstraintOnVideo];
}

#pragma mark - ProgressView
-(void)addProgressView{
    if (_progressView) {
        [_progressView removeFromSuperview];
    }
    CGFloat progressBarHeight = 3.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect progressFrame = CGRectMake(0, navigaitonBarBounds.size.height , navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[UIProgressView alloc] initWithFrame:progressFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _progressView.trackTintColor = [UIColor whiteColor];
    if (self.progressTintColor) {
        _progressView.progressTintColor = self.progressTintColor;
    }else{
        _progressView.progressTintColor = [UIColor colorWithRed:32/255.0 green:204/255.0 blue:133/255.0 alpha:1];
    }
    [self.navigationController.navigationBar addSubview:_progressView];
}


#pragma mark - WebView

-(void)openWebURL:(NSURL*)webURL{
    [self addProgressView];
    
    _webView = [[WKWebView alloc] init];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    [_webView loadRequest:[NSURLRequest requestWithURL:webURL]];
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    [self.view sendSubviewToBack:_webView];
    [self addConstraintOnWebView];
}

#pragma mark - QuickLook
#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    return self.filePath;
}


#pragma mark - WebView
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    //    self.errorTips = @"发生了点儿错误！";
    //    self.refreshScrollView = self.webView.scrollView;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (object == self.webView && [keyPath isEqualToString:@"title"]){
        if (!self.title) {
            self.title = self.webView.title;
        }
    }else if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Constraint

//constraint on webView
-(void)addConstraintOnWebView{
    //约束-左
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_webView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.f
                                                           constant:0]];
    //约束-上
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_webView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.f
                                                           constant:0]];
    //约束-右
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_webView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.f
                                                           constant:0]];
    //约束-下
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_webView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.f
                                                           constant:0]];
}

//constraint on quicklook
-(void)addConstraintOnQuickLook{
    //约束-左
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_qlPreviewVC.view
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.f
                                                           constant:-10]];
    //约束-上
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_qlPreviewVC.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.f
                                                           constant:CGRectGetHeight(self.navigationController.navigationBar.bounds)]];
    //约束-右
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_qlPreviewVC.view
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.f
                                                           constant:10]];
    //约束-下
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_qlPreviewVC.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.f
                                                           constant:0]];
}

//constraint on video
-(void)addConstraintOnVideo{
    //约束-左
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_playerView.view
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.f
                                                           constant:-10]];
    //约束-上
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_playerView.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.f
                                                           constant:CGRectGetHeight(self.navigationController.navigationBar.bounds)]];
    //约束-右
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_playerView.view
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.f
                                                           constant:10]];
    //约束-下
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_playerView.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.f
                                                           constant:0]];
}
@end
