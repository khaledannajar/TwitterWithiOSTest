//
//  Tweet.h
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/17/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Coordinates;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * tweeteeName;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * tweetText;
@property (nonatomic, retain) NSString * profileImageUrl;
@property (nonatomic, retain) NSString * retweeted;
@property (nonatomic, retain) Coordinates *coordinates;

@end
