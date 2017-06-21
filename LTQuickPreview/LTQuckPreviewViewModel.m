//
//  LTQuckPreviewViewModel.m
//  LTQuickPreview
//
//  Created by 梁通 on 2017/6/21.
//  Copyright © 2017年 liangtong. All rights reserved.
//

#import "LTQuckPreviewViewModel.h"

@interface LTQuckPreviewViewModel()<NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession* session;

@property (nonatomic, strong) NSURL* destinationPath;
@property (nonatomic, copy) void (^downloadProgress)(float progress);
@property (nonatomic, copy) void (^downloadComplete)(NSURL* filePath,NSError *error);

@end

@implementation LTQuckPreviewViewModel

- (LTQuickPreviewFileType)fileTypeWithURL:(NSURL*)url{
    NSArray* quickFiles = @[@"doc",@"docx",@"ppt",@"pptx",@"xls",@"xlsx",@"txt",@"rtf",@"png",@"bmp",@"gif",@"jpg",@"pdf",@"jpeg",@"csv",@"pages",@"key",@"numbers",@"tif",@"ico"];
    NSArray* videoFiles = @[@"mp4",@"mov",@"m3u8",@"mp3"];
    NSString* fileExtention = [[[url absoluteString] pathExtension] lowercaseString];
    for (NSString* quickItem in quickFiles) {
        if ([fileExtention isEqualToString:quickItem]) {
            return LTQuickPreviewFileTypeQuickLook;
        }
    }
    for (NSString* videoItem in videoFiles) {
        if ([fileExtention isEqualToString:videoItem]) {
            return LTQuickPreviewFileTypeVideo;
        }
    }
    return LTQuickPreviewFileTypeWeb;
}

-(NSURL*)filePathWithWebURL:(NSURL*)webURL{
    NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *quickPreviewCacheFolder = [documentPath stringByAppendingPathComponent:@"LTQuickPreviewCache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:quickPreviewCacheFolder]) {
        [fileManager createDirectoryAtPath:quickPreviewCacheFolder
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    NSString* fileName = [[webURL absoluteString] lastPathComponent];
    NSString* filePath = [quickPreviewCacheFolder stringByAppendingPathComponent:fileName];
    return [NSURL fileURLWithPath:filePath];
}

- (void)downloadFile:(NSURL*)fileURL
            progress:(void (^)(float progress)) downloadProgress
     destinationPath:(NSURL * (^)())destinationPath
            complete:(void (^)(NSURL* filePath,NSError *error))complete{
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask* downloadTask = [self.session downloadTaskWithURL:fileURL];
    
    self.downloadProgress = downloadProgress;
    self.downloadComplete = complete;
    self.destinationPath = destinationPath();
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:_destinationPath.path];
    NSError* error;
    if (fileExists) {
        [fileManager removeItemAtPath:_destinationPath.path error:&error];
    };
    
    [downloadTask resume];
}

#pragma mark - NSURLSessionDelegate
/*
 1.当接收到下载数据的时候调用,可以在该方法中监听文件下载的进度
 该方法会被调用多次
 totalBytesWritten:已经写入到文件中的数据大小
 totalBytesExpectedToWrite:目前文件的总大小
 bytesWritten:本次下载的文件数据大小
 */
-(void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    float progress = 1.0 * totalBytesWritten/totalBytesExpectedToWrite;
    if (self.downloadProgress) {
        self.downloadProgress(progress);
    }
}
/*
 2.恢复下载的时候调用该方法
 fileOffset:恢复之后，要从文件的什么地方开发下载
 expectedTotalBytes：该文件数据的总大小
 */
-(void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{

}
/*
 3.下载完成之后调用该方法
 */
-(void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location{
    NSError* error;
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:self.destinationPath.path error:&error];
}
/*
 4.请求完成之后调用
 如果请求失败，那么error有值
 */
-(void)URLSession:(nonnull NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    if (_downloadComplete) {
        _downloadComplete(self.destinationPath,error);
    }
}

@end
