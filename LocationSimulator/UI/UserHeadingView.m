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

#import "UserHeadingView.h"

@implementation UserHeadingView

- (id)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];

  if (self) {
    [self setOpaque:NO];
  }

  return self;
}

static inline double radians (double degrees) {return degrees * M_PI/180;}

- (void)drawRect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();

  CGContextSaveGState(ctx);

  CGContextTranslateCTM(ctx, CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) / 2);
  CGContextRotateCTM (ctx, radians(self.heading));

  CGContextTranslateCTM(ctx, -CGRectGetWidth(rect) / 2, -CGRectGetHeight(rect) / 2);

  CGContextBeginPath(ctx);
  CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.x + rect.size.height / 2);
  CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width / 2, rect.origin.y);
  CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height / 2);
  CGContextClosePath(ctx);

  CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
  CGContextFillPath(ctx);

  CGContextRestoreGState(ctx);
}

@end
