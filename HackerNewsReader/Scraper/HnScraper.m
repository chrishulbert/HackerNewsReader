//
//  HnScraper.m
//  HackerNewsReader
//
//  Created by Chris on 11/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HnScraper.h"
#import "ASIHTTPRequest.h"
#import "HnDb.h"

//if (![_fmDbSingleton tableExists:@"articles"]) {
//    [_fmDbSingleton executeUpdate:@"create table articles (id int primary key, title text, host text, link text, points int, submitter text, age text, comments int)"];
//}
//if (![_fmDbSingleton tableExists:@"pages"]) {
//    [_fmDbSingleton executeUpdate:@"create table pages (id int primary key, name text, position int, article_id int)"];
//}
@implementation HnScraper

+ (void)parseAndStoreMainPageData:(NSString*)response storeAsPage:(NSString*)page {
    [[HnDb instance] beginTransaction];
    
    [[HnDb instance] executeUpdate:@"delete from pages where name = ?" withArgumentsInArray:$arr(page)];
    
    int rank = 0;
    while (YES) {
        rank++;
        
        // Find the next title
        NSRange rng = [response rangeOfString:@"<td class=\"title\">"];
        if (rng.location == NSNotFound) break;
        response = [response substringFromIndex:rng.location];
        
        // Find the '<a href="'
        rng = [response rangeOfString:@"<a href=\""];
        if (rng.location == NSNotFound) break;
        response = [response substringFromIndex:rng.location+9];
        
        // Find the closing '"'
        rng = [response rangeOfString:@"\""];
        if (rng.location == NSNotFound) break;
        NSString *link = [response substringToIndex:rng.location];

        // Find the '>' at the end of the a href
        rng = [response rangeOfString:@">"];
        if (rng.location == NSNotFound) break;
        response = [response substringFromIndex:rng.location+1];

        // Find the '</a>'
        rng = [response rangeOfString:@"<"];
        if (rng.location == NSNotFound) break;
        NSString *title = [response substringToIndex:rng.location];

        // Find the 'comhead'
        rng = [response rangeOfString:@"<span class=\"comhead\">"];
        if (rng.location == NSNotFound) break;
        response = [response substringFromIndex:rng.location+22];
        
        // Find the '('
        rng = [response rangeOfString:@"("];
        if (rng.location == NSNotFound) break;
        response = [response substringFromIndex:rng.location+1];
        
        // Find the ')'
        rng = [response rangeOfString:@")"];
        if (rng.location == NSNotFound) break;
        NSString* host = [response substringToIndex:rng.location];
        
        // Find: <span id=score_2857424> 
        rng = [response rangeOfString:@"<span id=score_"];
        if (rng.location == NSNotFound) break;
        response = [response substringFromIndex:rng.location+15];

        // Find the closing >
        rng = [response rangeOfString:@">"];
        if (rng.location == NSNotFound) break;
        int articleId = [[response substringToIndex:rng.location] intValue]; // Grab the 2857424 from <span id=score_2857424>
        response = [response substringFromIndex:rng.location+1];
        int points = [response intValue];
        
        // Find: user?id=
        rng = [response rangeOfString:@"user?id="];
        if (rng.location == NSNotFound) break;
        response = [response substringFromIndex:rng.location+8];
        
        // Find the closing quote
        rng = [response rangeOfString:@"\""];
        if (rng.location == NSNotFound) break;
        NSString* submitter = [response substringToIndex:rng.location];

        // Find: </a> 3 days ago  |
        rng = [response rangeOfString:@"</a> "];
        if (rng.location == NSNotFound) break;
        response = [response substringFromIndex:rng.location+5];

        // Find the closing |
        rng = [response rangeOfString:@"  |"];
        if (rng.location == NSNotFound) break;
        NSString* age = [response substringToIndex:rng.location];

        // Find: <a href="item?id=2857424">216 comments</a>
        rng = [response rangeOfString:@"<a href=\"item?id="];
        if (rng.location == NSNotFound) break;
        response = [response substringFromIndex:rng.location];
        
        // Find the end of the <a href="item?id=2857424">
        rng = [response rangeOfString:@">"];
        if (rng.location == NSNotFound) break;
        response = [response substringFromIndex:rng.location+1];
        int comments = [response intValue];
        
        // Save to the database
        [[HnDb instance] executeUpdate:@"insert into pages(name, position, article_id) values(?, ?, ?)" withArgumentsInArray:$arr(page, $int(rank), $int(articleId))];
        [[HnDb instance] executeUpdate:@"delete from articles where id = ?" withArgumentsInArray:$arr($int(articleId))];
        [[HnDb instance] executeUpdate:@"insert into articles(id, title, host, link, points, submitter, age, comments) values (?, ?, ?, ?, ?, ?, ?, ?)"
                  withArgumentsInArray:$arr($int(articleId), title, host, link, $int(points), submitter, age, $int(comments))];
    }
    
    [[HnDb instance] commit];

    /*
     Raw:
     
     <td class="title"><a href="http://jonathanstark.com/card/">Jonathan's Card</a><span class="comhead"> (jonathanstark.com) </span></td></tr><tr><td colspan=2></td><td class="subtext"><span id=score_2857424>717 points</span> by <a href="user?id=ams1">ams1</a> 3 days ago  | <a href="/r?fnid=ApXlEnanfp">flag</a> | <a href="item?id=2857424">216 comments</a></td></tr><tr style="height:5px"></tr><tr><td align=right valign=top class="title">2.</td><td><center><a id=up_2864557 onclick="return vote(this)" href="vote?for=2864557&dir=up&by=chubs&auth=10cdaf23a369e10da08506f65e70b3142afa3385&whence=%62%65%73%74"><img src="http://ycombinator.com/images/grayarrow.gif" border=0 vspace=3 hspace=2></a><span id=down_2864557></span></center></td><td class="title">
     
     Readable:
     
     <tr>
     <td align="right" valign="top" class="title">1.</td>
     
     <td>
     <center>
     <a id="up_2857424" href=
     "vote?for=2857424&amp;dir=up&amp;whence=%62%65%73%74" name=
     "up_2857424"><img src="http://ycombinator.com/images/grayarrow.gif"
     border="0" vspace="3" hspace="2" /></a><span id="down_2857424"></span>
     </center>
     </td>
     
     <td class="title"><a href="http://jonathanstark.com/card/">Jonathan's
     Card</a> <span class="comhead">(jonathanstark.com)</span></td>
     </tr>
     
     <tr>
     <td colspan="2"></td>
     
     <td class="subtext"><span id="score_2857424">717 points</span> by <a href=
     "user?id=ams1">ams1</a> 3 days ago | <a href="item?id=2857424">216
     comments</a></td>
     </tr>
     
     <tr style="height:5px">
     <td></td>
     </tr>
*/
}

// Scrape one of the home pages
+ (void)doMainPageScrapeOf:(NSString*)url storeAsPage:(NSString*)page complete:(ScraperBlock)complete {
    // The __block prevents the callback blocks retaining the request, which would cause a circular leak because the request also retains the completion blocks.
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeOutSeconds = 20; // 60 is a bit long...
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        
        // Parse and store it
        [self parseAndStoreMainPageData:responseString storeAsPage:page];

        // Tell the view that it completed
        complete(YES);
    }];
    [request setFailedBlock:^{
        complete(NO);
    }];
    [request startAsynchronous];
}

#define RngFrom(l) NSMakeRange(l, response.length-l)
#define Search(a) rng=[response rangeOfString:a options:0 range:RngFrom(rng.location)]; if (rng.location == NSNotFound) break;
+ (void)parseAndStoreCommentPage:(NSString*)response storeAsArticle:(int)articleId {
    
    NSRange rng = [response rangeOfString:@"</textarea>"]; // Jump to the start of the comments in the page
    if (rng.location == NSNotFound) return;

    [[HnDb instance] beginTransaction];
    [[HnDb instance] executeUpdate:@"delete from comments where article_id = ?" withArgumentsInArray:$arr($int(articleId))];

    NSRegularExpression* removeTags = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:0 error:nil];

    int position=0;
    while(YES) {
        position++;
        
        // Find the spacer image to get the indent
        Search(@"images/s.gif");
        Search(@"width=");
        rng.location += 6;
        int indent = [[response substringWithRange:NSMakeRange(rng.location, 10)] intValue];
        
        // Get the user id
        Search(@"user?id=");
        rng.location += 8;
        NSRange rngUser = [response rangeOfString:@"\"" options:0 range:RngFrom(rng.location)];
        if (rngUser.location == NSNotFound) break;
        NSString *user = [response substringWithRange:NSMakeRange(rng.location, rngUser.location - rng.location)];
        
        // Get the actual comment
        Search(@"<span class=\"comment\">");
        rng.location += 22;
        NSRange rngComment = [response rangeOfString:@"</span>" options:0 range:RngFrom(rng.location)];
        if (rngComment.location == NSNotFound) break;
        NSString *comment = [response substringWithRange:NSMakeRange(rng.location, rngComment.location - rng.location)];

        comment = [comment stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
        comment = [comment stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        comment = [comment stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
        comment = [removeTags stringByReplacingMatchesInString:comment options:0 range:NSMakeRange(0, comment.length) withTemplate:@""];

        [[HnDb instance] executeUpdate:@"insert into comments(article_id, position, indent, user, comment) values(?, ?, ?, ?, ?)" 
                  withArgumentsInArray:$arr($int(articleId), $int(position), $int(indent), user, comment)];        
    }        
    
    [[HnDb instance] commit];
}

// Scrape a comment page
+ (void)doCommentPageScrapeForArticle:(int)articleId complete:(ScraperBlock)complete {
    // The __block prevents the callback blocks retaining the request, which would cause a circular leak because the request also retains the completion blocks.
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:$str(@"http://news.ycombinator.com/item?id=%d",articleId)]];
    request.timeOutSeconds = 20; // 60 is a bit long...
    [request setCompletionBlock:^{
        NSString *responseString = [request responseString];
        
        // Parse and store it
        [self parseAndStoreCommentPage:responseString storeAsArticle:articleId];
        
        // Tell the view that it completed
        complete(YES);
    }];
    [request setFailedBlock:^{
        complete(NO);
    }];
    [request startAsynchronous];    
}

@end
