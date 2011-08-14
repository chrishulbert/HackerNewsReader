//
//  ArticleComments.m
//  HackerNewsReader
//
//  Created by Chris on 12/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArticleComments.h"

#import "HnDb.h"
#import "HnScraper.h"

@implementation ArticleComments

@synthesize articleId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem* refreshBn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions)];
        self.navigationItem.rightBarButtonItem = refreshBn;
        [refreshBn release];
    }
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

#pragma mark - Activity helper

- (void)showActivity {
    UIActivityIndicatorView* act = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [act startAnimating];
    int gap = (self.navigationController.navigationBar.frame.size.height - act.frame.size.height) / 2;
    act.frame = CGRectOffset(act.frame, self.navigationController.navigationBar.frame.size.width-41-gap-act.frame.size.width, gap);
    [self.view addSubview:act];
    [act release];
}

- (void)hideActivity {
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Refresh data

- (void)refreshBnTapped {
    [self showActivity];
    [HnScraper doCommentPageScrapeForArticle:self.articleId complete:^(BOOL success) {
        [self hideActivity];
        if (success) {
            [self.tableView reloadData];
        } else {
            [[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not connect to server" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease] show];
        }
    }];
}

#pragma mark - Show options

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [self refreshBnTapped];
    }
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
        // Open HN page
        NSURL *url = [NSURL URLWithString:$str(@"http://news.ycombinator.com/item?id=%d", self.articleId)];
        [[UIApplication sharedApplication] openURL:url];
    }
    if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
        // Open link
        FMResultSet *s = [[HnDb instance] executeQuery:@"select link from articles where id=?" withArgumentsInArray:$arr($int(self.articleId))];
        if ([s next]) {
            NSURL *hn = [NSURL URLWithString:@"http://news.ycombinator.com/"];
            NSURL *url = [NSURL URLWithString:[s stringForColumnIndex:0] relativeToURL:hn];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)showActions {
    UIActionSheet* actions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Refresh", @"Open comments in Safari", @"Open link in Safari", nil];
    [actions showFromTabBar:self.tabBarController.tabBar];
    [actions release];
}

#pragma mark - View lifecycle

- (void)preNavPushConfigure {
    // Return the number of rows in the section.
    FMResultSet *s = [[HnDb instance] executeQuery:@"select * from articles where id=?" withArgumentsInArray:$arr($int(self.articleId))];
    if ([s next]) {
        self.title = [s stringForColumn:@"title"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    FMResultSet *s = [[HnDb instance] executeQuery:@"select count(*) from comments where article_id=?" withArgumentsInArray:$arr($int(self.articleId))];
    if ([s next]) {
        return [s intForColumnIndex:0];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString* sql = @"select * from comments where article_id=? and position=?";
    FMResultSet *s = [[HnDb instance] executeQuery:sql withArgumentsInArray:$arr($int(self.articleId), $int(indexPath.row+1))];
    if ([s next]) {
        cell.textLabel.text = [s stringForColumn:@"comment"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.detailTextLabel.text = [s stringForColumn:@"user"];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* sql = @"select * from comments where article_id=? and position=?";
    FMResultSet *s = [[HnDb instance] executeQuery:sql withArgumentsInArray:$arr($int(self.articleId), $int(indexPath.row+1))];
    if ([s next]) {
        NSString *comment = [s stringForColumn:@"comment"];
        int textWid = self.view.frame.size.width - 20;
        CGSize idealSize = [comment sizeWithFont:[UIFont systemFontOfSize:18] 
                               constrainedToSize:CGSizeMake(textWid, 900) 
                                   lineBreakMode:UILineBreakModeWordWrap];
        return idealSize.height+22;
    }
    return self.tableView.rowHeight;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
