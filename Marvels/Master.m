//
//  Master.m
//  Marvels
//
//  Created by roy orpiano on 06/06/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "Master.h"
#import "MarvelCharacter.h"
#import "MasterTableViewCell.h"
#import "Detail.h"
#import "Download.h"
#import "NSString+FileUrlFromString.h"

@interface Master () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSString *etag;

@property (strong, nonatomic) NSURLSessionTask *dataTask;
@property (strong, nonatomic) NSURLSession *defaultSession;
@property (strong, nonatomic) NSMutableDictionary *activeDownloads;
@property (strong, nonatomic) NSURLSession *downloadsSession;

@end

@implementation Master

@synthesize characters;
@synthesize dataTask;
@synthesize defaultSession;
@synthesize activeDownloads;
@synthesize downloadsSession;

BOOL downloadingMore;

- (NSURLSession *)downloadsSession {
    
    if (downloadsSession != nil) {
        return downloadsSession;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"bgSessionConfiguration"];
    
    //    [configuration setHTTPAdditionalHeaders:@]
    
    downloadsSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    return downloadsSession;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    activeDownloads = [[NSMutableDictionary alloc] init];
    defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    downloadsSession = [self downloadsSession];
    
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Marvel Characters";
    
    [self.tableView registerClass:[MasterTableViewCell class] forCellReuseIdentifier:@"master"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pauseDownload:(MarvelCharacter *)character
{
    NSString *urlString = character.thumbnailUrl;
    Download *download = activeDownloads[urlString];
    if (download) {
        if (download.isDownloading) {
            [download.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                if (resumeData != nil) {
                    download.resumeData = resumeData;
                    download.isDownloading = NO;
                }
            }];
        }
    }
}

- (void)resumDownload:(MarvelCharacter *)character
{
    NSString *urlString = character.thumbnailUrl;
    Download *download = activeDownloads[urlString];
    NSData *resumeData = download.resumeData;
    if (resumeData != nil) {
        download.downloadTask = [downloadsSession downloadTaskWithResumeData:resumeData];
        [download.downloadTask resume];
        download.isDownloading = YES;
    } else {
        NSURL *url = [NSURL URLWithString:download.url];
        if (url) {
            download.downloadTask = [downloadsSession downloadTaskWithURL:url];
            [download.downloadTask resume];
            download.isDownloading = YES;
        }
    }
}

- (void)startDownload:(MarvelCharacter *)character
{
    if (character.thumbnailUrl) {
        NSURL *url = [NSURL URLWithString:character.thumbnailUrl];
        
        Download *download = [[Download alloc] init:character.thumbnailUrl];
        download.downloadTask = [downloadsSession downloadTaskWithURL:url];
        
        [download.downloadTask resume];
        download.isDownloading = YES;
        
        activeDownloads[download.url] = download;
    }
    
}

- (int)characterIndexForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    NSString *url = [downloadTask.originalRequest.URL absoluteString];
    
    int index = 0;
    for (MarvelCharacter *character in characters) {
        if ([url isEqualToString:character.thumbnailUrl])
            return index;
        
        ++index;
    }
    
    return -1;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [characters count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MasterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"master" forIndexPath:indexPath];
    
    MarvelCharacter *marvelCharacter = [characters objectAtIndex:indexPath.row];
    cell.nameLabel.text = marvelCharacter.name;
    
    if ([marvelCharacter.thumbnailUrl isLocalFileExistsForUrlString]) {
        NSURL *thumbnailUrl = [marvelCharacter.thumbnailUrl localFilePathForUrlString];
        cell.characterImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnailUrl]];
    } else {
        NSLog(@"downloading...");
        [self startDownload:marvelCharacter];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MarvelCharacter *marvelCharacter = [characters objectAtIndex:indexPath.row];
    Detail *vc = [[Detail alloc] init];
    vc.marvelCharacter = marvelCharacter;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ScrollViewDelegate methods
/*
- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
                  willDecelerate:(BOOL)decelerate
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 50;
    if(y > h + reload_distance) {
        
        if (downloadingMore)
            return;
        
        NSLog(@"load more rows");
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *etag;
        if ([defaults objectForKey:@"etag"]) {
            WSGetCharacters *getMoreCharacters = [[WSGetCharacters alloc] init];
            etag = [defaults objectForKey:@"etag"];
            _etag = etag;
            
            getMoreCharacters.delegate = self;
            [getMoreCharacters startWithEtag:_etag];
        }
        
        downloadingMore = YES;
        
    }
}


#pragma mark - WSGetCharactersDelegate methods
- (void)GetCharactersWebServiceDidFinished:(NSDictionary *)receivedData withError:(NSError *)error
{
    NSMutableArray *moreCharacters = [[NSMutableArray alloc] init];
    
    if (receivedData) {
        if ([receivedData[@"code"] integerValue] == 200) {
            NSString *etag = receivedData[@"etag"];
            
            NSArray *comics = [[NSArray alloc] initWithArray:receivedData[@"data"][@"results"] ];
            for (NSDictionary *item in comics) {
                MarvelCharacter *marvelCharacter = [MarvelCharacter new];
                marvelCharacter.characterId = item[@"id"];
                marvelCharacter.name = item[@"name"];
                marvelCharacter.characterDescription = item[@"description"];
                marvelCharacter.thumbnailPath = item[@"thumbnail"][@"path"];
                marvelCharacter.thumbnailExtension = item[@"thumbnail"][@"extension"];
                marvelCharacter.thumbnailUrl = [NSString stringWithFormat:@"%@.%@", item[@"thumbnail"][@"path"], item[@"thumbnail"][@"extension"]];
                [moreCharacters addObject:marvelCharacter];
            }
            
            if (![_etag isEqualToString:etag]) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:etag forKey:@"etag"];
                [defaults synchronize];
                
                [characters addObjectsFromArray:moreCharacters];
                [self.tableView reloadData];
            }
            
        }
    }
    
    downloadingMore = NO;
}
*/
 
#pragma mark - NSURLSessionDelegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Finished downloading");
    
    NSString *originalURL = [downloadTask.originalRequest.URL absoluteString];
    NSURL *destinationURL = [originalURL localFilePathForUrlString];
    NSLog(@"Destination url: %@", destinationURL);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    @try {
        [fileManager removeItemAtURL:destinationURL error:nil];
    } @catch (NSException *exception) {
        //
    } @finally {
        @try {
            [fileManager copyItemAtURL:location toURL:destinationURL error:nil];
        } @catch (NSException *exception) {
            NSLog(@"Could not copy file to disk");
        } @finally {
            //
        }
    }
    
    NSString *url = [downloadTask.originalRequest.URL absoluteString];
    if (url) {
        activeDownloads[url] = nil;
        
        int characterIndex = [self characterIndexForDownloadTask:downloadTask];
        if (characterIndex != -1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:characterIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });
        }
    }
    
}

@end
