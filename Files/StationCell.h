//
//  StationCell.h
//  Bicyclette
//
//  Created by Nicolas on 10/10/10.
//  Copyright 2010 Nicolas Bouilleaud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Station;
@interface StationCell : UITableViewCell 

@property (nonatomic, assign) IBOutlet UILabel * nameLabel;
@property (nonatomic, assign) IBOutlet UILabel * addressLabel;
@property (nonatomic, assign) IBOutlet UILabel * availableCountLabel;
@property (nonatomic, assign) IBOutlet UILabel * freeCountLabel;
@property (nonatomic, assign) IBOutlet UILabel * totalCountLabel;
@property (nonatomic, assign) IBOutlet UILabel * refreshDateLabel;

@property (nonatomic, retain) Station * station;

@end