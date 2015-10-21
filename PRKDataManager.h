//
//  PRKDataManager.h
//  Parkable
//
//  Created by HAI on 10/21/15.
//  Copyright © 2015 Nathan Fennel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PRKDataManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedDataManager;

+ (BOOL)locationPermissionHasBeenRequested;

+ (void)requestedLocationPermission;

+ (CLLocationManager *)locationManager;

@end
