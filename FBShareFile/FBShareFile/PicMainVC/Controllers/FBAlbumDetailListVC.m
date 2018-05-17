//
//  FBAlbumDetailListVC.m
//  FBShareFile
//
//  Created by 张学阳 on 2018/5/8.
//  Copyright © 2018年 Gary. All rights reserved.
//

#import "FBAlbumDetailListVC.h"
#import "QMUIAsset.h"


@interface PicCollectionViewCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)UIImage *img;
@end

@implementation PicCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    self.imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imgView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255.0)/256.0 green:arc4random_uniform(255.0)/256.0 blue:arc4random_uniform(255.0)/256.0 alpha:1.0];
    self.imgView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.imgView];
}

-(void)setImg:(UIImage *)img{
    self.imgView.image = img;
}

@end



@interface FBAlbumDetailListVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong)NSMutableArray *imagesAssetArray;

@property(nonatomic, assign) BOOL isImagesAssetLoaded;// 这个属性的作用描述：https://github.com/QMUI/QMUI_iOS/issues/219

@property(nonatomic ,strong)UICollectionView *collectionView;
@end

@implementation FBAlbumDetailListVC



- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];

    [self getdataFromNet];
}

#pragma mark -------- 设置主UI
-(void)setupUI{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.minimumLineSpacing = 5;
    flowLayout.minimumLineSpacing = 5;
    
    CGFloat itemHW = SCREEN_WIDTH/2-5*3;
    flowLayout.itemSize = CGSizeMake(itemHW, itemHW);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.collectionView registerClass:[PicCollectionViewCell class] forCellWithReuseIdentifier:@"PicCollectionViewCell"];
    [self.view addSubview:self.collectionView];
}


#pragma mark -------- 数据源方法
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imagesAssetArray.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PicCollectionViewCell" forIndexPath:indexPath];
    QMUIAsset *assest = self.imagesAssetArray[indexPath.item];
    // 异步请求资源对应的缩略图
    [assest requestThumbnailImageWithSize:CGSizeMake((SCREEN_WIDTH-5*3)/2, (SCREEN_WIDTH-5*3)/2) completion:^(UIImage *result, NSDictionary *info) {
        cell.img = result;
    }];
    return cell;
}

#pragma mark -------- 获取相册数据
-(void)getdataFromNet{
    
    QMUIAlbumSortType albumSortType = QMUIAlbumSortTypePositive;
    self.imagesAssetArray = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.assetsGroup enumerateAssetsWithOptions:albumSortType usingBlock:^(QMUIAsset *resultAsset) {
            // 这里需要对 UI 进行操作，因此放回主线程处理
            dispatch_async(dispatch_get_main_queue(), ^{
                if (resultAsset) {
                    self.isImagesAssetLoaded = NO;
                    [self.imagesAssetArray addObject:resultAsset];
                } else {
                    // result 为 nil，即遍历相片或视频完毕
                    self.isImagesAssetLoaded = YES;
                    [self.collectionView reloadData];
                }
            });
        }];
    });
}



@end
