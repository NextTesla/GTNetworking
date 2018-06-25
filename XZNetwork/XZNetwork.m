//
//  XZNetwork.m
//  LawyerCard_iPhone
//
//  Created by bitzsoft_mac on 16/6/3.
//  Copyright © 2016年 JKing. All rights reserved.
//

#import "XZNetwork.h"
#import "AFNetworking.h"

#ifdef DEBUG
#define XZLog(...) printf("=================\n%s\n=================", [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define XZLog(...) {}
#endif

static NSMutableArray *_sessionTasks;
static AFHTTPSessionManager *_sessionManager;

@implementation XZNetwork

+ (void)initialize
{
    // 储存所有的请求
    _sessionTasks = [NSMutableArray array];
    
    // 初始化 sessionManager
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer.timeoutInterval = 15.f;
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", @"application/json", nil];
}

+ (void)cancelRequest:(NSString *)URLString
{
    if (!URLString || !URLString.length) return;
    @synchronized(self) {
        [_sessionTasks enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URLString]) {
                [task cancel];
                [_sessionTasks removeObject:task];
                *stop = YES;
            }
        }];
    }
}

+ (void)cancelAllRequests
{
    @synchronized(self) {
        [_sessionTasks enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [_sessionTasks removeAllObjects];
    }
}

+ (NSURLSessionTask *)GET:(NSString *)URLString parameters:(id)parameters success:(XZRequestSuccess)success faliure:(XZRequestFailed)failure
{
    NSURLSessionTask *task = [_sessionManager GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        XZLog(@"success: %@", responseObject);
        [_sessionTasks removeObject:task];
        success? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XZLog(@"error: %@", error);
        [_sessionTasks removeObject:task];
        failure? failure(error) : nil;
        
    }];
    
    task? [_sessionTasks addObject:task] : nil;
    
    return task;
}

+ (NSURLSessionTask *)POST:(NSString *)URLString parameters:(id)parameters success:(XZRequestSuccess)success faliure:(XZRequestFailed)failure
{
    NSURLSessionTask *task = [_sessionManager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        XZLog(@"success: %@", responseObject);
        [_sessionTasks removeObject:task];
        success? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XZLog(@"error: %@", error);
        [_sessionTasks removeObject:task];
        failure? failure(error) : nil;
        
    }];
    
    task? [_sessionTasks addObject:task] : nil;
    
    return task;
}

+ (NSURLSessionTask *)uploadImageWithURL:(NSString *)URLString
                              parameters:(id)parameters
                                  images:(NSArray *)images
                                    name:(NSString *)name
                               fileNames:(NSArray *)fileNames
                               imageType:(NSString *)imageType
                           compressRatio:(CGFloat)compressRatio
                                progress:(XZRequestProgress)progress
                                 success:(XZRequestSuccess)success
                                 faliure:(XZRequestFailed)failure
{
    NSURLSessionTask *task = [_sessionManager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (NSUInteger i = 0; i < images.count; i++) {
            // 压缩
            NSData *data = UIImageJPEGRepresentation(images[i], compressRatio ?: 1.f);
            // 图片名称默认为当前时间
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *image_name = fileNames[i] ?: [formatter stringFromDate:[NSDate date]];
            
            NSString *image_type = imageType ?: @"jpg";
            NSString *fileName = [NSString stringWithFormat:@"%@%ld.%@", image_name, i, image_type];
            NSString *mimeType = [NSString stringWithFormat:@"image/%@", image_type];
            
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        XZLog(@"success: %@", responseObject);
        [_sessionTasks removeObject:task];
        success? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XZLog(@"error: %@", error);
        [_sessionTasks removeObject:task];
        failure? failure(error) : nil;
        
    }];
    
    task? [_sessionTasks addObject:task] : nil;
    
    return task;
}

+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URLString
                             parameters:(id)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                               progress:(XZRequestProgress)progress
                                success:(XZRequestSuccess)success
                                faliure:(XZRequestFailed)failure
{
    NSURLSessionTask *task = [_sessionManager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError *error;
        [formData appendPartWithFileURL:[NSURL URLWithString:URLString] name:name error:&error];
        (failure && error) ? failure(error) : nil;
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        XZLog(@"success: %@", responseObject);
        [_sessionTasks removeObject:task];
        success? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        XZLog(@"error: %@", error);
        [_sessionTasks removeObject:task];
        failure? failure(error) : nil;
        
    }];
    
    task? [_sessionTasks addObject:task] : nil;
    
    return task;
}

+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URLString
                               storeDir:(NSString *)storeDir
                               progress:(XZRequestProgress)progress
                                success:(XZRequestSuccess)success
                                faliure:(XZRequestFailed)failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    __block NSURLSessionDownloadTask *task = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *dir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:storeDir ?: @"iDownload"];
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *filePath = [dir stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        XZLog(@"success: %@", response);
        [_sessionTasks removeObject:task];
        
        if (failure && error) { failure(error); return; }
        success? success(filePath.absoluteString) : nil;
        
    }];
    
    [task resume];
    task? [_sessionTasks addObject:task] : nil;
    
    return task;
}


@end
