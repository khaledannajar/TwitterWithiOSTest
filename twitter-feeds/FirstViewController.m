//
//  FirstViewController.m
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/2/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

// check this one TODO:
//https://github.com/episod/twitter-api-fields-as-crowdsourced/wiki/Status-Tweet-fields

#import "FirstViewController.h"
#import <Twitter/Twitter.h>
#import "AppDelegate.h"
#import "Util.h"

#define TWITTER_BASE_URL ([NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"])
#define SCR_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCR_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define IS_IPAD ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound)

@interface FirstViewController ()
{
    NSArray *recipeImages;
    AppDelegate *appDelegate;

}
    @property (strong, nonatomic) NSDictionary *tweetsDic;
    @property (nonatomic, retain) UIApplication *sharedApplication;
    @property (nonatomic, retain) NSString* searchToken;
    @property (nonatomic, retain) NSArray* statuses;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.searchBar = [[UISearchBar alloc]init];

    self.sharedApplication = [UIApplication sharedApplication];
    
    appDelegate = [self.sharedApplication delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeed) name:@"TwitterAccountAcquiredNotification" object:nil];
    

    UINib* nib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"Cell"];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //    TOTO: remove images from cache dictionary
}

#pragma  - mark data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    if (self.statuses) {
        NSLog(@"statuses count %d", self.statuses.count);
        return self.statuses.count;
    } else
    {
        return 0;
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//        NSLog(@"sizeForItemAtIndexPath");
//    NSString* string;
//    [string sizeWithFont:[UIFont systemFontOfSize:15] forWidth:50 lineBreakMode:NSLineBreakByWordWrapping];
    float width = SCR_WIDTH -10;
    if (IS_IPAD) {
        width = 320;
    }
    return CGSizeMake(width, 200);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    UIImageView *retweetedImageView = (UIImageView *)[cell viewWithTag:1];

    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:2];
    [profileImageView setHidden:true];

    UIImageView *placesImageView = (UIImageView *)[cell viewWithTag:3];


    UILabel* tweeterNameLabel = (UILabel*) [cell viewWithTag:4];
        UILabel* tweetedTxtView = (UILabel*) [cell viewWithTag:5];
        UILabel* tweeterDateTxtView = (UILabel*) [cell viewWithTag:6];
    UIButton* saveButton = (UIButton*) [cell viewWithTag:7];
    
    NSDictionary* oneTweet = [self.statuses objectAtIndex:indexPath.row];
    NSDictionary* user = [oneTweet objectForKey:@"user"];
    
    NSString* tweeteeName = [user objectForKey:@"name"];
    NSString* createdAt = [Util formatDateString:[oneTweet objectForKey:@"created_at"]];
    NSString* tweetText = [oneTweet objectForKey:@"text"];
    NSString* profileImage = [oneTweet objectForKey:@"profile_image_url"];
    NSString* retweetCount = [oneTweet objectForKey:@"retweet_count"];
    NSArray* coordinates = [oneTweet objectForKey:@"coordinates"];
    
    NSLog(@"name = %@ createdAt %@, tweetText %@, retweetCount %@, profileImage %@, coordinates %@", tweeteeName, createdAt, tweetText, retweetCount, profileImage, coordinates);

    
    
    tweeterNameLabel.text = tweeteeName;
    tweetedTxtView.text = tweetText;
    tweeterDateTxtView.text = createdAt;

    if ([retweetCount isKindOfClass:[NSNumber class]]) {
        if (retweetCount > 0) {
            [retweetedImageView setHidden:NO];
        }else{
            [retweetedImageView setHidden:YES];
        }
    }else
    {
        if ([[NSNull null] isEqual:retweetCount]) {
            [retweetedImageView setHidden:YES];
        }else{
            [retweetedImageView setHidden:NO];
        }
    }

    if ([Util isEmpty:coordinates] || [[NSNull null] isEqual:coordinates]) {
        [placesImageView setHidden:YES];
    }else{
        [placesImageView setHidden:NO];
        
        placesImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handlePinch:)];
        
        tapGestureRecognizer.delegate = self;
        [placesImageView addGestureRecognizer:tapGestureRecognizer];
    }
    
    [saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

# pragma - mark search bar

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
// return NO to not become first responder
{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;
// called when text starts editing
{
    NSLog(@"searchBarTextDidBeginEditing");
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;
// return NO to not resign first responder
{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
// called when text ends editing
{
        NSLog(@"searchBarTextDidEndEditing");
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
// called when text changes (including clear)
{

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
// called when keyboard search button pressed
{
    self.searchToken = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [searchBar resignFirstResponder];
    if (self.statuses) {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
        NSLog(@"searchBarSearchButtonClicked");
    if (appDelegate.twitterAccount)
    {
        [self getFeed];
    }else
    {
        appDelegate.target = self;
        appDelegate.selector = @selector(getFeed);
        [appDelegate getTwitterAccount];
        
        NSLog(@"searchBarSearchButtonClicked Account nil");
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
// called when cancel button pressed
{
        NSLog(@"searchBarCancelButtonClicked");
    [searchBar resignFirstResponder];
}

#pragma - mark save button, location methods

-(void) saveButtonClicked:(UIButton *)button
{

    CGPoint location = [button.superview convertPoint:button.center toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];

    if (indexPath) {
        NSLog(@"saveButton indexPath is %@", indexPath);
    [self.statuses objectAtIndex:indexPath.row];
        //    TODO: save tweet to core data
        
    }else{
        NSLog(@"saveButton indexPath is nil");
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
        NSLog(@"tapGestureRecognizer");
    // TODO: should move to the map - search for cafe
}


#pragma - mark call service

- (void)getFeed
{
    NSLog(@"getFeed ::: called");
    
    // Create an NSDictionary for the twitter request parameters. We specify we want to get 30 tweets though this can be changed to what you like
    NSDictionary *parameters =
    @{@"q" : self.searchToken,
    @"count" : @"30"};
    
    // Create a new TWRequest, use the GET request method, pass in our parameters and the URL
    SLRequest *twitterFeed  = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                 requestMethod:TWRequestMethodGET
                                                           URL:TWITTER_BASE_URL
                                                    parameters:parameters];
    
    
    // Set the twitter request's user account to the one we downloaded inside our app delegate
    twitterFeed.account = appDelegate.twitterAccount;
    // Enable the network activity indicator to inform the user we're downloading tweets
    self.sharedApplication.networkActivityIndicatorVisible = YES;
    // Perform the twitter request
    [twitterFeed performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error) {
            // If no errors were found then parse the JSON into a foundation object
            NSError *jsonError = nil;
            id feedData = [NSJSONSerialization
                           JSONObjectWithData:responseData options:0
                           error:&jsonError];
            if (!jsonError)
            {
                // If no errors were found during the JSON parsing our feed table
                NSLog(@"! jsonError");
                [self updateFeed:feedData]; }
            else
            {
                // In case we had an error parsing JSON then show alert view with the error's description
                //                ￼￼￼￼￼￼￼￼￼￼￼￼then update
                //                the user an
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[jsonError localizedDescription] delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            } }
        else
        {
            //            successfuly description
            // In case we couldn't perform the twitter request then show the user an alert view with the error's
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[error localizedDescription] delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil]; [alertView show];
        }
        // Stop the network activity indicator since we're done downloading data
        self.sharedApplication.networkActivityIndicatorVisible = NO; }];
}

- (void)updateFeed:(id)feedData {
    if(feedData)
        NSLog(@"updateFeed, feedData != nill");
    else
        NSLog(@"updateFeed, feedData = nill");
    self.tweetsDic = nil;
    self.tweetsDic = (NSDictionary *)feedData;
    self.statuses = [self.tweetsDic objectForKey:@"statuses"];

    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

@end
