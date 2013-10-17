//
//  Util.m
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/8/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import "Util.h"

@implementation Util

+( BOOL) isEmpty:(id) thing
{
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

+(NSString*) formatDateString:(NSString*) input
{
    NSDate *date= [Util getTwitterDateFromString:input];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-yyyy HH:MM "];
    return[    dateFormatter stringFromDate:date];
}

+(NSDate*) getTwitterDateFromString:(NSString*) input
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss +SSSS yyyy"];
    
    NSDate *date=[dateFormatter dateFromString:input];
    return date;
}

@end
