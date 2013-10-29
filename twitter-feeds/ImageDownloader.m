//
//  ImageDownloader.m
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/29/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import "ImageDownloader.h"
#import "AppDelegate.h"
#import "Util.h"

#define ALREADY_DOWNLOADING_STATE ([NSNull null])

@implementation ImageDownloader

+(void)getProfileImageUrl:(NSString*)profileImageUrl httpsUrl:(NSString*)profileImageUrlHttps forImageView:(UIImageView*) profileImageView inCollectionView:(UICollectionView*) collectionView withIndexPath:(NSIndexPath*)indexPath_
{
       AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    BOOL httpImage = ![[NSNull null] isEqual:profileImageUrl] && ! [Util isEmpty:profileImageUrl];
    BOOL httpsImage = ![[NSNull null] isEqual:profileImageUrlHttps] && ! [Util isEmpty:profileImageUrlHttps];
    if (httpImage || httpsImage) {
        
        NSString* tmpImageUrl = httpImage?profileImageUrl:profileImageUrlHttps;
        
        NSData* imageData = [appDelegate.imagesDictionary objectForKey:tmpImageUrl];
        if (imageData) {
            if (![imageData isEqual:ALREADY_DOWNLOADING_STATE]) {
                profileImageView.image = [UIImage imageWithData:imageData];
            }else{
                profileImageView.image = [UIImage imageNamed:@"person-placeholder.jpg"];
            }
            
        }else{
            profileImageView.image = [UIImage imageNamed:@"person-placeholder.jpg"];//TODO: USE this image instead of pending state
            [appDelegate.imagesDictionary setObject:ALREADY_DOWNLOADING_STATE forKey:tmpImageUrl];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSURL *imageURL = [NSURL URLWithString:tmpImageUrl];
                __block NSData *imageData;
                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                              ^{
                                  imageData = [NSData dataWithContentsOfURL:imageURL];
                                  if (imageData) {
                                      
                                      [appDelegate.imagesDictionary setObject:imageData forKey:tmpImageUrl];
                                      
                                      NSArray* indecies = [collectionView indexPathsForVisibleItems];
                                      for (NSIndexPath* path in indecies) {
                                          if ([indexPath_ isEqual:path]) {
                                              UICollectionViewCell* cell_ = [collectionView cellForItemAtIndexPath:indexPath_];
                                              UIImageView *profileImageView_ = (UIImageView *)[cell_ viewWithTag:2];
                                              profileImageView_.image = [UIImage imageWithData:[appDelegate.imagesDictionary objectForKey:tmpImageUrl]];
                                          }
                                      }
                                      NSLog(@"contains = <%d>", [indecies containsObject:indexPath_]);
                                      
                                  }
                              });
            });
        }
    }
    [profileImageView setHidden:NO];
}

@end
