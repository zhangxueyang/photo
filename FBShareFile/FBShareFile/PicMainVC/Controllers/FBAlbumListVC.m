//
//  FBAlbumListVC.m
//  FBShareFile
//
//  Created by 张学阳 on 2018/5/8.
//  Copyright © 2018年 Gary. All rights reserved.
//

#import "FBAlbumListVC.h"
#import "QMUIAssetsGroup.h"
#import "QMUIAssetsManager.h"
#import "FBAlbumDetailListVC.h"

@interface FBAlbumListVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *albumsArray;

@end

@implementation FBAlbumListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置导航栏试图
    [self setNavgationView];
    
    //设置主UI
    [self setupMainUI];
    
    //获取资源 刷新表格
    [self authorizedAlbum];
    
}

#pragma mark -------- 设置主ui
-(void)setupMainUI{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.view addSubview:_tableView];
    
}


#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.albumsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    QMUIAssetsGroup *assetsGroup = [self.albumsArray objectAtIndex:indexPath.row];
    // 显示相册缩略图
    cell.imageView.image = [assetsGroup posterImageWithSize:CGSizeMake(40, 40)];
    // 显示相册名称
    cell.textLabel.text = [assetsGroup name];
    // 显示相册中所包含的资源数量
    cell.textLabel.text = [NSString stringWithFormat:@"(%@)", @(assetsGroup.numberOfAssets)];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QMUIAssetsGroup *assetsGroup = [self.albumsArray objectAtIndex:indexPath.row];
    FBAlbumDetailListVC *detailList = [[FBAlbumDetailListVC alloc] init];
    detailList.assetsGroup = assetsGroup;
    [self.navigationController pushViewController:detailList animated:YES];
}

#pragma mark -------- 判断用户有没有授权设备
-(void)authorizedAlbum{
    
    if ([QMUIAssetsManager authorizationStatus] == QMUIAssetAuthorizationStatusNotAuthorized) {
        //已经禁止权限
        NSString *tipString = nil;
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
        if (!appName) {
            appName = [mainInfoDictionary objectForKey:(NSString *)kCFBundleNameKey];
        }
        tipString = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        NSLog(@"tipString ----- %@",tipString);
    }else{
        
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
                        [strongSelf refreshAlbumAndShowEmptyTipIfNeed];
                    }
                });
            }];
        });
    }
    
}

- (void)refreshAlbumAndShowEmptyTipIfNeed {
    if ([self.albumsArray count] > 0) {
        [self.tableView reloadData];
    } else {
//        NSString *tipString = @"空照片";
        //[self showEmptyViewWithText:tipString detailText:nil buttonTitle:nil buttonAction:nil];
        NSLog(@"还没有照片哦");
    }
}


#pragma mark -------- 设置导航栏
-(void)setNavgationView{
    self.view.backgroundColor = [UIColor whiteColor];
     UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancle)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)cancle{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
