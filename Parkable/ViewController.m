//
//  ViewController.m
//  Parkable
//
//  Created by HAI on 10/21/15.
//  Copyright © 2015 Nathan Fennel. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+AppColors.h"
#import "PRKSpot.h"

#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))

static CGFloat const footerHeight = 50.0f;

@interface ViewController ()

@property (nonatomic, strong) UIToolbar *statusBarBackground;

@property (nonatomic, strong) UIToolbar *footerToolbar;

/**
 *  Always returns a new and unique flexible space.
 *  Never use the direct pointer of _flexibleSpace
 */
@property (nonatomic, strong) UIBarButtonItem *flexibleSpace;

/**
 *  Button to take action and add a new location
 */
@property (nonatomic, strong) UIBarButtonItem *plusButton;

/**
 *  Button to find an available spot
 */
@property (nonatomic, strong) UIBarButtonItem *findSpotButton;

@end

@implementation ViewController {
	CGSize _lastFrameSize;
	UITextField *_alertControllerTextField;
	MKPointAnnotation *_destinationPointAnnotation;
	NSMutableArray *_spotsNearDestination;
	BOOL _animateEllipses;
	BOOL _didNavigateToUserLocation;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	
	[self.view addSubview:self.mapView];
	[self.view addSubview:self.footerToolbar];
	[self.view addSubview:self.statusBarBackground];
	self.view.backgroundColor = [UIColor appColor];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self performSelector:@selector(checkForFrameChange) withObject:self afterDelay:0.36f];
	});
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (![PRKDataManager locationPermissionHasBeenRequested]) {
		[self alertUserToLocationServiceRequest];
	}
}

- (void)checkForFrameChange {
	if (_lastFrameSize.width != self.view.bounds.size.width || _lastFrameSize.height != self.view.bounds.size.height) {
		[self updateViewConstraints];
	}
	
	_lastFrameSize = self.view.bounds.size;
	[self performSelector:@selector(checkForFrameChange) withObject:self afterDelay:0.25f];
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
	
	self.statusBarBackground.frame = [self statusBarBackgroundFrame];
	self.footerToolbar.frame = [self footerToolbarFrame];
	self.mapView.frame = [self mapViewFrame];
}





#pragma mark - Alerts


- (void)alertUserToLocationServiceRequest {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Parkable would like to use your location"
																			 message:@"Your location will be used"
																	  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes"
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction *action) {
														 [PRKDataManager requestedLocationPermission];
														 [[PRKDataManager locationManager] requestWhenInUseAuthorization];
													 }];
	[alertController addAction:okAction];
	
	UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Later"
													   style:UIAlertActionStyleDestructive
													 handler:^(UIAlertAction *action) {
														 NSLog(@"The user will not grand permission");
													 }];
	[alertController addAction:noAction];
	
	[self presentViewController:alertController
					   animated:YES
					 completion:^{
						 
					 }];
}



#pragma mark - Subviews

- (UIToolbar *)statusBarBackground {
	if (!_statusBarBackground) {
		_statusBarBackground = [[UIToolbar alloc] initWithFrame:[self statusBarBackgroundFrame]];
		_statusBarBackground.tintColor = [UIColor appColor];
	}
	
	return _statusBarBackground;
}

- (CGRect)statusBarBackgroundFrame {
	CGRect frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, kStatusBarHeight);
	
	return frame;
}

- (UIToolbar *)footerToolbar {
	if (!_footerToolbar) {
		_footerToolbar = [[UIToolbar alloc] initWithFrame:[self footerToolbarFrame]];
		_footerToolbar.tintColor = [UIColor appColor];
		[_footerToolbar setItems:@[self.plusButton, self.flexibleSpace, self.findSpotButton]];
	}
	
	return _footerToolbar;
}

- (CGRect)footerToolbarFrame {
	CGRect frame = CGRectMake(0.0f, self.view.frame.size.height - footerHeight, self.view.frame.size.width, footerHeight);
	
	return frame;
}

- (UIBarButtonItem *)flexibleSpace {
	return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
}

- (UIBarButtonItem *)plusButton {
	if (!_plusButton) {
		_plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(plusButtonTouched:)];
	}
	
	return _plusButton;
}

- (UIBarButtonItem *)findSpotButton {
	if (!_findSpotButton) {
		_findSpotButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(findSpotButtonTouched:)];
	}
	
	return _findSpotButton;
}

- (MKMapView *)mapView {
	if (!_mapView) {
		_mapView = [[MKMapView alloc] initWithFrame:[self mapViewFrame]];
		_mapView.showsUserLocation = YES;
		_mapView.showsCompass = YES;
		_mapView.showsPointsOfInterest = YES;
		_mapView.mapType = MKMapTypeStandard;
		_mapView.delegate = self;
		
		[PRKDataManager locationManager].delegate = self;
		
		if ([PRKDataManager locationPermissionHasBeenRequested]) {
			MKCoordinateRegion region = [PRKDataManager lastLocation];
			if (region.center.latitude == 0 || region.center.longitude == 0) {
				
			} else {
				[_mapView setRegion:region];
			}
		}
	}
	
	return _mapView;
}

- (CGRect)mapViewFrame {
	CGRect frame = self.view.bounds;
	
	return frame;
}





#pragma mark - Button Actions

- (void)plusButtonTouched:(UIBarButtonItem *)plusButton {
	NSString *title = @"Submit spot from current location?";
	NSString *message = @"This interface needs to be designed";
	UIAlertController *submitController = [UIAlertController alertControllerWithTitle:title
																			  message:message
																	   preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
														   style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction *action) {
															 
														 }];
	[submitController addAction:cancelAction];
	
	UIAlertAction *submitNewSpotAction = [UIAlertAction actionWithTitle:@"Submit"
																  style:UIAlertActionStyleDefault
																handler:^(UIAlertAction * _Nonnull action) {
																	NSLog(@"This is where the proper action should be called to submit a new handicap parking spot.");
																}];
	[submitController addAction:submitNewSpotAction];
	
	[self presentViewController:submitController
					   animated:YES
					 completion:^{
						 
					 }];
}

- (void)findSpotButtonTouched:(UIBarButtonItem *)findSpotButton {
	UIAlertController *addressController = [UIAlertController alertControllerWithTitle:@"Where would you like to go?"
																			   message:@"Enter the address where you would like to park near"
																		preferredStyle:UIAlertControllerStyleAlert];
	[addressController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		_alertControllerTextField = textField;
		textField.placeholder = @"Address";
		textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		textField.autocorrectionType = UITextAutocorrectionTypeNo;
		textField.returnKeyType = UIReturnKeySearch;
		textField.delegate = self;
	}];
	
	UIAlertAction *searchAction = [UIAlertAction actionWithTitle:@"Search"
														   style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction *action) {
															 NSLog(@"Search for location: %@", _alertControllerTextField.text);
															 [PRKDataManager findLocationCoordinatesForString:_alertControllerTextField.text];
															 [self.mapView removeAnnotations:self.mapView.annotations];
															 [self checkForDestinationUpdate];
														 }];
	[addressController addAction:searchAction];
	
	UIAlertAction *userLocationAction = [UIAlertAction actionWithTitle:@"Use Current Location"
																 style:UIAlertActionStyleDefault
															   handler:^(UIAlertAction * _Nonnull action) {
																   [PRKDataManager useCurrentLocationCoordinate];
																   [self.mapView removeAnnotations:self.mapView.annotations];
																   [self checkForDestinationUpdate];
															   }];
	[addressController addAction:userLocationAction];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
														   style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction *action) {
															 
														 }];
	[addressController addAction:cancelAction];
	
	
	[self presentViewController:addressController
					   animated:YES
					 completion:^{
						 
					 }];
}



#pragma mark - Add Annotations

- (void)checkForDestinationUpdate {
	if ([PRKDataManager destinationPlaceMark]) {
		// Create an editable PointAnnotation, using placemark's coordinates, and set your own title/subtitle
		_destinationPointAnnotation = [[MKPointAnnotation alloc] init];
		CLPlacemark *destinationPlaceMark = [PRKDataManager destinationPlaceMark];
		_destinationPointAnnotation.coordinate = destinationPlaceMark.location.coordinate;
		_destinationPointAnnotation.title = [PRKDataManager destinationName];
		_destinationPointAnnotation.subtitle = @"Searching for spots near here   ";
		
		// Zoom in to the correct location
		MKCoordinateRegion region = self.mapView.region;
		region.center = [PRKDataManager destinationPlaceMark].region.center;
		region.span.longitudeDelta /= 3600.0;
		region.span.latitudeDelta /= 3600.0;
		
		// Add point to the mapView
		[self.mapView setRegion:region
					   animated:YES];
		[self.mapView addAnnotation:_destinationPointAnnotation];
		
		// Select the PointAnnotation programatically
		[self.mapView selectAnnotation:_destinationPointAnnotation
							  animated:NO];
		
		[self performSelector:@selector(checkForSpots)
				   withObject:self
				   afterDelay:0.25f];
		_animateEllipses = YES;
		[self performSelector:@selector(animatePoint:)
				   withObject:@(0)
				   afterDelay:0.25f];
	} else {
		[self performSelector:@selector(checkForDestinationUpdate)
				   withObject:self
				   afterDelay:0.25f];
	}
}

- (void)checkForSpots {
	if ([PRKDataManager spotsNearDestination].count > 0) {
		_animateEllipses = NO;
		
		if (_spotsNearDestination) {
			for (MKPointAnnotation *pointAnnotation in _spotsNearDestination) {
				[self.mapView removeAnnotation:pointAnnotation];
			}
			
			[_spotsNearDestination removeAllObjects];
		} else {
			_spotsNearDestination = [[NSMutableArray alloc] init];
		}
		
		NSArray *spots = [PRKDataManager spotsNearDestination];
		NSInteger totalNumberOfSpots = 0;
		for (PRKSpot *spot in spots) {
			MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
			point.coordinate = spot.coordinate;
			point.title = spot.title;
			point.subtitle = [NSString stringWithFormat:@"%zd Spot%@", spot.numberOfSpots, spot.numberOfSpots == 1 ? @"" : @"s"];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.mapView addAnnotation:point];
			});
			[_spotsNearDestination addObject:point];
			totalNumberOfSpots += spot.numberOfSpots;
		}
		
		[self.mapView setRegion:[self regionFromLocations]
					   animated:YES];
		
		_destinationPointAnnotation.subtitle = [NSString stringWithFormat:@"%zd spot%@ near here", totalNumberOfSpots, totalNumberOfSpots == 1 ? @"" : @"s"];
	} else {
		[self performSelector:@selector(checkForSpots)
				   withObject:self
				   afterDelay:0.25f];
	}
}

- (MKCoordinateRegion)regionFromLocations {
	CLLocationCoordinate2D upper = [PRKDataManager destinationPlaceMark].location.coordinate;
	CLLocationCoordinate2D lower = [PRKDataManager destinationPlaceMark].location.coordinate;
	
	NSMutableArray *spots = [[NSMutableArray alloc] initWithArray:[PRKDataManager spotsNearDestination]];
	[spots addObject:[PRKSpot spotWithCoordinate:_destinationPointAnnotation.coordinate]];
	for (PRKSpot *spot in spots) {
		if(spot.coordinate.latitude > upper.latitude) upper.latitude = spot.coordinate.latitude;
		if(spot.coordinate.latitude < lower.latitude) lower.latitude = spot.coordinate.latitude;
		if(spot.coordinate.longitude > upper.longitude) upper.longitude = spot.coordinate.longitude;
		if(spot.coordinate.longitude < lower.longitude) lower.longitude = spot.coordinate.longitude;
	}
	
	MKCoordinateSpan locationSpan;
	locationSpan.latitudeDelta = upper.latitude - lower.latitude;
	locationSpan.longitudeDelta = upper.longitude - lower.longitude;
	locationSpan.latitudeDelta *= 1.3f;
	locationSpan.longitudeDelta *= 1.3f;
	CLLocationCoordinate2D locationCenter;
	locationCenter.latitude = (upper.latitude + lower.latitude) / 2;
	locationCenter.longitude = (upper.longitude + lower.longitude) / 2;
	
	MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
	return region;
}

- (void)animatePoint:(NSNumber *)ellipses {
	if (!_animateEllipses) {
		return;
	}
	
	int numberOfDots = [ellipses intValue];
	switch (numberOfDots) {
		case 0:
			_destinationPointAnnotation.subtitle = @"Searching for spots near here.  ";
			break;
			
		case 1:
			_destinationPointAnnotation.subtitle = @"Searching for spots near here.. ";
			break;
			
		case 2:
			_destinationPointAnnotation.subtitle = @"Searching for spots near here...";
			break;
			
		default:
			break;
	}
	
	numberOfDots++;
	numberOfDots %= 3;
	
	[self performSelector:@selector(animatePoint:) withObject:@(numberOfDots) afterDelay:0.25f];
}








#pragma mark - Map View Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation isEqual:_destinationPointAnnotation]) {
		return nil;
	}
	
	if (annotation == mapView.userLocation) {
		return nil;
	}
	
	static NSString *identifier = @"SpotsIdentifier";
	MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if(!annotationView) {
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)annotationView;
		pinAnnotationView.pinColor = MKPinAnnotationColorPurple;
	} else {
		annotationView.annotation = annotation;
	}
	
	annotationView.enabled = YES;
	annotationView.canShowCallout = YES;
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	NSString *title = view.annotation.title;
	NSString *message = @"Get driving directions to this spot?";
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
																			 message:message
																	  preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
														   style:UIAlertActionStyleCancel
														 handler:^(UIAlertAction * _Nonnull action) {
															 
														 }];
	[alertController addAction:cancelAction];
	
	NSString *appleMapsTitle = @"Maps";
	
	if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps://"]]) {
		UIAlertAction *googleMapsAction = [UIAlertAction actionWithTitle:@"Google Maps"
																   style:UIAlertActionStyleDefault
																 handler:^(UIAlertAction *action) {
																	 NSString *googleMapsURLString = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=driving",
																									  self.mapView.userLocation.coordinate.latitude,
																									  self.mapView.userLocation.coordinate.longitude,
																									  view.annotation.coordinate.latitude,
																									  view.annotation.coordinate.longitude];
																	 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
																 }];
		[alertController addAction:googleMapsAction];
		
		appleMapsTitle = @"Apple Maps";
	}
	
	UIAlertAction *appleMapsAction = [UIAlertAction actionWithTitle:appleMapsTitle
															  style:UIAlertActionStyleDefault
															handler:^(UIAlertAction *action) {
																MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
																NSDictionary *addressDict = @{(NSString *)kABPersonAddressStreetKey : title};
																MKPlacemark *destinationPlaceMark = [[MKPlacemark alloc] initWithCoordinate:view.annotation.coordinate addressDictionary:addressDict];
																MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlaceMark];
																
																NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
																[MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
																			   launchOptions:launchOptions];
															}];
	[alertController addAction:appleMapsAction];
	
	[self presentViewController:alertController
					   animated:YES
					 completion:^{
						 
					 }];
}













#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
	if (!_didNavigateToUserLocation) {
		CLLocation *currentLocation = [locations firstObject];
		_didNavigateToUserLocation = YES;
		
		self.mapView.region = MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f));
	}
}











#pragma mark - Text FIELD Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField isEqual:_alertControllerTextField]) {
		NSLog(@"Search for location: %@", textField.text);
	} else {
		NSLog(@"I do not recognize this textfield. The text in the textfield is:\n\"%@\"\n", textField.text);
	}
	
	return YES;
}









#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"Memory Warning");
}

@end
