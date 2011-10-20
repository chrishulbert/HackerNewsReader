//
//  Home.h
//  HackerNewsReader
//
//  Created by Chris on 10/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"

@interface Home : PullRefreshTableViewController {
    
}

- (NSString*)baseUrl;
- (NSString*)basePage;
- (NSString*)baseTitle;

@end
