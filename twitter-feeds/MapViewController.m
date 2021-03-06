//
//  MapViewController.m
//  twitter-feeds
//
//  Created by KhaledAnnajar on 10/14/13.
//  Copyright (c) 2013 ALWANS. All rights reserved.
//

#import "MapViewController.h"

#define METERS_PER_MILE 1609.344

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
//    TODO: check size of coordinates
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[self.coordinates objectAtIndex:0] doubleValue];
    coordinates.longitude = [[self.coordinates objectAtIndex:1] doubleValue];
    MKPointAnnotation* point = [[MKPointAnnotation alloc]init];
    point.coordinate = coordinates;
    point.title = self.tweteeTitle;
    
    [self.mapView addAnnotation:point];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinates, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion:region animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissButton:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
