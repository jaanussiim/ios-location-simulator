/*
 * Copyright 2012 JaanusSiim
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <MapKit/MapKit.h>
#import "JSLocationManager.h"
#import "RouteInputFile.h"
#import "JSLocation.h"

@interface JSLocationManager ()

@property (nonatomic, assign) BOOL sendLocationUpdates;
@property (nonatomic, assign) BOOL locationFeederRunning;
@property (nonatomic, strong) CLLocation *latestLocation;

@end

@implementation JSLocationManager

- (MKAnnotationView *)fakeUserLocationView {
  if (!self.mapView) {
    return nil;
  }

  [self.mapView.userLocation setCoordinate:self.location.coordinate];
  MKAnnotationView *userLocationView = [[MKAnnotationView alloc] initWithAnnotation:self.mapView.userLocation reuseIdentifier:nil];
  [userLocationView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TrackingDot.png"]]];
  userLocationView.centerOffset = CGPointMake(-10, -10);
  return userLocationView;
}

- (void)startUpdatingLocation {
  __block __weak JSLocationManager *weakSelf = self;
  [self setSendLocationUpdates:YES];
  if (![self.input hasBeenRead]) {
    [self.input setCompletionBlock:^{
      [weakSelf runLocationFeeder];
    }];
    [self.input read];
  } else {
    [self runLocationFeeder];
  }
}

- (void)runLocationFeeder {
  if (self.locationFeederRunning) {
    return;
  }

  [self pushNextLocation];
  [self setLocationFeederRunning:YES];
}

- (void)pushNextLocation {
  JSLocation *location = [self.input nextLocation];
  [self setLatestLocation:location];

  if (self.mapView) {
    MKAnnotationView *userLocationView = [self.mapView viewForAnnotation:self.mapView.userLocation];
    [userLocationView.superview sendSubviewToBack:userLocationView];

    CGRect frame = userLocationView.frame;
    frame.origin = [self.mapView convertCoordinate:self.latestLocation.coordinate toPointToView:userLocationView.superview];
    frame.origin.x -= 10;
    frame.origin.y -= 10;
    [UIView animateWithDuration:location.secondsForMove animations:^{
      userLocationView.frame = frame;
    }];

    [self.mapView.userLocation setCoordinate:self.latestLocation.coordinate];
  }

  if (self.sendLocationUpdates && [self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
    [self.delegate locationManager:self didUpdateLocations:[NSArray arrayWithObject:location]];
  }

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, location.secondsForMove * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self pushNextLocation];
  });
}

@end
