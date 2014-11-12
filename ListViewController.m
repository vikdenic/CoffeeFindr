//
//  ListViewController.m
//  CoffeeFind
//
//  Created by Johnny Appleseed on 11/12/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import "ListViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CoffeePlace.h"
#import "DetailViewController.h"

@interface ListViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property CLLocationManager *locationManager;
@property NSArray *coffeePlacesArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property CLLocation *currentLocation;

@end

@implementation ListViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.coffeePlacesArray = [[NSMutableArray alloc]initWithCapacity:5];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self updateCurrentLocation];
}

#pragma mark - CLLocationManagerDelegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = locations[0];
    [self findCoffeePlaces:self.currentLocation];
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Helper methods

-(void)updateCurrentLocation
{
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}
-(void)findCoffeePlaces:(CLLocation *)location
{
    // Retreives data for a local search
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"coffee";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(.05,.05));

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];

    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        NSMutableArray *temporaryArray = [NSMutableArray new];
        // Retrieves data for 5 closest Coffee Places
        for(int i = 0; i < 5; i++)
        {
            MKMapItem *mapItemWithData = [mapItems objectAtIndex:i];

            // Calculates how far user is from coffee place, in miles
            CLLocationDistance metersAway = [mapItemWithData.placemark.location distanceFromLocation:location];
            float milesDifference = metersAway / 1609.34;

            // Creates new CoffeePlace reference
            CoffeePlace *coffeePlace = [[CoffeePlace alloc]init];

            // Sets MKMapItem property for CoffeePlace reference
            coffeePlace.mapItem = mapItemWithData;

            // Sets milesDistance property for CoffeePlace reference
            coffeePlace.milesDifference = milesDifference;

            // Adds CoffeePlace reference to mutable array
            [temporaryArray addObject:coffeePlace];
        }

        // Orders the array of PizzaPlaces by their milesAway property
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"milesDifference" ascending:YES];
        NSArray *sortedArray = [temporaryArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        for (CoffeePlace *cp in sortedArray)
        {
            NSLog(@"Array: %@: %f", cp.mapItem.name, cp.milesDifference);
        }

        self.coffeePlacesArray = [NSArray arrayWithArray:sortedArray];
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coffeePlacesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [[[self.coffeePlacesArray objectAtIndex:indexPath.row] mapItem] name];
    NSString *milesString =[NSString stringWithFormat:@"%.2f mi",[[self.coffeePlacesArray objectAtIndex:indexPath.row] milesDifference]];
    cell.detailTextLabel.text = milesString;
    return cell;
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *detailVC = segue.destinationViewController;
    detailVC.coffeePlace = [self.coffeePlacesArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    detailVC.currentLocation = self.currentLocation;
}

@end
