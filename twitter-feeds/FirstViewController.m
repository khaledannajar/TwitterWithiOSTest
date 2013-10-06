//
//  FirstViewController.m
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/2/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import "FirstViewController.h"
#import <Twitter/Twitter.h>
#import "AppDelegate.h"

#define TWITTER_BASE_URL (@"https://api.twitter.com/1.1/search/tweets.json")


@interface FirstViewController ()
{
    NSArray *recipeImages;
NSArray *tweetsArray;
}
    @property (strong, nonatomic) NSArray *tweetsArray;
@end

@implementation FirstViewController
@synthesize tweetsArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
//    TODO: show loading view
//    call service
//    https://api.twitter.com/1.1/search/tweets.json?q=%23freebandnames&since_id=24012619984051000&max_id=250126199840518145&result_type=mixed&count=4
//    convert json to object
//    hide loading view
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]
                                delegate];
    if (appDelegate.twitterAccount)
    {

        [self getFeed];
    }else
    {
        NSLog(@"firstViewController tiwtter Account nil");
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeed) name:@"TwitterAccountAcquiredNotification" object:nil];
    
    recipeImages = [NSArray arrayWithObjects:@"angry_birds_cake.jpg", @"creme_brelee.jpg", @"egg_benedict.jpg", @"full_breakfast.jpg", @"green_tea.jpg", @"ham_and_cheese_panini.jpg", @"ham_and_egg_sandwich.jpg", @"hamburger.jpg", @"instant_noodle_with_egg.jpg", @"japanese_noodle_with_pork.jpg", @"mushroom_risotto.jpg", @"noodle_with_bbq_pork.jpg", @"starbucks_coffee.jpg", @"thai_shrimp_cake.jpg", @"vegetable_curry.jpg", @"white_chocolate_donut.jpg", nil];

    UINib* nib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"Cell"];
    
    
}

- (void)getFeed
{
    NSLog(@"getFeed ::: called");
    NSURL *feedURL = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
    // Create an NSDictionary for the twitter request parameters. We specify we want to get 30 tweets though this can be changed to what you like
    NSDictionary *parameters = @{@"count" : @"30"};
    // Create a new TWRequest, use the GET request method, pass in our parameters and the URL
    TWRequest *twitterFeed = [[TWRequest alloc] initWithURL:feedURL
                                                 parameters:parameters
                                              requestMethod:TWRequestMethodGET];
    // Get the shared instance of the app delegate
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // Set the twitter request's user account to the one we downloaded inside our app delegate
    twitterFeed.account = appDelegate.twitterAccount;
    // Enable the network activity indicator to inform the user we're downloading tweets
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    sharedApplication.networkActivityIndicatorVisible = YES;
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
        sharedApplication.networkActivityIndicatorVisible = NO; }];
}

- (void)updateFeed:(id)feedData {
    // We receive the NSArray of tweets and store it in our local tweets array
    self.tweetsArray = (NSArray *)feedData;
//    NSLog(@"tweetsArray = %@", tweetsArray);
//        NSLog(@"feedData = %@", feedData);
    [self.collectionView reloadData];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
            NSLog(@"numberOfItemsInSection %d", self.tweetsArray.count);
//    return recipeImages.count;
    return self.tweetsArray.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//        NSLog(@"sizeForItemAtIndexPath");
//    NSString* string;
//    [string sizeWithFont:[UIFont systemFontOfSize:15] forWidth:50 lineBreakMode:NSLineBreakByWordWrapping];
    return CGSizeMake(250, 200);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
//    NSLog(@"cellForItemAtIndexPath");
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
//    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:2];
//    recipeImageView.image = [UIImage imageNamed:[recipeImages objectAtIndex:indexPath.row]];

    UIImageView *retweetedImageView = (UIImageView *)[cell viewWithTag:1];
    [retweetedImageView setHidden:true];
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:2];
    [profileImageView setHidden:true];

    UIImageView *placesImageView = (UIImageView *)[cell viewWithTag:3];
    [placesImageView setHidden:true];

    UITextView* tweeterNameTxtView = (UITextView*) [cell viewWithTag:4];
        UITextView* tweetedTxtView = (UITextView*) [cell viewWithTag:5];
        UITextView* tweeterDateTxtView = (UITextView*) [cell viewWithTag:6];
    UIButton* saveButton = (UIButton*) [cell viewWithTag:7];
    
//    retweet image : 1
//    profile image: 2
//places: 3
//    tweeter name: 4
//    tweeted text: 5
//    date 6
//    save 7
    
    NSDictionary* oneTweet = [self.tweetsArray objectAtIndex:indexPath.row];
    NSDictionary* user = [oneTweet objectForKey:@"user"];
    
    NSString* tweeteeName = [user objectForKey:@"name"];
    NSString* createdAt =     [oneTweet objectForKey:@"created_at"];
    NSString* tweetText = [oneTweet objectForKey:@"text"];
    NSString* profileImage = [oneTweet objectForKey:@"profile_image_url"];
    NSString* retweetCount = [oneTweet objectForKey:@"retweet_count"];

    NSLog(@"tweeteeName = %@",tweeteeName);
    NSLog(@"createdAt = %@",createdAt);
    NSLog(@"tweetText = %@",tweetText);
    NSLog(@"profileImage = %@",profileImage);
    NSLog(@"retweetCount = %@",retweetCount);
    
    
    
    return cell;
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//    TOTO: remove images from cache dictionary
}

@end
