//
//  HnDb.m
//  HackerNewsReader
//
//  Created by Chris on 11/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HnDb.h"
#import "ConciseKit.h"

@implementation HnDb

// My dodgy singleton
FMDatabase* _fmDbSingleton;
+ (FMDatabase*)instance {
    if (!_fmDbSingleton) {
        NSString* filePath = [[$ documentPath] stringByAppendingPathComponent:@"HnDb.sqlite"];
        _fmDbSingleton = [[FMDatabase alloc] initWithPath:filePath];
        _fmDbSingleton.logsErrors = YES;
        [_fmDbSingleton open];
        
        if (![_fmDbSingleton tableExists:@"articles"]) {
            [_fmDbSingleton executeUpdate:@"create table articles (id int primary key, title text, host text, link text, points int, submitter text, age text, comments int)"];
        }
        if (![_fmDbSingleton tableExists:@"pages"]) {
            [_fmDbSingleton executeUpdate:@"create table pages (id int primary key, name text, position int, article_id int)"];
        }
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
