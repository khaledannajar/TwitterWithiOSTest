//
//  SavedViewController.m
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/18/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import "SavedViewController.h"
#import "AppDelegate.h"
#import "Util.h"
#import "MapViewController.h"
#import "DataManager.h"
#import "Tweet.h"
#import "Coordinates.h"

@interface SavedViewController ()
{
    AppDelegate *appDelegate;
}

@property (nonatomic, retain) DataManager* dataManager;
@property (nonatomic, strong) NSArray *tweets;
@end

@implementation SavedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = [[UIApplication sharedApplication] delegate];
    self.dataManager = appDelegate.dataManager;
    
    [self fetchSavedTweets];
    
    UINib* nib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"Cell"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.tweets = nil;
}

# pragma - mark Collection view methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.tweets count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float width = SCR_WIDTH -10;
    if (IS_IPAD) {
        width = 320;
    }
    
    Tweet* oneTweet = [self.tweets objectAtIndex:indexPath.row];
    
    float height = [oneTweet.height floatValue];
    
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
    UIButton* deleteButton = (UIButton*) [cell viewWithTag:8];
    
    UIButton* saveButton = (UIButton*) [cell viewWithTag:7];
    [saveButton setHidden:YES];

    
    Tweet* oneTweet = [self.tweets objectAtIndex:indexPath.row];
    
    tweeterNameLabel.text = oneTweet.tweeteeName;
    tweetedTxtView.text = oneTweet.tweetText;
    tweeterDateTxtView.text = [Util formatDateStringFromDate:oneTweet.createdAt];
    
    if (oneTweet.retweeted) {
        [retweetedImageView setHidden:NO];
    }else
    {
        [retweetedImageView setHidden:YES];
    }
    
    if ([[NSNull null] isEqual:oneTweet.coordinates]) {
        [placesImageView setHidden:YES];
    }else{
        [placesImageView setHidden:NO];
        
        placesImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                        initWithTarget:self action:@selector(handleTap:)];
        tapGestureRecognizer.delegate = self;
        [placesImageView addGestureRecognizer:tapGestureRecognizer];
    }
    //    TODO test code to be removed
    [profileImageView setImage:[UIImage imageNamed:@"green_tea.jpg"]];
    [profileImageView setHidden:NO];
    //    End test code
    
    [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

#pragma - mark delete button, location methods

-(void) deleteButtonClicked:(UIButton *)button
{
    CGPoint tapLocation = [button.superview convertPoint:button.center toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];

    Tweet* oneTweet = [self.tweets objectAtIndex:indexPath.row];
    [[self.dataManager managedObjectContext] deleteObject:oneTweet];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGPoint tapLocation = [tapGestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];

    Tweet* oneTweet = [self.tweets objectAtIndex:indexPath.row];
    
    MapViewController* mapController = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
    mapController.coordinates = @[oneTweet.coordinates.latitude, oneTweet.coordinates.longitude];
    mapController.tweteeTitle = oneTweet.tweeteeName;
    
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:mapController];
    [self presentViewController:nav animated:YES completion:nil];
}

# pragma - mark fetch core data for tweets
-(void) fetchSavedTweets
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Tweet" inManagedObjectContext:self.dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    self.tweets = [self.dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}
@end
