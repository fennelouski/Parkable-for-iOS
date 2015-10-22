//
//  ViewController.h
//  Parkable
//
//  Created by HAI on 10/21/15.
//  Copyright © 2015 Nathan Fennel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PRKDataManager.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>

@interface ViewController : UIViewController <UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate>


@property (nonatomic, strong) MKMapView *mapView;


@end

