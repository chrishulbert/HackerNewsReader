//
//  Home.m
//  HackerNewsReader
//
//  Created by Chris on 10/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Home.h"
#import "HnDb.h"
#import "HnScraper.h"
#import "ArticleComments.h"

@implementation Home

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Customisable for subclasses

- (NSString*)baseUrl {
    return @"http://news.ycombinator.com/";
}

- (NSString*)basePage {
    return @"home";
}

- (NSString*)baseTitle {
    return @"Hacker News";
}

#pragma mark - Refresh data

- (void)refreshBnTapped {
    [HnScraper doMainPageScrapeOf:self.baseUrl storeAsPage:self.basePage complete:^(BOOL success) {
        if (success) {
            [self.tableView reloadData];
        } else {
            [[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to server" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease] show];
        }
    }];
    [self stopLoading];
}

- (void) refresh {
    [self performSelector:@selector(refreshBnTapped) withObject:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:127/256.0 green:50/256.0 blue:0 alpha:1];
    self.navigationController.navigationBar.translucent = YES;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Figure out how long since it was last loaded, if >1hour ago, try to load it
    // TODO only load automatically if you're on wifi
    
    // Return the number of rows in the section.
    FMResultSet *s = [[HnDb instance] executeQuery:@"select loaded from pages_loaded where page=?" withArgumentsInArray:$arr(self.basePage)];
    if ([s next]) {
        NSDate* lastLoad = [s dateForColumnIndex:0];
        if (lastLoad.timeIntervalSinceReferenceDate < [[NSDate date] timeIntervalSinceReferenceDate]-60*60) {
            // Loaded more than an hour ago
            [self refreshBnTapped];            
        }
    } else {
        // Not loaded yet at all
        [self refreshBnTapped];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    FMResultSet *s = [[HnDb instance] executeQuery:@"select count(*) from pages where name=?" withArgumentsInArray:$arr(self.basePage)];
    if ([s next]) {
        return [s intForColumnIndex:0];
    }
    return 0;
}

- (NSString*)pluralComments:(int)comments {
    if (comments==0) return @"no comments";
    if (comments==1) return @"1 comment";
    return $str(@"%d comments", comments);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString* sql = @"select a.* from pages p, articles a where p.article_id = a.id and p.position=? and p.name=?";
    FMResultSet *s = [[HnDb instance] executeQuery:sql withArgumentsInArray:$arr($int(indexPath.row+1), self.basePage)];
    if ([s next]) {
        cell.textLabel.text = [s stringForColumn:@"title"];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.text = $str(@"%d points, %@, %@",
                                         [s intForColumn:@"points"],
                                         [self pluralComments:[s intForColumn:@"comments"]],
                                         [s stringForColumn:@"age"]);
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* sql = @"select a.* from pages p, articles a where p.article_id = a.id and p.position=? and p.name=?";
    FMResultSet *s = [[HnDb instance] executeQuery:sql withArgumentsInArray:$arr($int(indexPath.row+1), self.basePage)];
    if ([s next]) {
        NSString *title = [s stringForColumn:@"title"];
        int textWid = self.view.frame.size.width - 40;
        CGSize idealSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:18] 
                             constrainedToSize:CGSizeMake(textWid, 900) 
                                 lineBreakMode:UILineBreakModeWordWrap];
        return idealSize.height+22;   
    }
    return self.tableView.rowHeight;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* sql = @"select a.id from pages p, articles a where p.article_id = a.id and p.position=? and p.name=?";
    FMResultSet *s = [[HnDb instance] executeQuery:sql withArgumentsInArray:$arr($int(indexPath.row+1), self.basePage)];
    if ([s next]) {
        int articleId = [s intForColumnIndex:0];
        
        ArticleComments* ac = [[ArticleComments alloc] initWithNibName:@"ArticleComments" bundle:nil];
        ac.articleId = articleId;
        [ac preNavPushConfigure];
        [self.navigationController pushViewController:ac animated:YES];
    }
}

@end
