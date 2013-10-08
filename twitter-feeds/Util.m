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

@end
