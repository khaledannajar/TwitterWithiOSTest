//
//  MapViewController.h
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/14/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) NSArray* coordinates;
@property (retain, nonatomic) NSString* tweteeTitle;
- (IBAction)dismissButton:(id)sender;

@end
