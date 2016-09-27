# NetWorkManger
A simple Network request tool base on AFNetWorking.

#useage
 ```objc
 + (instancetype)sharedManager;

/*!
 *  get请求
 *
 *  @param url        接口url
 *  @param parameters 参数
 *  @param success    请求成功的block
 *  @param failure    请求失败的block
 */
+ (void)get:(NSString *)url parameters:(id )parameters success:(void(^)(id responseObject))success faliure:(void(^)(id error))failure;

/*!
 *  post请求
 *
 *  @param url        接口url
 *  @param parameters 参数
 *  @param success    请求成功的block
 *  @param failure    请求失败的block
 */
+ (void)post:(NSString *)url parameters:(id)parameters success:(void(^)(id responseObject))success faliure:(void(^)(id error))failure;

/*!
 *  post请求 不拼接基地址
 *
 *  @param url        接口url
 *  @param parameters 参数
 *  @param success    请求成功的block
 *  @param failure    请求失败的block
 */
+ (void)postNoBaseUrl:(NSString *)url parameters:(id)parameters success:(void(^)(id responseObject))success faliure:(void(^)(id error))failure;


/*!
 *  上传图片(多图)
 *
 *  @param operations  上传图片预留参数 可不填
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
                   UpLoadProgress:(uploadProgress)progress;

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
                   uploadProgress:(uploadProgress)progress;

/*!
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
                  downLoadProgress:(downloadProgress)progress;
 ```
