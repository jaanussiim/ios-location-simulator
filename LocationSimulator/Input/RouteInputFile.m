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

#import "RouteInputFile.h"
#import "RouteInputFile+Private.h"

@interface RouteInputFile ()

@property (nonatomic, strong) NSURL *fileURL;

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

- (void)readComplete {
  if (self.completionBlock) {
    self.completionBlock();
  }
}

@end
