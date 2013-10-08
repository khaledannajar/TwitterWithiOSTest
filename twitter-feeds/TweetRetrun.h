//
//  TweetRetrun.h
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/6/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetRetrun : NSObject

@property (nonatomic, retain) NSString* retweetImage;
@property (nonatomic, retain) NSString* profileImage;
@property (nonatomic, retain) NSString* places;
@property (nonatomic, retain) NSString* tweeterName;
@property (nonatomic, retain) NSString* tweetedText;
@property (nonatomic, retain) NSString* date;

@end
