//
//  LTQuckPreviewViewModel.h
//  LTQuickPreview
//
//  Created by 梁通 on 2017/6/21.
//  Copyright © 2017年 liangtong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTQuckPreviewViewModel : NSObject

typedef void (^LTQuckPreviewProgressCallbackBlock)(float);
typedef NSURL * (^LTQuckPreviewDestinationPathCallbackBlock)(void);
typedef void (^LTQuckPreviewDownloadCompleteCallbackBlock)(NSURL*,NSError*);

typedef NS_ENUM(NSInteger, LTQuickPreviewFileType){
    LTQuickPreviewFileTypeQuickLook,    //使用QuickLook预览
    LTQuickPreviewFileTypeVideo,        //使用播放器预览
    LTQuickPreviewFileTypeWeb,          //打开网页
};


//use file cache
@property (nonatomic, assign) BOOL useCache;

/**
 *  check file type with url
 **/
- (LTQuickPreviewFileType)fileTypeWithURL:(NSURL*)url;

/**
 *  file local path by weburl
 **/
-(NSURL*)filePathWithWebURL:(NSURL*)webURL;

/**
 *  download file
 **/
- (void)downloadFile:(NSURL*)fileURL
            progress:(LTQuckPreviewProgressCallbackBlock) downloadProgress
     destinationPath:(LTQuckPreviewDestinationPathCallbackBlock)destinationPath
            complete:(LTQuckPreviewDownloadCompleteCallbackBlock)complete;


@end
