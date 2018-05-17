//
//  TranshFileVC.m
//  FBShareFile
//
//  Created by 张学阳 on 2018/5/8.
//  Copyright © 2018年 Gary. All rights reserved.
//

#import "TranshFileVC.h"
#import "QMUIAssetsManager.h"
#import "QMUIAsset.h"
#import <GCDWebServer/GCDWebServer.h>
#import <GCDWebServer/GCDWebUploader.h>
#import <GCDWebServer/GCDWebServerDataRequest.h>
#import "GCDWebServer.h"
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <GCDWebServer/GCDWebServerStreamedResponse.h>
#import <GCDWebServer/GCDWebServerConnection.h>



@interface TranshFileVC ()<GCDWebUploaderDelegate>
@property (nonatomic, strong) GCDWebUploader *webUploadServer;

@property(nonatomic,strong)GCDWebServer *webServer;

//获取全部相册内容
@property(nonatomic,strong)NSMutableArray *albumsArray;

@property(nonatomic,strong)NSMutableArray *assestSource;

@property(nonatomic,strong)UILabel *titleLabe;

@property(nonatomic,strong)UIImageView *imgView;

@property(nonatomic,strong)NSMutableArray *source;

@end

@implementation TranshFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.titleLabe = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, SCREEN_WIDTH-20, 30)];
    self.titleLabe.textColor = [UIColor greenColor];
    [self.view addSubview:self.titleLabe];
    
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.titleLabe.frame)+20, 100, 100)];
    self.imgView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.imgView];
    
//    http://www.codeforge.cn/article/302098
}

#pragma mark -------- 屏幕点击事件
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    if (self.titleLabe.text) {
        return;
    }
    
     [self getAllAlbumsList];
    
//    [self rigthClick:@""];
}


#pragma mark -------- 异步处理信息
-(void)asynDataImageData:(UIImage *)img contentsOfURL:(NSURL *)contentsOfURL{
    
    _webServer = [[GCDWebServer alloc] init];
    
    
    __weak typeof(self)  weakSelf = self;
    [self.source enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *info = obj[@"info"];
        NSURL *contents = info[@"PHImageFileURLKey"];
        NSData *data = [NSData dataWithContentsOfURL:contents];
        
        [weakSelf.webServer addDefaultHandlerForMethod:@"GET"
                                  requestClass:[GCDWebServerRequest class]
                             asyncProcessBlock:^(GCDWebServerRequest* request, GCDWebServerCompletionBlock completionBlock) {
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                     GCDWebServerDataResponse* response = [GCDWebServerDataResponse responseWithData:data contentType:@"application/x-jpg"];
                                     NSLog(@"request --- %@",request);
                                     completionBlock(response);
                                 });
                             }];
        
        
        
    }];
    

    
    
//    [_webServer addHandlerForMethod:@"GET"
//                               path:@"/images/"
//                       requestClass:[GCDWebServerRequest class]
//                       processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
//                           return [GCDWebServerResponse responseWithRedirect:[NSURL URLWithString:@"img1" relativeToURL:request.URL] permanent:NO];
//                       }];
    

    if ([_webServer start]) {
        NSLog(@"服务器启动");
    } else {
        NSLog(@"启动失败");
    }
    
    NSString *ip = [_webServer.serverURL absoluteString];
    NSLog(@"ip ===== %@",ip);
    
    self.titleLabe.text = ip;
    

}


#pragma mark -------- 加载自定义的网站 显示图片 下载
-(void)loadHtmlData:(NSURL *)source imageData:(UIImage *)img{
    
    NSString* websitePath = [[NSBundle mainBundle] pathForResource:@"Website" ofType:nil];
    
    _webServer = [[GCDWebServer alloc] init];
    
    [_webServer addGETHandlerForBasePath:@"/"
                           directoryPath:websitePath
                           indexFilename:@"index.html"
                                cacheAge:3600
                      allowRangeRequests:YES];
    
    
    
    [_webServer addHandlerForMethod:@"GET"
                    pathRegex:@"/.*\\.html"
                 requestClass:[GCDWebServerRequest class]
                 processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                     NSString *var_title = @"var_title";
                     NSDictionary *variables = @{var_title:source.absoluteString};
                     NSString *wPath = [websitePath stringByAppendingPathComponent:request.path];
                     GCDWebServerDataResponse *dataResponse = [[GCDWebServerDataResponse alloc] initWithHTMLTemplate:wPath variables:variables];
                     return dataResponse;
                 }];


    
//    [_webServer addDefaultHandlerForMethod:@"GET"
//                                      requestClass:[GCDWebServerRequest class]
//                                 asyncProcessBlock:^(GCDWebServerRequest* request, GCDWebServerCompletionBlock completionBlock) {
//                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//                                         NSData *data = [NSData dataWithContentsOfURL:source];
//                                         GCDWebServerDataResponse* response = [GCDWebServerDataResponse responseWithData:data contentType:@"application/x-jpg"];
//                                         NSLog(@"request --- %@",request);
//                                         completionBlock(response);
//
//                                     });
//                                 }];
    
//    [_webServer addHandlerForMethod:@"GET"
//                               path:@"/"
//                       requestClass:[GCDWebServerRequest class]
//                       processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
//                           return [GCDWebServerResponse responseWithRedirect:[NSURL URLWithString:@"/img1" relativeToURL:request.URL] permanent:NO];
//                       }];

    
    if ([_webServer start]) {
        NSLog(@"服务器启动");
    } else {
        NSLog(@"启动失败");
    }

    NSString *ip = [_webServer.serverURL absoluteString];
    NSLog(@"ip ===== %@",ip);
    
    self.titleLabe.text = ip;

}



-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_webServer stop];
}


#pragma mark -------- 获取相册信息
-(void)getAllAlbumsList{
    self.albumsArray = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __weak __typeof(self)weakSelf = self;
        [[QMUIAssetsManager sharedInstance] enumerateAllAlbumsWithAlbumContentType:QMUIAlbumContentTypeAll usingBlock:^(QMUIAssetsGroup *resultAssetsGroup) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 这里需要对 UI 进行操作，因此放回主线程处理
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (resultAssetsGroup) {
                    [strongSelf.albumsArray addObject:resultAssetsGroup];
                } else {
                    //便利完成之后
                    //暂时先取出全部相册的内容
                    QMUIAssetsGroup *group = [strongSelf.albumsArray firstObject];
                    [strongSelf getdataFromNet:group];
                }
            });
        }];
    });
    
}

#pragma mark -------- 获取相册数据
-(void)getdataFromNet:(QMUIAssetsGroup *)group{
    
    QMUIAlbumSortType albumSortType = QMUIAlbumSortTypePositive;
    self.assestSource = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [group enumerateAssetsWithOptions:albumSortType usingBlock:^(QMUIAsset *resultAsset) {
            // 这里需要对 UI 进行操作，因此放回主线程处理
            dispatch_async(dispatch_get_main_queue(), ^{
                if (resultAsset) {
                    [self.assestSource addObject:resultAsset];
                } else {
                    // result 为 nil，即遍历相片或视频完毕
                    QMUIAsset *assest = [self.assestSource firstObject];
//                    NSString *subStr = [[assest.identifier componentsSeparatedByString:@"/"] firstObject];
//                    NSString *urlStr = [NSString stringWithFormat:@"/assets-library://asset/asset.JPG?id=%@&ext=JPG", subStr];
//                    NSURL *strUrl = [NSURL URLWithString:urlStr];
//
//                    NSLog(@"\n\n\n---   %@  \n  ---  %zd",assest.identifier,assest.requestID);
//                    NSLog(@"\n\n\nstrUrl ---------\n %@",strUrl);
//                    NSLog(@"\n\n\burstIdentifier ---------\n %@",assest.phAsset);
                    
//                    NSData *imgData = [NSData dataWithContentsOfURL:strUrl];
//                    UIImage *img = [UIImage imageWithContentsOfFile:strUrl.absoluteString];
//                    self.imgView.image = img;

                    [assest requestThumbnailImageWithSize:CGSizeMake((SCREEN_WIDTH-5*3)/2, (SCREEN_WIDTH-5*3)/2) completion:^(UIImage *result, NSDictionary *info) {
                        if (info[@"PHImageFileURLKey"]) {
                            NSLog(@"info33333  ------ %@",info);
                            NSURL *urlStr1 = info[@"PHImageFileURLKey"];
                            [self loadHtmlData:urlStr1 imageData:result];
//                            [self asynDataImageData:result contentsOfURL:urlStr];
//                            NSData *imgData = [NSData dataWithContentsOfURL:urlStr1];
//                            UIImage *img = [UIImage imageWithContentsOfFile:urlStr1.absoluteString];
//                            self.imgView.image = img;
                        }
                    }];
                    
//                    self.source = [[NSMutableArray alloc] init];
//                    for (int i = 0 ; i<6; i++) {
//                        QMUIAsset *assest = [self.assestSource firstObject];
//                        [assest requestThumbnailImageWithSize:CGSizeMake((SCREEN_WIDTH-5*3)/2, (SCREEN_WIDTH-5*3)/2) completion:^(UIImage *result, NSDictionary<NSString *,id> *info) {
//                            if (info[@"PHImageFileURLKey"]) {
//                                NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
//                                [dicM setValue:result forKey:@"result"];
//                                [dicM setValue:info forKey:@"info"];
//                                [self.source addObject:dicM];
//                            }
//                        }];
//                    }
//
//                    [self asynDataImageData:nil contentsOfURL:nil];
                    
                }
            });
        }];
    });
}


#pragma mark----将照片保存到沙盒
+(void)saveImageToSandbox:(UIImage *)image andImageNage:(NSString *)imageName andResultBlock:(void(^)(BOOL result))block
{
    //高保真压缩图片，此方法可将图片压缩，但是图片质量基本不变，第二个参数为质量参数
    NSData *imageData=UIImageJPEGRepresentation(image, 0.5);
    //将图片写入文件
    NSString *filePath=[self filePath:imageName];
    //是否保存成功
    BOOL result=[imageData writeToFile:filePath atomically:YES];
    //保存成功传值到blcok中
    if (result) {
        block(result);
    }
}

#pragma mark----获取沙盒路径
+(NSString *)filePath:(NSString *)fileName
{
    //获取沙盒目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //保存文件名称
    NSString *filePath=[paths[0] stringByAppendingPathComponent:fileName];
    
    return filePath;
}



-(void)testPhoto{
    
    NSString *urlStr = [NSString stringWithFormat:@"assets-library://asset/asset.JPG?id=%@&amp;amp;ext=JPG", @""];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
   
    PHAsset *asset = fetchResult.firstObject;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeMake(500, 500)
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage *img, NSDictionary *info) {
                                                
                                            }];
}

//NSString *urlStr = [NSString stringWithFormat:@"assets-library://asset/asset.JPG?id=%@&amp;amp;ext=JPG", selectedPhotoArr[index]];
//assets-library://asset/asset.JPG?id=703E488F-9E52-475E-84F9-289DE6A31D00&ext=JPG
//assets-library://asset/asset.JPG?id=CD12228F-0E99-4ABD-999D-6A76F54024E7&ext=JPG
// CD12228F-0E99-4ABD-999D-6A76F54024E7


#pragma mark -------- 直接从沙盒中 取出数据  并上传文件
- (void)rigthClick:(NSString *)soure {
    // Create server
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    // documentsPath = [documentsPath stringByAppendingPathComponent:@"addMusic"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //开始服务器
    _webUploadServer = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    _webUploadServer.delegate = self;
    _webUploadServer.allowHiddenItems = YES;
    
    if ([_webUploadServer start]) {
        NSLog(@"服务器启动");
    } else {
        NSLog(@"启动失败");
    }
    
    //获取IP
    NSString *ip = [_webUploadServer.serverURL absoluteString];
    NSLog(@"ip ===== %@",ip);
    NSInteger index = ip.length - 1;
    ip = [ip substringToIndex:index];
}


#pragma mark -------- GCDWebUploaderDelegate
- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path {
    NSLog(@"[UPLOAD] %@", path);
    // [self.tableView reloadData];
}

- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath {
    NSLog(@"[MOVE] %@ -> %@", fromPath, toPath);
     // [self.tableView reloadData];
}

- (void)webUploader:(GCDWebUploader*)uploader didDeleteItemAtPath:(NSString*)path {
    NSLog(@"[DELETE] %@", path);
    // [self.tableView reloadData];
}

- (void)webUploader:(GCDWebUploader*)uploader didCreateDirectoryAtPath:(NSString*)path {
    NSLog(@"[CREATE] %@", path);
    //  [self.tableView reloadData];
}

@end



/***
 https://stackoverflow.com/questions/28303810/send-uiimage-to-localwebserver-using-gcdwebserver
 https://stackoverflow.com/questions/31382070/convert-ios-photo-album-path-url-same-like-as-document-directory-file-path/31778726#31778726
 解决沙盒路径的问题
 
 一个资产URL看起来像这样
 An asset URL looks like this:
 
 assets-library://asset/asset.JPG?id=CD12228F-0E99-4ABD-999D-6A76F54024E7&ext=JPG
 
 这是ALAssetsLibrary的内部URL，除此之外没有其他含义。你不能指望将这个URL传递给GCDWebServer，并期望服务器神奇地做些事情
 This is an internal URL to ALAssetsLibrary which means nothing outside of this context. You can't expect to pass this URL to GCDWebServer and expect the server to magically do something with it.
 
 
 此外，根据定义，GCDWebServer只能使用HTTP方案提供URL，主机名称与您的iPhone / iPad网络名称匹配，并且与您实施处理程序的路径相匹配。
 Furthermore, GCDWebServer by definition can only serve URLs with the HTTP scheme, with the hostname matching your iPhone/iPad network name, and with paths for which you have implemented handlers.
 
 例如，如果您已为路径/photos/index.html实施了GET处理程序，那么使用您的Web浏览器（http：//my-device.local/photos/index.html）连接到您的iPhone / iPad将调用相应的GCDWebServer上的处理程序，然后可以返回一些内容（如HTML网页或图像文件）。
 For instance if you have implemented a GET handler for the path /photos/index.html, then connecting to your iPhone/iPad using your web browser at http://my-device.local/photos/index.html will call the corresponding handler on GCDWebServer, which then can return some content (like an HTML web page or an image file).
 
 然而，从您的Web浏览器连接到assets-library：//asset/asset.JPG并不意味着什么，并会失败。
 Connecting however to assets-library://asset/asset.JPG from your web browser doesn't mean anything and will fail.
 
 如果您在该路径的GCDWebServer中没有GET处理程序，则连接到http：//my-device.local/asset.JPG？id = CD12228F-0E99-4ABD-999D-6A76F54024E7＆ext = JPG也会失败。
 Connecting to http://my-device.local/asset.JPG?id=CD12228F-0E99-4ABD-999D-6A76F54024E7&ext=JPG will also fail if you don't have a GET handler in GCDWebServer for that path.
 
 
 简而言之，要使用GCDWebServer为ALAssetsLibrary提供照片，您可以这样做：
 So in a nutshell, to serve photos from ALAssetsLibrary using GCDWebServer, you can do it as such:
 
 实现一个默认处理程序来捕获所有的GET请求
 Implement a default handler to catch all GET requests
 
 为GET请求处理/index.html（您必须在默认处理程序后将其添加到GCDWebServer实例）
 Implement a handler for GET requests to /index.html (you must add it to the GCDWebServer instance after the default handler)
 
 在执行/index.html处理程序时，您返回一个HTML网页，其中列出了ALAssetsLibrary中的照片资产的网址，每个网页都有一个相对URL链接，如我的照片链接（资产URL的路径部分）
 In the implementation of the /index.html handler, you return an HTML web page that lists the URLs of the photo assets from ALAssetsLibrary, each of them having a relative URL link like
 
 <a href="/asset.JPG?id=CD12228F-0E99-4ABD-999D-6A76F54024E7&ext=JPG">My photo link</a>
 
 (the path portion of the asset URL).
 
  在默认处理程序的实现中，您可以检索GCDWebServerRequest的路径，
  并预先设置assets-library：// asset，
  然后返回原始资产URL：
 assets-library://asset/asset.JPG？id = CD12228F -0E99-4ABD-999D-6A76F54024E7＆EXT = JPG。
  通过这个URL，您可以最终检索资产数据（即JPEG图像），
 并使用GCDWebServerDataResponse返回它（不要忘记将MIME类型设置为image / jpeg）。
 
 In the implementation of the default handler, you retrieve the path of the GCDWebServerRequest, prepend assets-library://asset, and that gives you back the original asset URL: assets-library://asset/asset.JPG?id=CD12228F-0E99-4ABD-999D-6A76F54024E7&ext=JPG. With this URL, you can finally retrieve the asset data, i.e. the JPEG image, and return it using a GCDWebServerDataResponse (don't forget to set the MIME type to image/jpeg).
 
 
 
 

 ***/
















