//
//  ViewController.m
//  FBShareFile
//
//  Created by 张学阳 on 2018/5/7.
//  Copyright © 2018年 Gary. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "QMUIAssetsManager.h"
#import "FBAlbumListVC.h"
#import "TranshFileVC.h"

#import <SystemConfiguration/CaptiveNetwork.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    TranshFileVC *fileVC = [[TranshFileVC alloc] init];
    [self presentViewController:fileVC animated:YES completion:nil];
    
    
//    NSLog(@"fetchSSIDInfo --- %@",[self fetchSSIDInfo]);
    
}




#pragma mark -------- 获取WiFi 信息
//获取WiFi 信息，返回的字典中包含了WiFi的名称、路由器的Mac地址、还有一个Data(转换成字符串打印出来是wifi名称)
//fetchSSIDInfo --- {
//    BSSID = "88:25:93:cd:f3:f6";
//    SSID = acxw;
//    SSIDDATA = <61637877>;
//}
- (NSDictionary *)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    if (!ifs) {
        return nil;
    }
    NSDictionary *info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    return info;
}








//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    FBAlbumListVC *albumListVC = [[FBAlbumListVC alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:albumListVC];
//    [self presentViewController:nav animated:YES completion:nil];
//}

#pragma mark -------- 判断用户是否有访问相册权限
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 列出所有相册智能相册
    // PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 列出所有用户创建的相册
    // PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    // 获取所有资源的集合，并按资源的创建时间排序
//    PHFetchOptions *options = [[PHFetchOptions alloc] init];
//    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
//    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
//
//    NSLog(@"assetsFetchResults --- %@",assetsFetchResults);
//
//    // 这时 assetsFetchResults 中包含的，应该就是各个资源（PHAsset）
//    for (NSInteger i = 0; i < assetsFetchResults.count; i++) {
//        // 获取一个资源（PHAsset）
//        PHAsset *asset = assetsFetchResults[i];
//        NSLog(@"asset -- %@",asset);
//    }
//}



#pragma mark -------- 获取
//-(void)getImageSouce{
//    [self setupUI];
//
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//        [self.groupSource removeAllObjects];
//        [self.picAssastSource removeAllObjects];
//        [self.picSource removeAllObjects];
//
//        if ([self photoLibraryPermissions]) {//授权成功
//            NSLog(@"选择照片");
//            self.assLibary = [[ALAssetsLibrary alloc] init];
//            [self.assLibary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//                NSLog(@"group --- %@",group);
//                if (group) {
//                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//                    //资源大于
//                    if (group.numberOfAssets > 0) {
//                        [self.groupSource addObject:group];
//
//                        //便利相册数组里边的  照片对象
//                        [group enumerateAssetsWithOptions:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//                            if (result) {
//                                [self.picAssastSource addObject:result];
//                                NSLog(@"result ---    %@",result);
//
//                                // 获取资源图片的详细资源信息，其中 imageAsset 是某个资源的 ALAsset 对象
//                                ALAssetRepresentation *representation = [result defaultRepresentation];
//                                // 获取资源图片的 fullScreenImage
//                                UIImage *contentImage = [UIImage imageWithCGImage:[representation fullScreenImage]];
//
//                                if (contentImage) {
//                                    [self.picSource addObject:contentImage];
//                                }
//
//                            }
//                        }];
//
//                    }
//                }
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.mainCollectionView reloadData];
//                });
//
//
//            } failureBlock:^(NSError *error) {
//                // NSLog(@"error --- %@",error);
//            }];
//
//        }else{
//            NSLog(@"没有授权");
//        }
//
//    });
//}


//-(void)getImageDataSource{
//
//    [self.groupSource removeAllObjects];
//    [self.picAssastSource removeAllObjects];
//    [self.picSource removeAllObjects];
//
//    if ([self photoLibraryPermissions]) {//授权成功
//        NSLog(@"选择照片");
//        self.assLibary = [[ALAssetsLibrary alloc] init];
//        [self.assLibary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//            NSLog(@"group --- %@",group);
//            if (group) {
//                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//                //资源大于
//                if (group.numberOfAssets > 0) {
//                    [self.groupSource addObject:group];
//
//                    //便利相册数组里边的  照片对象
//                    [group enumerateAssetsWithOptions:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
//                        if (result) {
//                            [self.picAssastSource addObject:result];
//                            NSLog(@"result ---    %@",result);
//
//                            // 获取资源图片的详细资源信息，其中 imageAsset 是某个资源的 ALAsset 对象
//                            ALAssetRepresentation *representation = [result defaultRepresentation];
//                            // 获取资源图片的 fullScreenImage
//                            UIImage *contentImage = [UIImage imageWithCGImage:[representation fullScreenImage]];
//
//                            if (contentImage) {
//                                [self.picSource addObject:contentImage];
//                            }
//
//                        }
//                    }];
//
//                }
//            }else{
//                if ([self.groupSource count] > 0) {
//                    // 把所有的相册储存完毕，可以展示相册列表
//                } else {
//                    // 没有任何有资源的相册，输出提示
//                }
//            }
//        } failureBlock:^(NSError *error) {
//            // NSLog(@"error --- %@",error);
//        }];
//
//    }else{
//        NSLog(@"没有授权");
//    }
//}


#pragma mark -------- 便利相册 group 的 照片对象
//相册权限判断
//-(BOOL)photoLibraryPermissions{
//
//    NSString *tipString = nil;
//    //获取 资产库的授权状态
//    ALAuthorizationStatus alAuthorSatatus = [ALAssetsLibrary authorizationStatus];
//
//    if (alAuthorSatatus == ALAuthorizationStatusRestricted || alAuthorSatatus == ALAuthorizationStatusDenied) {
//        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
//        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
//        tipString = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
//        // 展示提示语
//        NSLog(@"tipString === %@",tipString);
//        return NO;
//    }
//
//    NSLog(@"测试一下");
//
//    return YES;
//
//}



/***
 
 Assets Library资产库
 AL Authorization Status 资产库授权状态
 
 
 NS_ENUM_DEPRECATED_IOS(6_0, 9_0)
 ALAuthorizationStatus
 
 //User has not yet made a choice with regards to this application
 //用户尚未对该应用程序作出选择。
 ALAuthorizationStatusNotDetermined
 
 //This application is not authorized to access photo data.
 //此应用程序未被授权访问照片数据。
 
 //The user cannot change this application’s status, possibly due to active restrictions
 //用户无法更改此应用程序的状态，可能是由于活动限制。
 ALAuthorizationStatusRestricted
 
 //User has explicitly denied this application access to photos data.
 //用户已显式地拒绝此应用程序访问照片数据。
 ALAuthorizationStatusDenied
 
 //User has authorized this application to access photos data
 //用户授权此应用程序访问照片数据。
 ALAuthorizationStatusAuthorized
 
 
 

 
 ***/




@end
