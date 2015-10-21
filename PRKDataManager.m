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

@property (nonatomic, strong) NSMutableArray *spotsNearDestination;

@end

@implementation PRKDataManager {
	CLLocationCoordinate2D _currentLocationCoordinate;
	CLPlacemark *_destinationPlaceMark;
	NSString *_destinationName;
	int numberOfTries;
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
		self.spotsNearDestination = [NSMutableArray new];
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







#pragma mark - Parking Spots

+ (NSArray *)spotsNearDestination {
	return [[PRKDataManager sharedDataManager] spotsNearDestination];
}

- (NSArray *)spotsNearDestination {
	if (numberOfTries < 20) {
		numberOfTries ++;
		return @[];
	}
	
	PRKSpot *spot1 = [PRKSpot spotWithCoordinate:CLLocationCoordinate2DMake(42.3595269, -71.0653017)];
	spot1.title = @"19 Myrtle St., \nBeacon Hill Area, 02114";
	spot1.numberOfSpots = 2;
	PRKSpot *spot2 = [PRKSpot spotWithCoordinate:CLLocationCoordinate2DMake(42.3650128, -71.0534021)];
	spot2.title = @"348	Hanover St., \nNorth End Boston, 02113";
	spot2.numberOfSpots = 1;
	PRKSpot *spot3 = [PRKSpot spotWithCoordinate:CLLocationCoordinate2DMake(42.361725, -71.052331)];
	spot3.title = @"101	Atlantic Ave., \nNorth End Boston, 02110";
	spot3.numberOfSpots = 2;
	
	NSArray *dummyData = @[spot1, spot2, spot3];
	return dummyData;
	
	return self.spotsNearDestination;
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
