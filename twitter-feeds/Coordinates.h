//
//  Coordinates.h
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/17/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet;

@interface Coordinates : NSManagedObject

@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) Tweet *tweet;

@end
