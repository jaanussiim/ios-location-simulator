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
#import "UserHeadingView.h"

@interface JSLocationManager ()

@property (nonatomic, assign) BOOL sendLocationUpdates;
@property (nonatomic, assign) BOOL locationFeederRunning;
@property (nonatomic, strong) CLLocation *latestLocation;
@property (nonatomic, strong) NSMutableArray *userMonitoredRegions;
@property (nonatomic, strong) NSMutableArray *userInsideRegions;
@property (nonatomic, strong) UserHeadingView *headingView;

@end

@implementation JSLocationManager

- (id)init {
  self = [super init];

  if (self) {
    [self setUserMonitoredRegions:[NSMutableArray array]];
    [self setUserInsideRegions:[NSMutableArray array]];
  }

  return self;
}

- (MKAnnotationView *)fakeUserLocationView {
  if (!self.mapView) {
    return nil;
  }

  [self.mapView.userLocation setCoordinate:self.location.coordinate];
  MKAnnotationView *userLocationView = [[MKAnnotationView alloc] initWithAnnotation:self.mapView.userLocation reuseIdentifier:nil];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:self.fakeUserLocationImage];
  [userLocationView addSubview:imageView];

  CGSize imageSize = imageView.frame.size;
  CGSize arrowViewSize = CGSizeMake(imageSize.width + 4, imageSize.height + 4);

  UserHeadingView *headingView = [[UserHeadingView alloc] initWithFrame:CGRectMake(-2, -2, arrowViewSize.width, arrowViewSize.height)];
  [userLocationView insertSubview:headingView belowSubview:imageView];
  [self setHeadingView:headingView];
  userLocationView.centerOffset = CGPointMake(-imageSize.width / 2, -imageSize.height / 2);
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

  NSTimeInterval interval = location.secondsForMove / self.replaySpeed;

  if (self.mapView) {
    MKAnnotationView *userLocationView = [self.mapView viewForAnnotation:self.mapView.userLocation];
    [userLocationView.superview sendSubviewToBack:userLocationView];

    [self.headingView setHeading:location.course];
    [self.headingView setNeedsDisplay];

    CGRect frame = userLocationView.frame;
    frame.origin = [self.mapView convertCoordinate:self.latestLocation.coordinate toPointToView:userLocationView.superview];
    frame.origin.x -= 10;
    frame.origin.y -= 10;
    [UIView animateWithDuration:interval animations:^{
      userLocationView.frame = frame;
    }];

    [self.mapView.userLocation setCoordinate:self.latestLocation.coordinate];
  }

  if (self.sendLocationUpdates && [self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
    [self.delegate locationManager:self didUpdateLocations:[NSArray arrayWithObject:location]];
  }

  NSArray *regionsEntered = [self regionsEnteredWithLocation:location];
  [self.userInsideRegions addObjectsFromArray:regionsEntered];

  if ([self.delegate respondsToSelector:@selector(locationManager:didEnterRegion:)]) {
    for (CLRegion *region in regionsEntered) {
      [self.delegate locationManager:self didEnterRegion:region];
    }
  }

  NSArray *regionsExited = [self regionsExitedWithLocation:location];
  [self.userInsideRegions removeObjectsInArray:regionsExited];

  if ([self.delegate respondsToSelector:@selector(locationManager:didExitRegion:)]) {
    for (CLRegion *region in regionsExited) {
      [self.delegate locationManager:self didExitRegion:region];
    }
  }

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self pushNextLocation];
  });
}

- (NSArray *)regionsExitedWithLocation:(JSLocation *)location {
  NSMutableArray *exited = [NSMutableArray array];
  for (CLRegion *region in self.userInsideRegions) {
    if ([region containsCoordinate:location.coordinate]) {
      continue;
    }

    [exited addObject:region];
  }

  return [NSArray arrayWithArray:exited];
}

- (NSArray *)regionsEnteredWithLocation:(JSLocation *)location {
  NSMutableArray *entered = [NSMutableArray array];
  for (CLRegion *region in self.userMonitoredRegions) {
    if (![region containsCoordinate:location.coordinate]) {
      continue;
    }

    if ([self.userInsideRegions containsObject:region]) {
      continue;
    }

    [entered addObject:region];
  }

  return [NSArray arrayWithArray:entered];
}

- (void)stopUpdatingLocation {
  [self setSendLocationUpdates:NO];
}

- (void)startMonitoringForRegion:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy {
  [self startMonitoringForRegion:region];
}

- (void)startMonitoringForRegion:(CLRegion *)region {
  [self.userMonitoredRegions addObject:region];

  if ([region containsCoordinate:self.latestLocation.coordinate]) {
    [self.userInsideRegions addObject:region];
  }

  if ([self.delegate respondsToSelector:@selector(locationManager:didStartMonitoringForRegion:)]) {
    [self.delegate locationManager:self didStartMonitoringForRegion:region];
  }
}

- (void)stopMonitoringForRegion:(CLRegion *)region {
  [self.userMonitoredRegions removeObject:region];
  [self.userInsideRegions removeObject:region];
}

- (NSSet *)monitoredRegions {
  return [NSSet setWithArray:self.userMonitoredRegions];
}

- (CLLocation *)location {
  return self.latestLocation;
}

@end
