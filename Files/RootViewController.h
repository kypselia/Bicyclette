//
//  RootViewController.h
//  Bicyclette
//
//  Created by Nicolas on 02/04/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
@interface RootViewController : UITableViewController {
	NSArray *				arrdtArray;
	NSMutableDictionary *	stationsDictionary;
	NSMutableSet *			currentRequests;
	NSMutableArray *		favoritesArray;
	BOOL					shouldCancel;
	
	UIBarButtonItem *		favoritesButton;
	BOOL					onlyShowFavorites;
	
	UISegmentedControl *				titleToggle;
	
	CLLocationManager *		locationManager;
}

- (IBAction) sendRequests;

- (IBAction) toggleFavorites;
@property (nonatomic,retain) IBOutlet UIBarButtonItem * favoritesButton;

- (IBAction) toggleWanted;
@property (nonatomic,retain) IBOutlet UISegmentedControl * titleToggle;

@end