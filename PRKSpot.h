//
//  PRKSpot.h
//  Parkable
//
//  Created by HAI on 10/21/15.
//  Copyright © 2015 Nathan Fennel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PRKSpot : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSString *title;

@property (nonatomic) NSInteger numberOfSpots;

@end
