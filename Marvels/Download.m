//
//  Download.m
//  Marvels
//
//  Created by roy orpiano on 08/06/2017.
//  Copyright © 2017 raorpiano. All rights reserved.
//

#import "Download.h"

@implementation Download

- (id _Nonnull )init:(NSString *_Nullable)url
{
    self = [super self];
    
    if (self) {
        _url = url;
    }
    
    return self;
}

@end
