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
	}
	
	return _mapView;
}

- (CGRect)mapViewFrame {
	CGRect frame = self.view.bounds;
	
	return frame;
}





#pragma mark - Button Actions

- (void)plusButtonTouched:(UIBarButtonItem *)plusButton {
	NSLog(@"Plus Button Touched");
}

- (void)findSpotButtonTouched:(UIBarButtonItem *)findSpotButton {
	NSLog(@"Find Spot Button Touched");
	
	UIAlertController *addressController = [UIAlertController alertControllerWithTitle:@"Where would you like to go?"
																			   message:@"Please enter the address where you would like to park near"
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
			[self.mapView addAnnotation:point];
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
	locationSpan.latitudeDelta *= 1.1f;
	locationSpan.longitudeDelta *= 1.1f;
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
