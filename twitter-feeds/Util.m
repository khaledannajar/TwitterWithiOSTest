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
    input = @"Tue Oct 08 21:08:30 +0000 2013";
    
    NSString* year  = [input substringWithRange: NSMakeRange( input.length -4, 4)];
    NSString* month = [input substringWithRange: NSMakeRange( 4, 3)];
    NSString* day   = [input substringWithRange: NSMakeRange( 8, 2)];
    NSString* time  = [input substringWithRange: NSMakeRange(11, 8)];
    
    NSString* output = [NSString stringWithFormat:@"%@ %@ %@ - %@",day,month,year,time];
    return output;
}

@end
