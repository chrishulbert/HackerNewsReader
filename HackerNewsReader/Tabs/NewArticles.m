//
//  NewArticles.m
//  HackerNewsReader
//
//  Created by Chris on 10/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewArticles.h"

@implementation NewArticles

- (NSString*)baseUrl {
    return @"http://news.ycombinator.com/newest";
}

- (NSString*)basePage {
    return @"newest";
}

- (NSString*)baseTitle {
    return @"New";
}

@end
