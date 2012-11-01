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

#import <CoreLocation/CoreLocation.h>
#import "RouteInputFile.h"
#import "RouteInputFile+Private.h"

@interface RouteInputFile ()

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign) NSUInteger scanLocation;

@end

@implementation RouteInputFile {
  NSArray *_trackPoints;
}

- (id)initWithURL:(NSURL *)fileURL {
  self = [super init];

  if (self) {
    [self setFileURL:fileURL];
  }

  return self;
}

- (BOOL)hasBeenRead {
  return [_trackPoints count] > 0;
}

- (void)read {

}

- (void)setTrackPoints:(NSArray *)trackPoints {
  _trackPoints = trackPoints;
}

- (NSArray *)trackPoints {
  return _trackPoints;
}

- (void)readComplete {
  if (self.completionBlock) {
    self.completionBlock();
  }
}

- (CLLocation *)nextLocation {
  CLLocation *location = [self.trackPoints objectAtIndex:self.scanLocation];
  [self setScanLocation:self.scanLocation + 1];
  if (self.scanLocation >= [self.trackPoints count]) {
    [self setScanLocation:0];
  }

  return location;
}

@end
