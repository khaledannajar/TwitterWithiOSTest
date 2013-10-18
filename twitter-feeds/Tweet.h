//
//  Tweet.h
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/18/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coordinates;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * profileImageUrl;
@property (nonatomic, retain) NSNumber * retweeted;
@property (nonatomic, retain) NSString * tweeteeName;
@property (nonatomic, retain) NSString * tweetText;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) Coordinates *coordinates;

@end
