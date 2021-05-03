//
//  NSString+FileUrlFromString.h
//  Marvels
//
//  Created by roy orpiano on 08/06/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileUrlFromString)

- (NSURL *)localFilePathForUrlString;

- (BOOL)isLocalFileExistsForUrlString;

@end
