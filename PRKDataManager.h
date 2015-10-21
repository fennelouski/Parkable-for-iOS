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

/**
 *  Called sparingly to see if the user has granted location permission
 *
 *  @return The user has initially agree to grant locaiton permission
 */
+ (BOOL)locationPermissionHasBeenRequested;

/**
 *  Called exactly once in the entire life of the app once the user has initially agreed to grant location permission
 */
+ (void)requestedLocationPermission;

/**
 *  The one location manager used across the entire app
 *
 *  @return The one location manager used across the entire app
 */
+ (CLLocationManager *)locationManager;


+ (void)findLocationCoordinatesForString:(NSString *)addressString;

+ (CLPlacemark *)destinationPlaceMark;
+ (NSString *)destinationName;

+ (NSArray *)spotsNearDestination;



@end
