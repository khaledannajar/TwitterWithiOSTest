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
#import "MapViewController.h"
#import "DataManager.h"
#import "Tweet.h"
#import "Coordinates.h"

#define TWITTER_BASE_URL ([NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"])

#define HEIGHT_DICTIONARY_KEY (@"height")
@interface FirstViewController ()
{
    NSArray *recipeImages;
    AppDelegate *appDelegate;

}
    @property (strong, nonatomic) NSDictionary *tweetsDic;
    @property (nonatomic, retain) UIApplication *sharedApplication;
    @property (nonatomic, retain) NSString* searchToken;
    @property (nonatomic, retain) NSMutableArray* statuses;
@property (nonatomic, retain) DataManager* dataManager;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    self.sharedApplication = [UIApplication sharedApplication];
    
    appDelegate = [self.sharedApplication delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeed) name:@"TwitterAccountAcquiredNotification" object:nil];
    

    UINib* nib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"Cell"];
    
    self.dataManager = appDelegate.dataManager;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //    TOTO: remove images from cache dictionary
}

#pragma  - mark data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.statuses.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float width = SCR_WIDTH -10;
    if (IS_IPAD) {
        width = 320;
    }
    
    NSDictionary* oneTweet = [self.statuses objectAtIndex:indexPath.row];

    float height = [[oneTweet objectForKey:HEIGHT_DICTIONARY_KEY] floatValue];
    
    return CGSizeMake(width, height);
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
    
    UIButton* deleteButton = (UIButton*) [cell viewWithTag:8];
    [deleteButton setHidden:YES];
    
    NSDictionary* oneTweet = [self.statuses objectAtIndex:indexPath.row];
    NSDictionary* user = [oneTweet objectForKey:@"user"];
    
    NSString* tweeteeName = [user objectForKey:@"name"];
    NSString* createdAt = [Util formatDateString:[oneTweet objectForKey:@"created_at"]];
    NSString* tweetText = [oneTweet objectForKey:@"text"];
    NSString* profileImageUrl = [user objectForKey:@"profile_image_url"];
    NSString* profileImageUrlHttps = [user objectForKey:@"profile_image_url_https"];
    NSNumber* retweeted = [oneTweet objectForKey:@"retweeted"];


    NSArray* coordinates = [oneTweet objectForKey:@"coordinates"];
    
    NSLog(@"name = %@ createdAt %@, tweetText %@, retweetCount %@, profileImage %@, coordinates %@", tweeteeName, createdAt, tweetText, retweeted,
          profileImageUrl, coordinates);

    
    
    tweeterNameLabel.text = tweeteeName;
    tweetedTxtView.text = tweetText;
    tweeterDateTxtView.text = createdAt;

    if ([retweeted boolValue]) {
            [retweetedImageView setHidden:NO];
    }else
    {
            [retweetedImageView setHidden:YES];
    }

    if ([Util isEmpty:coordinates] || [[NSNull null] isEqual:coordinates]) {
        [placesImageView setHidden:YES];
    }else{
        [placesImageView setHidden:NO];
        
        placesImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleTap:)];
        
        tapGestureRecognizer.delegate = self;
        [placesImageView addGestureRecognizer:tapGestureRecognizer];
    }
    
//    TODO: download images in updateFeed method to fix images override each other
    BOOL httpImage = ![[NSNull null] isEqual:profileImageUrl] && ! [Util isEmpty:profileImageUrl];
    BOOL httpsImage = ![[NSNull null] isEqual:profileImageUrlHttps] && ! [Util isEmpty:profileImageUrlHttps];
    if (httpImage || httpsImage) {
        
        NSString* tmpImageUrl = httpImage?profileImageUrl:profileImageUrlHttps;
        
        NSData* imageData = [appDelegate.imagesDictionary objectForKey:tmpImageUrl];
        if (imageData) {
            
            profileImageView.image = [UIImage imageWithData:imageData];
            
        }else{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSURL *imageURL = [NSURL URLWithString:tmpImageUrl];
                __block NSData *imageData;
                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                              ^{
                                  imageData = [NSData dataWithContentsOfURL:imageURL];
                                  
                                  [appDelegate.imagesDictionary setObject:imageData forKey:tmpImageUrl];
                                  [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                              });
            });
        }
    }
    [profileImageView setHidden:NO];
    
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

}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;
// return NO to not resign first responder
{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
// called when text ends editing
{
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

    CGPoint tapLocation = [button.superview convertPoint:button.center toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];

    if (indexPath) {
        NSLog(@"saveButton indexPath is %@", indexPath);
    [self.statuses objectAtIndex:indexPath.row];
        
        NSManagedObjectContext *context = [self.dataManager managedObjectContext];
        Tweet* tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:context];
        
        NSDictionary* oneTweet = [self.statuses objectAtIndex:indexPath.row];

        NSDictionary* user = [oneTweet objectForKey:@"user"];
        NSString* tweeteeName = [user objectForKey:@"name"];
        
        tweet.tweeteeName = tweeteeName;
        tweet.createdAt = [Util getTwitterDateFromString:[oneTweet objectForKey:@"created_at"]];
        tweet.tweetText = [oneTweet objectForKey:@"text"];
        tweet.profileImageUrl = [oneTweet objectForKey:@"profile_image_url"];
        NSNumber* retweeted = [oneTweet objectForKey:@"retweeted"];
        tweet.retweeted = retweeted;
        tweet.height = [NSNumber numberWithFloat:[[oneTweet objectForKey:HEIGHT_DICTIONARY_KEY] floatValue]];
        NSDictionary* coordinatesDict = [oneTweet objectForKey:@"coordinates"];
        if (![[NSNull null] isEqual:coordinatesDict] ) {
            NSArray* coordinatesArray = [coordinatesDict objectForKey:@"coordinates"];
            tweet.coordinates = [NSEntityDescription insertNewObjectForEntityForName:@"Coordinates" inManagedObjectContext:context];
            tweet.coordinates.tweet = tweet;
            tweet.coordinates.longitude = [coordinatesArray objectAtIndex:0];
            tweet.coordinates.latitude = [coordinatesArray objectAtIndex:1];
        }
        [appDelegate.dataManager saveContext];
        NSLog(@"tweet = %@ coordinates=%@ ",tweet, tweet.coordinates);
        
    }else{
        NSLog(@"saveButton indexPath is nil");
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint tapLocation = [tapGestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    
    
    NSDictionary* oneTweet = [self.statuses objectAtIndex:indexPath.row];
    NSDictionary* coordinatesDict = [oneTweet objectForKey:@"coordinates"];
    NSArray* coordinatesArray = [coordinatesDict objectForKey:@"coordinates"];
    NSDictionary* user = [oneTweet objectForKey:@"user"];
    
    NSString* tweeteeName = [user objectForKey:@"name"];
    
    MapViewController* mapController = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
    mapController.coordinates = coordinatesArray;
    mapController.tweteeTitle = tweeteeName;
    
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:mapController];
    [self presentViewController:nav animated:YES completion:nil];
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

    self.tweetsDic = (NSDictionary *)feedData;
    self.statuses = [NSMutableArray arrayWithArray:[self.tweetsDic objectForKey:@"statuses"]];

    
    float image_up_space = 11;
    float image_height = 46;
    float image_tweet_txt_height = 20;
    float tweet_text_button_height = 12;
    float button_height = 32;
    float tweet_txt_height = 40;
    float underButtonHeight = 10;
    
    float width = SCR_WIDTH -10;
    if (IS_IPAD) {
        width = 320;
    }
    for (int index=0; index < self.statuses.count; index++) {
        NSMutableDictionary* oneTweet = [NSMutableDictionary dictionaryWithDictionary:[self.statuses objectAtIndex:index]];
        NSString* string = [oneTweet objectForKey:@"text"];
        tweet_txt_height = [string sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(width, 19 * 10) lineBreakMode:NSLineBreakByWordWrapping].height;

        float height = image_up_space + image_height + image_tweet_txt_height + tweet_text_button_height + button_height + tweet_txt_height + underButtonHeight;
        [oneTweet setObject:[NSNumber numberWithFloat:height] forKey:HEIGHT_DICTIONARY_KEY];
        [self.statuses setObject:oneTweet atIndexedSubscript:index];
    }
    
    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

@end
