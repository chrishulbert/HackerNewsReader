//
//  Best.m
//  HackerNewsReader
//
//  Created by Chris on 10/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Best.h"


@implementation Best

- (NSString*)baseUrl {
    return @"http://news.ycombinator.com/best";
}

- (NSString*)basePage {
    return @"best";
}

- (NSString*)baseTitle {
    return @"Best";
}

@end
