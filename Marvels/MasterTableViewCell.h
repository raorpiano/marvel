//
//  MasterTableViewCell.h
//  Marvels
//
//  Created by roy orpiano on 06/06/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MasterTableViewCell;

@protocol MasterTableViewCellDelegate <NSObject>

- (void)imageDownloadDidFinished:(MasterTableViewCell *)cell;

@end

@interface MasterTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *characterImageView;
@property (strong, nonatomic) UILabel *nameLabel;

@property (weak, nonatomic) id<MasterTableViewCellDelegate> delegate;

- (void)downloadImageFormUrl:(NSString *)url;

@end
