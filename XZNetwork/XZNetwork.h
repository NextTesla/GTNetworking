//
//  XZNetwork.h
//  LawyerCard_iPhone
//
//  Created by bitzsoft_mac on 16/6/3.
//  Copyright © 2016年 JKing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XZRequestMethod) {
    XZRequestMethodGET = 0,
    XZRequestMethodPOST,
    XZRequestMethodHEAD,
    XZRequestMethodPUT,
    XZRequestMethodDELETE,
    YTKRequestMethodPATCH
};

/// 请求成功block
typedef void(^XZRequestSuccess)(id responseData);
/// 请求失败block
typedef void(^XZRequestFailed)(NSError *error);
/// 上传、下载进度block
typedef void(^XZRequestProgress)(NSProgress *progress);

@interface XZNetwork : NSObject

/// 取消指定URL的网络请求
+ (void)cancelRequest:(NSString *)URLString;
/// 取消所有网络请求
+ (void)cancelAllRequests;

///**
// *  发起请求
// *
// *  @param URLString  请求地址
// *  @param parameters 请求参数
// *  @param success    请求成功回调
// *  @param failure    请求失败回调
// *
// *  @return 此次请求任务
// */
//+ (NSURLSessionTask *)request:(NSString *)URLString method:(XZRequestMethod)method parameters:(id)parameters success:(XZRequestSuccess)success faliure:(XZRequestFailed)failure;

/**
 *  GET请求
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param success    请求成功回调
 *  @param failure    请求失败回调
 *
 *  @return 此次请求任务
 */
+ (NSURLSessionTask *)GET:(NSString *)URLString parameters:(id)parameters success:(XZRequestSuccess)success faliure:(XZRequestFailed)failure;

/**
 *  POST请求
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param success    请求成功回调
 *  @param failure    请求失败回调
 *
 *  @return 此次请求任务
 */
+ (NSURLSessionTask *)POST:(NSString *)URLString parameters:(id)parameters success:(XZRequestSuccess)success faliure:(XZRequestFailed)failure;


/**
 *  上传图片
 *
 *  @param URLString      请求地址
 *  @param parameters     请求参数
 *  @param images         图片数组
 *  @param name           服务器对应字段
 *  @param fileNames      图片名称
 *  @param imageType      图片类型 (默认:jpg)
 *  @param compressRatio  压缩比例 (0.f ~ 1.f)
 *  @param progress       上传进度回调
 *  @param success        请求成功回调
 *  @param failure        请求失败回调
 *
 *  @return 此次请求任务
 */
+ (NSURLSessionTask *)uploadImageWithURL:(NSString *)URLString
                              parameters:(id)parameters
                                  images:(NSArray *)images
                                    name:(NSString *)name
                               fileNames:(NSArray *)fileNames
                               imageType:(NSString *)imageType
                           compressRatio:(CGFloat)compressRatio
                                progress:(XZRequestProgress)progress
                                 success:(XZRequestSuccess)success
                                 faliure:(XZRequestFailed)failure;


/**
 *  上传文件
 *
 *  @param URLString      请求地址
 *  @param parameters     请求参数
 *  @param name           服务器对应字段
 *  @param filePath       文件沙盒路径
 *  @param progress       上传进度回调
 *  @param success        请求成功回调
 *  @param failure        请求失败回调
 *
 *  @return 此次请求任务
 */
+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URLString
                             parameters:(id)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                               progress:(XZRequestProgress)progress
                                success:(XZRequestSuccess)success
                                faliure:(XZRequestFailed)failure;

/**
 *  下载文件
 *
 *  @param URLString      请求地址
 *  @param storeDir       文件储存目录
 *  @param progress       下载进度回调
 *  @param success        请求成功回调
 *  @param failure        请求失败回调
 *
 *  @return 此次请求任务
 */
+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URLString
                               storeDir:(NSString *)storeDir
                               progress:(XZRequestProgress)progress
                                success:(XZRequestSuccess)success
                                faliure:(XZRequestFailed)failure;


@end
