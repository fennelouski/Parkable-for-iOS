//
//  PRKSpot.m
//  Parkable
//
//  Created by HAI on 10/21/15.
//  Copyright © 2015 Nathan Fennel. All rights reserved.
//

#import "PRKSpot.h"

@implementation PRKSpot

+ (instancetype)spotWithCoordinate:(CLLocationCoordinate2D)coordinate {
	return [[PRKSpot alloc] initWithCoordinate:coordinate];
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	self = [super init];
	
	if (self) {
		self.coordinate = coordinate;
	}
	
	return self;
}

@end
