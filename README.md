GTNetworking
=========

## What
A simple Network request tool based on AFNetWorking.

一个基于AFNetWorking的集约型网络请求封装.

## Useage

```
/**
 *  获取当前baseUrl
 */
+ (NSString *)baseUrl;

/**
 *  设置baseUrl
 *
 *  @param baseUrl AFNetworking的baseUrl
 */
+ (void)configBaseUrl:(NSString *)baseUrl;

/**
 *  设置超时时间
 *
 *  @param timeout 超时时间 单位:秒
 */
+ (void)setTimeout:(NSTimeInterval)timeout;

/**
 *  设置通用请求头 只需要配置一次即可
 *
 *  @param headers 请求头
 */
+ (void)configCommonHttpHeader:(NSDictionary *)headers;

/**
 *  取消指定请求
 *
 *  @param url 请求的url
 */
+ (void)cancelRequestWithURL:(NSString *)url;

/**
 *  取消所有请求
 */
+ (void)cancelAllRequests;

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
+ (NSURLSessionTask *)GET:(NSString *)URLString parameters:(id)parameters success:(GTRequestSuccess)success faliure:(GTRequestFailure)failure;


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
+ (NSURLSessionTask *)POST:(NSString *)URLString parameters:(id)parameters success:(GTRequestSuccess)success faliure:(GTRequestFailure)failure;

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
                                progress:(GTRequestProgress)progress
                                 success:(GTRequestSuccess)success
                                 faliure:(GTRequestFailure)failure;


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
                               progress:(GTRequestProgress)progress
                                success:(GTRequestSuccess)success
                                faliure:(GTRequestFailure)failure;


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
                               progress:(GTRequestProgress)progress
                                success:(GTRequestSuccess)success
                                faliure:(GTRequestFailure)failure;
```
