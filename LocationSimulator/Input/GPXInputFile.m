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
#import "GPXInputFile.h"
#import "GDataXMLNode.h"
#import "RouteInputFile+Private.h"

@implementation GPXInputFile

- (void)read {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSData *data = [[NSData alloc] initWithContentsOfURL:self.fileURL];
    NSLog(@"Read data length:%d", [data length]);

    NSError *err = nil;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:&err];
    if (doc == nil) {
      NSLog(@"Could not create document from response data:%@", err);
    } else {
      NSArray *points = [self loadTrackPointsFromDocument:doc];
      [self setTrackPoints:points];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      [self readComplete];
    });
  });
}

- (NSArray *)loadTrackPointsFromDocument:(GDataXMLDocument *)document {
  NSError *err = nil;
  NSArray *nodes = [[document rootElement] nodesForXPath:@"//_def_ns:gpx/_def_ns:trk/_def_ns:trkseg/_def_ns:trkpt" error:&err];
  NSLog(@"Found %d points", [nodes count]);

  NSMutableArray *result = [NSMutableArray arrayWithCapacity:[nodes count]];
  for (GDataXMLElement *node in nodes) {
    double lat = [[[node attributeForName:@"lat"] stringValue] doubleValue];
    double lon = [[[node attributeForName:@"lon"] stringValue] doubleValue];

    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    [result addObject:location];
  }

  return [NSArray arrayWithArray:result];
}

@end
