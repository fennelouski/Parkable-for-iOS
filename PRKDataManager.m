//
//  PRKDataManager.m
//  Parkable
//
//  Created by HAI on 10/21/15.
//  Copyright © 2015 Nathan Fennel. All rights reserved.
//

#import "PRKDataManager.h"
#import "PRKSpot.h"

static NSString * const locationPermissionHasBeenRequestedKey = @"locationPermissionHasBeenRequestedKey";

@interface PRKDataManager ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation PRKDataManager {
	CLLocationCoordinate2D _currentLocationCoordinate;
	CLPlacemark *_destinationPlaceMark;
	NSString *_destinationName;
}

+(instancetype)sharedDataManager {
	static PRKDataManager *sharedDataManager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedDataManager = [[PRKDataManager alloc] init];
	});
	
	return sharedDataManager;
}


- (instancetype)init {
	self = [super init];
	
	if (self) {
		[self startLocationManager];
	}
	
	return self;
}




#pragma mark - Location

+ (BOOL)locationPermissionHasBeenRequested {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	return [defaults boolForKey:locationPermissionHasBeenRequestedKey];
}

+ (void)requestedLocationPermission {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:YES forKey:locationPermissionHasBeenRequestedKey];
}

+ (CLLocationManager *)locationManager {
	return [[PRKDataManager sharedDataManager] locationManager];
}

+ (void)findLocationCoordinatesForString:(NSString *)addressString {
	[[PRKDataManager sharedDataManager] findLocationCoordinatesForString:addressString];
}

- (void)findLocationCoordinatesForString:(NSString *)addressString {
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	_destinationPlaceMark = nil;
	_destinationName = addressString;
	[geocoder geocodeAddressString:addressString
				 completionHandler:^(NSArray* placemarks, NSError* error) {
		for (CLPlacemark* aPlacemark in placemarks) {
			_currentLocationCoordinate = aPlacemark.location.coordinate;
			_destinationPlaceMark = aPlacemark;
		}
	}];
}


#pragma mark - Destination Information

+ (CLPlacemark *)destinationPlaceMark {
	return [[PRKDataManager sharedDataManager] destinationPlaceMark];
}

- (CLPlacemark *)destinationPlaceMark {
	return _destinationPlaceMark;
}

+ (NSString *)destinationName {
	return [[PRKDataManager sharedDataManager] destinationName];
}

- (NSString *)destinationName {
	return _destinationName;
}

- (void)startLocationManager {
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	[self.locationManager startUpdatingLocation];
	
	if ([PRKDataManager locationPermissionHasBeenRequested]) {
		[self.locationManager requestWhenInUseAuthorization];
	}
}

@end
