//
//  AppDelegate.h
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/2/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "DataManager.h"

#define AccountTwitterAccountAccessGranted @"TwitterAccountAccessGranted"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) ACAccount* twitterAccount;
@property (nonatomic, retain) NSObject* target;
@property (nonatomic) SEL selector;
@property (nonatomic, retain) DataManager* dataManager;
@property (nonatomic, retain) NSMutableDictionary* imagesDictionary;

- (void)getTwitterAccount;

@end
