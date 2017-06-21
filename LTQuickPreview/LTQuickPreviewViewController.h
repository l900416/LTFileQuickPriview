//
//  LTQuickPreviewViewController.h
//  LTQuickPreview
//
//  Created by 梁通 on 2017/6/21.
//  Copyright © 2017年 liangtong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTQuickPreviewViewController : UIViewController

@property (nonatomic, strong) UIColor* progressTintColor;

+(instancetype) instanceWithFilePath:(NSURL*)filePath;
+(instancetype) instanceWithFileURL:(NSURL*)fileURL;

@end
