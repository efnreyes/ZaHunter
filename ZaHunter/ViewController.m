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
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
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
        
        self.mapItems = mapItems;
        [self.tableView reloadData];
    }];
}

#pragma mark TableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pizzariaCellID"];
    MKMapItem *item = [self.mapItems objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f km", [self.userLocation distanceFromLocation:[item placemark].location] / 1000.0f];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.mapItems.count > 4) {
        return 4;
    } else {
        return self.mapItems.count;
    }
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
