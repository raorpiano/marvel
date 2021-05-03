//
//  Detail.m
//  Marvels
//
//  Created by roy orpiano on 06/06/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "Detail.h"
#import "DetailTableViewCell.h"
#import "MarvelCharacter.h"
#import "NSString+FileUrlFromString.h"

@interface Detail () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *characters;
@property (strong, nonatomic) UIImage *image;

@end

@implementation Detail

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView registerClass:[DetailTableViewCell class] forCellReuseIdentifier:@"detail"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 1.0f)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _characters = [[NSMutableArray alloc] init];
    [_characters addObject:_marvelCharacter];
    [self.tableView reloadData];
    
    _image = [UIImage imageNamed:@"male"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_characters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
    
    MarvelCharacter *marvelCharacter = [_characters objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = marvelCharacter.name;
    cell.descriptionLabel.text = marvelCharacter.characterDescription;
    cell.imgPath = marvelCharacter.thumbnailPath;
    cell.characterImageView.image = _image;
    
    if ([marvelCharacter.thumbnailUrl isLocalFileExistsForUrlString]) {
        NSURL *thumbnailUrl = [marvelCharacter.thumbnailUrl localFilePathForUrlString];
        cell.characterImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnailUrl]];
    } else {
        NSLog(@"Download image");
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@.%@", marvelCharacter.thumbnailPath, marvelCharacter.thumbnailExtension]];
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            _image = [UIImage imageWithData:data];
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    marvelCharacter.thumbnailImage = data;
                    [self.tableView reloadData];
                });
            }
        }];
        [task resume];
    }
    
    return cell;
}

@end
