//
//  ViewController.m
//  LocalExplorer
//
//  Created by Wang, Jinlian on 6/13/14.
//  Copyright (c) 2014 capitalone. All rights reserved.
//

#import "ViewController.h"
#import "SearchResultDetailsUIViewController.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIPopoverController *popover;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 1000.0f;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(newLocation.coordinate, MKCoordinateSpanMake(1, 1));
    [self.mapView setRegion:region animated:YES];
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.region = region;
    request.naturalLanguageQuery = @"chinese restaurant";
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        NSMutableArray *placemarks = [[NSMutableArray alloc] init];
        if (!error) {
            for (MKMapItem *mapItem in [response mapItems]) {
                NSLog(@"Name: %@, Placemark title: %@", [mapItem name], [[mapItem placemark] title]);
                /*
                SearchResultAnnotation *annotation = [[SearchResultAnnotation alloc] init];
                annotation.title = [[mapItem placemark] title];
                annotation.subtitle = [mapItem name];
                annotation.coordinate = [[[mapItem placemark] location] coordinate];
                 */
                [placemarks addObject:mapItem.placemark];
                MKCircle *circle = [MKCircle circleWithCenterCoordinate:mapItem.placemark.coordinate radius:6000.0f];
                [self.mapView addOverlay:circle];
            }
            [self.mapView addAnnotations:placemarks];
            //[self.mapView addAnnotations:response.mapItems];
            
            MKDirectionsRequest *walkingRouteRequest = [[MKDirectionsRequest alloc] init];
            walkingRouteRequest.transportType = MKDirectionsTransportTypeAutomobile;
            [walkingRouteRequest setSource:[[response mapItems] objectAtIndex:0]];
            [walkingRouteRequest setDestination :[[response mapItems] objectAtIndex:1]];
            
            MKDirections *walkingRouteDirections = [[MKDirections alloc] initWithRequest:walkingRouteRequest];
            [walkingRouteDirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * walkingRouteResponse, NSError *walkingRouteError) {
                if (walkingRouteError) {
                    //[self handleDirectionsError:walkingRouteError];
                } else {
                    // The code doesn't request alternate routes, so add the single calculated route to
                    // a previously declared MKRoute property called walkingRoute.
                    [self.mapView addOverlay:[(MKRoute *)walkingRouteResponse.routes[0] polyline]];
                }
            }];
            
        } else {
            NSLog(@"Search Request Error: %@", [error localizedDescription]);
        }
    }];
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    MKAnnotationView *pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"test"];
    pinView.image = [UIImage imageNamed:@"icon_atm_pin_atm"];
    pinView.canShowCallout = NO;
    return pinView;
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    SearchResultDetailsUIViewController *controller = [[SearchResultDetailsUIViewController alloc] init];
    controller.annotation = (MKPlacemark*)view.annotation;
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popover presentPopoverFromRect:view.bounds inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    popover.popoverContentSize = CGSizeMake(500, 300);
    self.popover = popover;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay{
    if([overlay isKindOfClass:[MKCircle class]]){
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        renderer.strokeColor = [UIColor redColor];
        return renderer;
    } else if([overlay isKindOfClass:[MKPolyline class]]){
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        renderer.strokeColor = [UIColor blueColor];
        return renderer;
    }
    return nil;
}

@end
