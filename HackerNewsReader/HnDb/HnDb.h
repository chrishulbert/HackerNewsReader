//
//  HnDb.h
//  HackerNewsReader
//
//  Created by Chris on 11/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface HnDb : NSObject

@property(nonatomic, retain) FMDatabase* fmdb;

+ (HnDb*)instance;

@end
