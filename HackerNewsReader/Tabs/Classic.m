//
//  Classic.m
//  HackerNewsReader
//
//  Created by Chris on 10/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Classic.h"


@implementation Classic

- (NSString*)baseUrl {
    return @"http://news.ycombinator.com/classic";
}

- (NSString*)basePage {
    return @"classic";
}

- (NSString*)baseTitle {
    return @"Classic";
}

@end
