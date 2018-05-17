//
//  QMUIImagePickerCollectionViewCell.h
//  qmui
//
//  Created by 李浩成 on 16/8/29.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIAsset.h"

/**
 *  图片选择空间里的九宫格 cell，支持显示 checkbox、饼状进度条及重试按钮（iCloud 图片需要）
 */
@interface QMUIImagePickerCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong, readonly) UIImageView *contentImageView;
@property(nonatomic, strong, readonly) UIImageView *videoMarkImageView;
@property(nonatomic, strong, readonly) UILabel *videoDurationLabel;
@property(nonatomic, strong, readonly) CAGradientLayer *videoBottomShadowLayer;

@property(nonatomic, assign) QMUIAssetDownloadStatus downloadStatus; // Cell 中对应资源的下载状态，这个值的变动会相应地调整 UI 表现
@property(nonatomic, copy) NSString *assetIdentifier;// 当前这个 cell 正在展示的 QMUIAsset 的 identifier

@end
