//
//  AppDelegate.m
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/2/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import "AppDelegate.h"
#import <Social/Social.h>

#define AccountTwitterSelectedAccountIdentifier @"TwitterAccountSelectedAccountIdentifier"

@interface AppDelegate () <UIAlertViewDelegate>
@property (nonatomic, retain) ACAccountStore* accountStore;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.accountStore = [[ACAccountStore alloc]init];
    [self getTwitterAccount];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)getTwitterAccount {
    NSLog(@"getTwitterAccount");
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:
                                         ACAccountTypeIdentifierTwitter];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted) {
                
                NSLog(@"getTwitterAccount granted");
                // 1
                NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                
                // 2
                NSString *twitterAccountIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:AccountTwitterSelectedAccountIdentifier];
                self.twitterAccount = [self.accountStore accountWithIdentifier:twitterAccountIdentifier];
                
                // 3
                if (self.twitterAccount) {
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       [[NSNotificationCenter defaultCenter] postNotificationName: AccountTwitterAccountAccessGranted object:nil];
                                   });
                }
                else
                {
                    //      4
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey: AccountTwitterSelectedAccountIdentifier];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    //      5
                    if (twitterAccounts.count > 1)
                    {
                        UIAlertView *alertView = [[UIAlertView alloc]
                                                  initWithTitle:@"Twitter"
                                                  message:@"Select one of your Twitter Accounts" delegate:self
                                                  cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                        for (ACAccount *account in twitterAccounts)
                        {
                            [alertView addButtonWithTitle:
                             account.accountDescription];
                        }
                        dispatch_async( dispatch_get_main_queue(), ^{
                            [alertView show];
                        });
                    }
                    //      6
                    else
                    {
                        self.twitterAccount = [twitterAccounts lastObject];
                        
                        dispatch_async( dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName: AccountTwitterAccountAccessGranted object:nil]; });
                    }
                }
            }
            else
            {
                if (error)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter"
                                                                            message:@"There was an error retrieving your Twitter account, make sure you have an account setup in Settings and that access is granted for iSocial"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"Dismiss"
                                                                  otherButtonTitles:nil];
                        [alertView show]; });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter"
                                                                            message:@"Access to Twitter was not granted. Please go to the device settings and allow access for iSocial"
                                                                           delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles:nil];
                        [alertView show];}
                                   );
                }
                
            }
        }];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [self.accountStore
                                    accountsWithAccountType:twitterAccountType];
        self.twitterAccount = twitterAccounts[(buttonIndex - 1)];
        [[NSUserDefaults standardUserDefaults] setObject:self.twitterAccount.identifier forKey:AccountTwitterSelectedAccountIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:
         AccountTwitterAccountAccessGranted object:nil];
    }
}

@end
