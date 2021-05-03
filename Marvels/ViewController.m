//
//  ViewController.m
//  Marvels
//
//  Created by roy orpiano on 06/06/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "ViewController.h"
#import "MarvelCharacter.h"
#import "Master.h"
#import "NSString+MD5.h"

@interface ViewController ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ViewController

@synthesize imageView;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.hidden = YES;

    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"marvel-logo"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:imageView];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeWidth
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeWidth
                              multiplier:(4.0f/5.0f)
                              constant:0.f]];
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeHeight
                              multiplier:(1.0f/5.0f)
                              constant:1.f]];
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0f
                              constant:1.f]];
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:imageView
                              attribute:NSLayoutAttributeCenterY
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterY
                              multiplier:1.0f
                              constant:1.f]];
    
//    WSGetCharacters *getCharacters = [[WSGetCharacters alloc] init];
//    getCharacters.delegate = self;
//    [getCharacters start];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setHTTPAdditionalHeaders:@{@"Accept" : @"*/*"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    long timestamp = time(NULL);
    NSString *publicKey = @"cf75b3a70448823917e8c371d8c8e5cd";
    NSString *privKey = @"90751ac68df2db01d3f4b15a6bd6b4950d9f9349";
    NSString *baseURL = @"https://gateway.marvel.com/v1/public/characters";
    
    NSString *hash = [[NSString stringWithFormat:@"%ld%@%@", timestamp, privKey, publicKey] getMD5String];
    
    NSString *urlWithParam = [NSString stringWithFormat:@"%@?ts=%ld&apikey=%@&hash=%@", baseURL, timestamp, publicKey, hash];
    
    NSURL *url = [NSURL URLWithString:urlWithParam];

    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            
            NSError * error = nil;
            NSDictionary * receivedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSMutableArray *characters = [[NSMutableArray alloc] init];
            
            NSLog(@"received data: %@", receivedData);
            
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
                    [characters addObject:marvelCharacter];
                }
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:etag forKey:@"etag"];
                [defaults synchronize];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                Master *vc = [[Master alloc] init];
                vc.characters = [[NSMutableArray alloc] initWithArray:characters];
                
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                
                [self presentViewController:nav animated:YES completion:nil];
                
                
            });
        }
    }];
    [task resume];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
}


@end
