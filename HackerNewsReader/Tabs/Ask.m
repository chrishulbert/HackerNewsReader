//
//  Ask.m
//  HackerNewsReader
//
//  Created by Chris Hulbert on 14/08/11.
//  Copyright 2011 Splinter Software. All rights reserved.
//

#import "Ask.h"


@implementation Ask

- (NSString*)baseUrl {
    return @"http://news.ycombinator.com/ask";
}

- (NSString*)basePage {
    return @"ask";
}

- (NSString*)baseTitle {
    return @"Ask";
}

@end
