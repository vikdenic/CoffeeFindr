//
//  DetailViewController.h
//  CoffeeFind
//
//  Created by Johnny Appleseed on 11/12/14.
//  Copyright (c) 2014 MobileMakers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoffeePlace.h"

@interface DetailViewController : UIViewController

@property CoffeePlace *coffeePlace;
@property CLLocation *currentLocation;

@end
