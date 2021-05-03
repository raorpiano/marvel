//
//  MarvelCharacter.h
//  Marvels
//
//  Created by roy orpiano on 06/06/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MarvelCharacter : NSObject

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *characterId;
@property (nullable, nonatomic, copy) NSString *characterDescription;
@property (nullable, nonatomic, copy) NSString *thumbnailPath;
@property (nullable, nonatomic, copy) NSString *thumbnailExtension;
@property (nullable, nonatomic, copy) NSData *thumbnailImage;
@property (nullable, nonatomic, copy) NSString *thumbnailUrl;

@end
