//
//  ViewController.m
//  ZaHunter
//
//  Created by Efrén Reyes Torres on 8/6/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Pizzaria.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
@property CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *mapItems;
@property CLLocation *userLocation;
@property UILabel *tableFooter;
@property NSMutableArray *travelTimes;
@property NSMutableArray *pizzariaLocations;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.travelTimes = [[NSMutableArray alloc] init];
    self.pizzariaLocations = [[NSMutableArray alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    CGRect footerRect = CGRectMake(0, 0, 320, 40);
    self.tableFooter = [[UILabel alloc] initWithFrame:footerRect];
    self.tableFooter.textColor = [UIColor blueColor];
    self.tableFooter.backgroundColor = [self.tableView backgroundColor];
    self.tableFooter.opaque = YES;
    self.tableFooter.font = [UIFont boldSystemFontOfSize:15];
    self.tableFooter.numberOfLines = 3;
    self.tableFooter.text = @"Test";
    self.tableView.tableFooterView = self.tableFooter;
}


-(void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks firstObject];
//        NSString *address = [NSString stringWithFormat:@"%@ %@ \n%@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality];
        [self findPizzaria:placemark.location];
    }];
}

-(void)findPizzaria:(CLLocation *) location {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = [response.mapItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {

			// get the locations
			CLLocation *locationObj1 = [(MKMapItem *)obj1 placemark].location;
			CLLocation *locationObj2 = [(MKMapItem *)obj2 placemark].location;
			// calculate distances with current location
			NSNumber *distanceObj1 = [NSNumber numberWithDouble:[locationObj1 distanceFromLocation:location]];
			NSNumber *distanceObj2 = [NSNumber numberWithDouble:[locationObj2 distanceFromLocation:location]];

			return [distanceObj1 compare:distanceObj2];
		}];

        if (mapItems.count > 4) {
            for (int i = 0; i < 4; i++) {
                [self.pizzariaLocations addObject:[mapItems objectAtIndex:i]];
            }
        }
        
        self.mapItems = mapItems;

        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];

        for (MKMapItem *nextLocation in self.pizzariaLocations) {
            [self getDirectionsFromPoint:currentLocation toPoint:nextLocation];
            currentLocation = nextLocation;
        }

        double totalTravelTime = 0;
        int counter = 1;
        for (NSDecimalNumber *time in self.travelTimes) {
            totalTravelTime += ([time doubleValue] + 50);

        }

        int hours = floor(totalTravelTime/(60*60));
        int minutes = floor((totalTravelTime/60) - hours * 60);
        int seconds = floor(totalTravelTime - (minutes * 60) - (hours * 60 * 60));

        self.tableFooter.text = [NSString stringWithFormat: @"It will take you about %d:%d:%d hrs\nto hunt all the za...", hours, minutes, seconds];
        [self.tableView reloadData];
    }];
}

-(void)getDirectionsFromPoint:(MKMapItem *)mapItemA toPoint:(MKMapItem *)mapItemB {
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = mapItemA;
    request.destination = mapItemB;
    request.transportType = MKDirectionsTransportTypeWalking;
    request.requestsAlternateRoutes = NO;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = response.routes.firstObject;
        [self.travelTimes addObject:[NSDecimalNumber numberWithFloat:route.expectedTravelTime]];
        NSLog(@"%f", route.expectedTravelTime);
    }];
}

#pragma mark TableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pizzariaCellID"];
    MKMapItem *item = [self.pizzariaLocations objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f km", [self.userLocation distanceFromLocation:[item placemark].location] / 1000.0f];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.pizzariaLocations.count;
}

#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        [self reverseGeocode:location];
        [self.locationManager stopUpdatingLocation];
        self.userLocation = location;
        break;
    }
}

@end
