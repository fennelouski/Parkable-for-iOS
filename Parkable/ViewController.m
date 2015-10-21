//
//  ViewController.m
//  Parkable
//
//  Created by HAI on 10/21/15.
//  Copyright © 2015 Nathan Fennel. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+AppColors.h"

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
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	
	[self.view addSubview:self.footerToolbar];
	[self.view addSubview:self.statusBarBackground];
	self.view.backgroundColor = [UIColor appColor];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self performSelector:@selector(checkForFrameChange) withObject:self afterDelay:0.36f];
	});
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






#pragma mark - Button Actions

- (void)plusButtonTouched:(UIBarButtonItem *)plusButton {
	NSLog(@"Plus Button Touched");
}

- (void)findSpotButtonTouched:(UIBarButtonItem *)findSpotButton {
	NSLog(@"Find Spot Button Touched");
}


#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
	
	NSLog(@"Memory Warning");
}

@end
