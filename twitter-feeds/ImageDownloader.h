//
//  ImageDownloader.h
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/29/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageDownloader : NSObject
+(void)getProfileImageUrl:(NSString*)profileImageUrl httpsUrl:(NSString*)profileImageUrlHttps forImageView:(UIImageView*) profileImageView inCollectionView:(UICollectionView*) collectionView withIndexPath:(NSIndexPath*)indexPath_;
@end
