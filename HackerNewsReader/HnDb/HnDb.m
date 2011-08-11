//
//  HnDb.m
//  HackerNewsReader
//
//  Created by Chris on 11/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HnDb.h"

@implementation HnDb

@synthesize fmdb;

// My dodgy singleton
HnDb* _hnDbSingleton;
+ (HnDb*)instance {
    if (!_hnDbSingleton) {
        _hnDbSingleton = [[HnDb alloc] init];
    }
    return _hnDbSingleton;
}

- (id)init {
    self = [super init];
    if (self) {
        fmdb = 
    }
    return self;
}

@end
