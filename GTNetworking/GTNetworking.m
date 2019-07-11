//
//  GTNetworking.m
//  LawyerCard_iPhone
//
//  Created by bitzsoft_mac on 16/6/3.
//  Copyright © 2016年 JKing. All rights reserved.
//

#import "GTNetworking.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

static AFHTTPSessionManager *gt_sessionManager;
static NSString *gt_networkBaseUrl = nil;
static BOOL gt_networkBaseUrlChanged = NO;
static NSTimeInterval gt_timeout = 60.f;
static NSDictionary *gt_httpHeaders;
static NSMutableArray *gt_sessionTasks;

@implementation GTNetworking

+ (void)setTimeout:(NSTimeInterval)timeout {
    gt_timeout = timeout;
}

+ (void)configBaseUrl:(NSString *)baseUrl {
    if (baseUrl && baseUrl.length && ![baseUrl isEqualToString:gt_networkBaseUrl]) {
        gt_networkBaseUrlChanged = YES;
    } else {
        gt_networkBaseUrlChanged = NO;
    }
    gt_networkBaseUrl = baseUrl.copy;
}

+ (NSString *)baseUrl {
    return gt_networkBaseUrl;
}

+ (void)configCommonHttpHeader:(NSDictionary *)headers {
    gt_httpHeaders = [headers copy];
}

+ (void)cancelRequestWithURL:(NSString *)url {
    if (!url || !url.length) {
        return;
    }
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:url]) {
                [task cancel];
                [[self allTasks] removeObject:task];
                *stop = YES;
            }
        }];
    }
}

+ (void)cancelAllRequests {
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allTasks] removeAllObjects];
    }
}

+ (NSURLSessionTask *)GET:(NSString *)URLString
               parameters:(id)parameters
                  success:(GTRequestSuccess)success
                  faliure:(GTRequestFailure)failure {
    
    NSURLSessionTask *task = [[self manager] GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        GTLog(@"request success: %@", responseObject);
        [[self allTasks] removeObject:task];
        success? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        GTLog(@"request failure: %@", error);
        [[self allTasks] removeObject:task];
        failure? failure(error) : nil;
        
    }];
    
    task? [[self allTasks] addObject:task] : nil;
    
    return task;
}

+ (NSURLSessionTask *)POST:(NSString *)URLString parameters:(id)parameters success:(GTRequestSuccess)success faliure:(GTRequestFailure)failure {
    
    NSURLSessionTask *task = [[self manager] POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        GTLog(@"success: %@", responseObject);
        [[self allTasks] removeObject:task];
        success? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        GTLog(@"error: %@", error);
        [[self allTasks] removeObject:task];
        failure? failure(error) : nil;
        
    }];
    
    task? [[self allTasks] addObject:task] : nil;
    
    return task;
}

+ (NSURLSessionTask *)uploadImageWithURL:(NSString *)URLString
                              parameters:(id)parameters
                                  images:(NSArray *)images
                                    name:(NSString *)name
                               fileNames:(NSArray *)fileNames
                               imageType:(NSString *)imageType
                           compressRatio:(CGFloat)compressRatio
                                progress:(GTRequestProgress)progress
                                 success:(GTRequestSuccess)success
                                 faliure:(GTRequestFailure)failure {
    
    NSURLSessionTask *task = [[self manager] POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
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
        
        GTLog(@"success: %@", responseObject);
        [[self allTasks] removeObject:task];
        success? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        GTLog(@"error: %@", error);
        [[self allTasks] removeObject:task];
        failure? failure(error) : nil;
        
    }];
    
    task? [[self allTasks] addObject:task] : nil;
    
    return task;
}

+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URLString
                             parameters:(id)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                               progress:(GTRequestProgress)progress
                                success:(GTRequestSuccess)success
                                faliure:(GTRequestFailure)failure {
    
    NSURLSessionTask *task = [[self manager] POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError *error;
        [formData appendPartWithFileURL:[NSURL URLWithString:URLString] name:name error:&error];
        (failure && error) ? failure(error) : nil;
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        GTLog(@"success: %@", responseObject);
        [[self allTasks] removeObject:task];
        success? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        GTLog(@"error: %@", error);
        [[self allTasks] removeObject:task];
        failure? failure(error) : nil;
        
    }];
    
    task? [[self allTasks] addObject:task] : nil;
    
    return task;
}

+ (NSURLSessionTask *)downloadFileWithURL:(NSString *)URLString
                               storeDir:(NSString *)storeDir
                               progress:(GTRequestProgress)progress
                                success:(GTRequestSuccess)success
                                faliure:(GTRequestFailure)failure {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    __block NSURLSessionDownloadTask *task = [[self manager] downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
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
        
        GTLog(@"success: %@", response);
        [[self allTasks] removeObject:task];
        
        if (failure && error) { failure(error); return; }
        success? success(filePath.absoluteString) : nil;
        
    }];
    
    [task resume];
    task? [[self allTasks] addObject:task] : nil;
    
    return task;
}

#pragma mark - Private Methods

+ (AFHTTPSessionManager *)manager {
    @synchronized (self) {
        if (gt_sessionManager == nil || gt_networkBaseUrlChanged) {
            
            gt_networkBaseUrlChanged = NO;
            // 请求时显示菊花
            [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
            
            AFHTTPSessionManager *manager = nil;
            if (gt_networkBaseUrl) {
                manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:gt_networkBaseUrl]];
            } else {
                manager = [AFHTTPSessionManager manager];
            }
            
            for (NSString *key in gt_httpHeaders.allKeys) {
                [manager.requestSerializer setValue:gt_httpHeaders[key] forHTTPHeaderField:key];
            }
            
            manager.requestSerializer.timeoutInterval = gt_timeout;
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                      @"text/html",
                                                                                      @"text/json",
                                                                                      @"text/plain",
                                                                                      @"text/javascript",
                                                                                      @"text/xml",
                                                                                      @"image/*"]];
            gt_sessionManager = manager;
        }
    }
    return gt_sessionManager;
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gt_sessionTasks = [NSMutableArray array];
    });
    return gt_sessionTasks;
}

@end
