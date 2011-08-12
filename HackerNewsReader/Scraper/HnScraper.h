//
//  HnScraper.h
//  HackerNewsReader
//
//  Created by Chris on 11/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ScraperBlock)(BOOL success);

@interface HnScraper : NSObject

+ (void)doMainPageScrapeOf:(NSString*)url storeAsPage:(NSString*)page complete:(ScraperBlock)complete;
+ (void)doCommentPageScrapeForArticle:(int)articleId complete:(ScraperBlock)complete;

@end
