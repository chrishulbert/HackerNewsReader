//
//  HnDb.m
//  HackerNewsReader
//
//  Created by Chris on 11/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HnDb.h"
#import "FMDatabase.h"
#import "ConciseKit.h"

@implementation HnDb

// My dodgy singleton
FMDatabase* _fmDbSingleton;
+ (FMDatabase*)instance {
    if (!_fmDbSingleton) {
        NSString* filePath = [[$ documentPath] stringByAppendingPathComponent:@"HnDb.sqlite"];
        _fmDbSingleton = [[FMDatabase alloc] initWithPath:filePath];
    }
    return _fmDbSingleton;
}

// Close and save the database
+ (void)close {
    [_fmDbSingleton close];
    [_fmDbSingleton release];
    _fmDbSingleton = nil;
}

@end
