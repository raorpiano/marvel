//
//  MasterTableViewCell.m
//  Marvels
//
//  Created by roy orpiano on 06/06/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "MasterTableViewCell.h"

@implementation MasterTableViewCell

@synthesize characterImageView;
@synthesize nameLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        characterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        characterImageView.translatesAutoresizingMaskIntoConstraints = NO;
        characterImageView.layer.cornerRadius = 5.0;
        characterImageView.clipsToBounds = YES;
        characterImageView.contentMode = UIViewContentModeScaleAspectFit;
        characterImageView.image = [UIImage imageNamed:@"male"];
        [self.contentView addSubview:characterImageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:nameLabel];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(characterImageView, nameLabel);
        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[characterImageView(80)]-8-[nameLabel]-8-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views];
        [self.contentView addConstraints:constraints];
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[characterImageView(80)]-16-|"
                                                              options: 0
                                                              metrics:nil
                                                                views:views];
        [self.contentView addConstraints:constraints];
        
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[nameLabel]-16-|"
                                                              options: 0
                                                              metrics:nil
                                                                views:views];
        [self.contentView addConstraints:constraints];
    }
    
    return self;
}

- (void)downloadImageFormUrl:(NSString *)url
{
    
}

@end
