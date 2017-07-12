//
//  LTQuickPreviewViewController.h
//  LTQuickPreview
//
//  Created by 梁通 on 2017/6/21.
//  Copyright © 2017年 liangtong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTQuickPreviewViewController : UIViewController

//progress tint color
@property (nonatomic, strong) UIColor* progressTintColor;

//use file cache - default is YES
@property (nonatomic, assign) BOOL useCache;

/**
 *  preview local file
 **/
+(instancetype) instanceWithFilePath:(NSURL*)filePath;


/**
 *  preview online file
 **/
+(instancetype) instanceWithFileURL:(NSURL*)fileURL;


/**
 *  preview file, default cache is used
 **/
+(instancetype) instanceWithURL:(NSURL*)url;

/**
 *  preview file
 **/
+(instancetype) instanceWithURL:(NSURL*)url useCache:(BOOL)useCache;

@end
