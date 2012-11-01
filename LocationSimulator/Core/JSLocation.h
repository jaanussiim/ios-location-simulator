//
//  JSLocation.h
//  SpeedCamera
//
//  Created by Jaanus Siim on 11/1/12.
//  Copyright (c) 2012 InGenius Labs. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface JSLocation : CLLocation

@property (nonatomic, assign) NSTimeInterval secondsForMove;

@end
