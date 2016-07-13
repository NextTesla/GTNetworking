//
//  NetWorkManager.m
//  NetWorkManager
//
//  Created by JKing on 16/6/3.
//  Copyright © 2016年 JKing. All rights reserved.
//

#import "NetWorkManager.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>

static NSString * const BaseURLString = @"http://www.baidu.com";

@implementation NetWorkManager

+ (instancetype)sharedManager
{
    static NetWorkManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[NetWorkManager alloc] initWithBaseURL:[NSURL URLWithString:BaseURLString]];
        _sharedManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        /*! 超时时间 */
        self.requestSerializer.timeoutInterval = 10.0;
        
        /*! 设置返回数据为json, 分别设置请求以及相应的序列化器 */
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        /*! 设置相应的缓存策略 */
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        /*! 设置apikey ------类似于自己应用中的tokken---此处仅仅作为测试使用*/
        //        [manager.requestSerializer setValue:apikey forHTTPHeaderField:@"apikey"];
        
        /*! 复杂的参数类型 需要使用json传值-设置请求内容的类型*/
        //        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        /*! 设置响应数据的基本类型 */
        [self.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/javascript",@"text/html", nil]];
    }
    return self;
}

/**
 *  上传图片(多图)
 *
 *  @param operations  上传图片预留参数---视具体情况而定 可移除
 *  @param imageArray  上传的图片数组
 *  @param targetWidth 图片目标压缩宽度
 *  @param urlString   上传的url
 *  @param success     上传成功的回调
 *  @param failure     上传失败的回调
 *  @param progress    上传进度
 */
- (void)uploadImageWithOperations:(NSDictionary *)operations
                       imageArray:(NSArray *)imageArray
                      targetWidth:(CGFloat)targetWidth
                        urlString:(NSString *)urlString
                          success:(void (^)(id obj))success
                          failure:(void (^)(NSError *error))failure
                   UpLoadProgress:(uploadProgress)progress
{
    NSLog(@"请求地址----%@\n    请求参数----%@", urlString, imageArray);
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [[NetWorkManager sharedManager] POST:urlString parameters:operations constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSUInteger i = 0;
        
        /*! 出于性能考虑,将上传图片进行压缩 */
        for (UIImage *image in imageArray)
        {
            /*! image的分类方法 */
            UIImage *resizedImage = [UIImage IMGCompressed:image targetWidth:targetWidth];
            
            NSData *imgData = UIImageJPEGRepresentation(resizedImage, 1.0);
            
            /*! 拼接data */
            [formData appendPartWithFileData:imgData name:@"file" fileName:@"user_head.jpg" mimeType:@"image/jpg"];
            i ++;
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"上传进度--%lld,总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"上传图片成功 = %@",responseObject);
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"上传图片失败 = %@",error);
        failure(error);
        
    }];
}


/*!
 *  视频上传
 *
 *  @param operations   上传视频预留参数 可不填
 *  @param videoPath    上传视频的本地沙河路径
 *  @param urlString    上传的url
 *  @param success      成功的回调
 *  @param failure      失败的回调
 *  @param progress     上传的进度
 */
+ (void)uploadVideoWithOperaitons:(NSDictionary *)operations
                        urlString:(NSString *)urlString
                        videoPath:(NSString *)videoPath
                          success:(void (^)(id obj))success
                          failure:(void (^)(NSError *error))failure
                   uploadProgress:(uploadProgress)progress
{
    /*! 获得视频资源 */
    AVURLAsset *avAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];
    
    /*! 压缩 */
    
    //    NSString *const AVAssetExportPreset640x480;
    //    NSString *const AVAssetExportPreset960x540;
    //    NSString *const AVAssetExportPreset1280x720;
    //    NSString *const AVAssetExportPreset1920x1080;
    //    NSString *const AVAssetExportPreset3840x2160;
    
    AVAssetExportSession  *  avAssetExport = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
    
    /*! 创建日期格式化器 */
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    
    /*! 转化后直接写入Library---caches */
    
    NSString *  videoWritePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/output-%@.mp4",[formatter stringFromDate:[NSDate date]]]];
    
    
    avAssetExport.outputURL = [NSURL URLWithString:videoWritePath];
    
    
    avAssetExport.outputFileType =  AVFileTypeMPEG4;
    
    [avAssetExport exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([avAssetExport status]) {
            case AVAssetExportSessionStatusCompleted:
            {
                [[NetWorkManager sharedManager] POST:urlString parameters:operations constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    
                    //获得沙盒中的视频内容
                    
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:videoWritePath] name:@"write you want to writre" fileName:videoWritePath mimeType:@"video/mpeg4" error:nil];
                    
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                    NSLog(@"上传进度--%lld,总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
                    
                    if (progress)
                    {
                        progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
                    }
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
                    
                    NSLog(@"上传视频成功 = %@",responseObject);
                    if (success)
                    {
                        success(responseObject);
                    }
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    if (failure)
                    {
                        failure(error);
                    }
                }];
                
                break;
            }
            default:
                break;
        }
        
    }];
}


/**
 *  文件下载
 *
 *  @param operations 文件下载预留参数 可不填
 *  @param urlString  请求路径
 *  @param savePath   下载文件保存路径
 *  @param success    成功回调
 *  @param failure    失败回调
 *  @param progress   下载进度
 */
- (void)downLoadFileWithOperations:(NSDictionary *)operations
                         urlString:(NSString *)urlString
                          savaPath:(NSString *)savePath
                           success:(void (^)(id obj))success
                           failure:(void (^)(NSError *error))failure
                  downLoadProgress:(downloadProgress)progress
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionTask *task = nil;
    task = [manager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"下载进度：%.2lld%%",100 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        /*! 回到主线程刷新UI */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (progress)
            {
                progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
            
        });

    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (!savePath)
        {
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            NSLog(@"默认路径--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
        }
        else
        {
            return [NSURL fileURLWithPath:savePath];
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        JXLog(@"下载文件成功");
        if (error == nil)
        {
            if (success)
            {
                /*! 返回完整路径 */
                success([filePath path]);
            }
            else
            {
                if (failure)
                {
                    failure(error);
                }
            }
        }
    }];
}

@end
