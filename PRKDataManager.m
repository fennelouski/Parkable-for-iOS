//
//  PRKDataManager.m
//  Parkable
//
//  Created by HAI on 10/21/15.
//  Copyright © 2015 Nathan Fennel. All rights reserved.
//

#import "PRKDataManager.h"

static NSString * const locationPermissionHasBeenRequestedKey = @"locationPermissionHasBeenRequestedKey";

@interface PRKDataManager ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation PRKDataManager {
	
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
