//
//  DetailViewController.m
//  CoffeeFind
//
//  Created by Johnny Appleseed on 11/12/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.coffeePlace.mapItem.name;
    [self getPathDirections:self.currentLocation.coordinate withDestination:self.coffeePlace.mapItem.placemark.location.coordinate];
}

#pragma mark - Helper methods
-(void)getPathDirections:(CLLocationCoordinate2D)source withDestination:(CLLocationCoordinate2D)destination{

    MKPlacemark *placemarkSrc = [[MKPlacemark alloc] initWithCoordinate:source addressDictionary:nil];
    MKMapItem *mapItemSrc = [[MKMapItem alloc] initWithPlacemark:placemarkSrc];
    MKPlacemark *placemarkDest = [[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil];
    MKMapItem *mapItemDest = [[MKMapItem alloc] initWithPlacemark:placemarkDest];
    [mapItemSrc setName:@"name1"];
    [mapItemDest setName:@"name2"];

    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:mapItemSrc];
    [request setDestination:mapItemDest];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    request.requestsAlternateRoutes = NO;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];

    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error){
         MKRoute *routeDetails = response.routes.lastObject;
         NSString *allSteps = [NSString new];
         for (int i = 0; i < routeDetails.steps.count; i++)
         {
             MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
             NSString *newStep = step.instructions;
             allSteps = [allSteps stringByAppendingString:newStep];
             allSteps = [allSteps stringByAppendingString:@"\n\n"];
         }
         self.textView.text = allSteps;
         NSLog(@"%@", allSteps);
     }];
}

@end
