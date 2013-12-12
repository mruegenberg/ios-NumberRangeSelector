//
//  DLEnterWeightView.m
//  Weightely
//
//  Created by Marcel Ruegenberg on 28.10.13.
//  Copyright (c) 2013 Dustlab. All rights reserved.
//

#import "NumberRangeSelector.h"
#import <UIColor+HelperAdditions.h>
#import <NSObject+ObserveActions.h>
#import "DLSeamlessTiledLayer.h"

@interface TriangleView : UIView
@property (strong) UIColor *color;
@end

@implementation TriangleView

- (id)init {
    if((self = [super init])) {
        self.contentMode = UIViewContentModeRedraw;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height);
    CGContextAddLineToPoint(c,
                            self.bounds.origin.x + self.bounds.size.width,
                            self.bounds.origin.y + self.bounds.size.height);
    CGContextAddLineToPoint(c,
                            self.bounds.origin.x + self.bounds.size.width / 2,
                            self.bounds.origin.y);
    [self.color setFill];
    CGContextFillPath(c);
}

@end



@interface DLEnterWeightScaleView : UIView

@property CGFloat fullStepSize; // size of a sub step. for each full step, 10 substeps are shown
@property NSInteger stepsStart;
@property NSInteger stepsEnd;
@property NSInteger stepSize;
@property (nonatomic, readonly) CGFloat subStepSize;
@property (nonatomic) CGFloat highlightPos;

// compute the position of the line correspondng to `pos`,
// where `pos` is a number from 0 to `[fullStepLabels count]`. Partial steps are allowed.
- (CGFloat)offsetForPosition:(CGFloat)pos;

- (CGFloat)positionForOffset:(CGFloat)offset;

@end


@implementation DLEnterWeightScaleView

- (id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        __block typeof(self) bself = self;
        [self addObserverAction:^{
            [bself setNeedsDisplay];
        } forKeyPath:@"highlightPos" context:self];
        
        ((CATiledLayer *)self.layer).tileSize = CGSizeMake(320, 320);
    }
    return self;
}

- (void)dealloc {
    [self removeActionObserverForKeyPath:@"highlightPos" context:self];
}

- (CGFloat)subStepSize {
    return self.fullStepSize / 10;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGContextSetLineWidth(c, 1 / self.contentScaleFactor);
    CGFloat stepSize = self.subStepSize;
    CGFloat xStart = 0;
    NSUInteger cnt = ((self.stepsEnd - self.stepsStart) / self.stepSize + 2) * 10;
    
    CGFloat hightlightOffset = [self offsetForPosition:self.highlightPos];
    UIColor *highlightColor = [self.tintColor colorMultipliedByScalar:1.5 withMinimum:0.3];
    {
        {
            CGFloat h,s,b,a;
            if(CGColorGetNumberOfComponents([highlightColor CGColor]) < 3)
                [highlightColor getWhite:&b alpha:&a];
            else
                [highlightColor getHue:&h saturation:&s brightness:&b alpha:&a];
            if(b < 0.35) {
                highlightColor = [UIColor whiteColor];
            }
        }
    }
    if(highlightColor == nil) highlightColor = [UIColor whiteColor];
    for(NSUInteger i = 0; i < cnt; ++i) {
        CGFloat pos = xStart + i * stepSize;
        if(pos < rect.origin.x)
            ;
        else {
            if(pos > rect.origin.x + rect.size.width)
                break;
            if(pos == hightlightOffset) {
                [highlightColor set];
            }
            CGContextMoveToPoint(c, pos, 0);
            CGContextAddLineToPoint(c, pos, 20);
            CGContextStrokePath(c);
        }
        [[UIColor whiteColor] set];
    }
    
    xStart = self.fullStepSize + self.fullStepSize / 2;
    
    CGContextSetLineWidth(c, 2 / self.contentScaleFactor);
    NSDictionary *stepLabelAttrs = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:24],
                                     NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSDictionary *highlightedLabelAttrs = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:24],
                                            NSForegroundColorAttributeName:highlightColor};
    NSAssert(self.stepsStart <= self.stepsEnd, @"Negative number of steps!"); // exchange the two?
    for(NSInteger i = self.stepsStart; i < self.stepsEnd; i += self.stepSize) {
        NSString *stepLabel = [NSString stringWithFormat:@"%d", i];
        CGSize s = [stepLabel sizeWithAttributes:stepLabelAttrs];
        if(xStart + s.width < rect.origin.x) {
            ;
        }
        else {
            if(xStart - s.width / 2 > rect.origin.x + rect.size.width)
                break;
            if(xStart == hightlightOffset) {
                [highlightColor set];
            }
            CGContextMoveToPoint(c, xStart, 0);
            CGContextAddLineToPoint(c, xStart, 30);
            CGContextStrokePath(c);
            
            if(xStart == hightlightOffset) {
                [stepLabel drawInRect:CGRectMake(xStart - s.width / 2, self.bounds.size.height - 40, s.width, 30) withAttributes:highlightedLabelAttrs];
            }
            else {
                [stepLabel drawInRect:CGRectMake(xStart - s.width / 2, self.bounds.size.height - 40, s.width, 30) withAttributes:stepLabelAttrs];
            }
        }
        
        xStart += self.fullStepSize;
        
        [[UIColor whiteColor] set];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.fullStepSize * ((self.stepsEnd - self.stepsStart) / self.stepSize + 2), 70);
}

- (CGFloat)offsetForPosition:(CGFloat)pos {
    CGFloat xStart = self.fullStepSize + self.fullStepSize / 2;
    return xStart + floorf((pos * self.fullStepSize) / self.subStepSize) * self.subStepSize;
}

- (CGFloat)positionForOffset:(CGFloat)offset {
    CGFloat xStart = self.fullStepSize + self.fullStepSize / 2;
    offset -= xStart;
    return floorf((offset / self.fullStepSize) * self.subStepSize) / self.subStepSize;
}

+ (Class)layerClass {
    return [DLSeamlessTiledLayer class];
}

@end



@interface NumberRangeSelector ()

@property (strong) DLEnterWeightScaleView *scaleView;
@property (strong) UIScrollView *scrollView;
@property (strong) TriangleView *triView;

@end



@implementation NumberRangeSelector

- (id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])) {
        self.scaleView = [[DLEnterWeightScaleView alloc] initWithFrame:CGRectZero];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        self.scrollView.delegate = self;
        self.scrollView.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:self.scaleView];
        [self addSubview:self.scrollView];
        
        self.triView = [[TriangleView alloc] init];
        [self addSubview:self.triView];
    }
    return self;
}

- (void)setStepsStart:(NSInteger)stepsStart { self.scaleView.stepsStart = stepsStart; }
- (void)setStepsEnd:(NSInteger)stepsEnd     { self.scaleView.stepsEnd = stepsEnd; }
- (void)setStepSize:(NSUInteger)stepSize    { self.scaleView.stepSize = stepSize; }
- (void)setFullStepSize:(CGFloat)fullStepSize { self.scaleView.fullStepSize = fullStepSize; [self.scaleView sizeToFit]; }
- (NSInteger)stepsStart { return self.scaleView.stepsStart; }
- (NSInteger)stepsEnd   { return self.scaleView.stepsEnd; }
- (NSUInteger)stepSize  { return self.scaleView.stepSize; }
- (CGFloat)fullStepSize { return self.scaleView.fullStepSize; }

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.scaleView sizeToFit];
    self.scrollView.contentSize = self.scaleView.frame.size;
    self.scrollView.frame = self.bounds;
    self.triView.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width / 2 - 10,
                                    self.scaleView.frame.origin.y + self.scaleView.frame.size.height - 10,
                                    20, 10);
    self.triView.color = [UIColor whiteColor]; // [UIColor colorWithWhite:0.97 alpha:1.0]; // FIXME: hack!
}

- (void)tintColorDidChange {
//    self.backgroundColor = self.tintColor;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self willChangeValueForKey:@"currentPosition"];
    CGFloat currentOffset = targetContentOffset->x + self.scrollView.frame.size.width / 2;
    CGFloat pos = [self.scaleView positionForOffset:currentOffset];
    CGFloat newOffset = [self.scaleView offsetForPosition:pos] - self.scrollView.frame.size.width / 2;
    *targetContentOffset = CGPointMake(newOffset, targetContentOffset->y);
    self.scaleView.highlightPos = pos;
    [self didChangeValueForKey:@"currentPosition"];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self willChangeValueForKey:@"currentPosition"];
    [self didChangeValueForKey:@"currentPosition"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self willChangeValueForKey:@"currentPosition"];
    CGFloat currentOffset = scrollView.contentOffset.x + self.scrollView.frame.size.width / 2;
    CGFloat pos = [self.scaleView positionForOffset:currentOffset];
    self.scaleView.highlightPos = pos;
    [self didChangeValueForKey:@"currentPosition"];
}

- (CGFloat)currentPosition {
    CGFloat currentOffset = self.scrollView.contentOffset.x + self.scrollView.frame.size.width / 2;
    CGFloat pos = [self.scaleView positionForOffset:currentOffset];
    return self.scaleView.stepsStart + pos * self.scaleView.stepSize;
}

- (void)setCurrentPosition:(CGFloat)currentPosition {
    [self setCurrentPosition:currentPosition animated:NO];
}

- (void)setCurrentPosition:(CGFloat)currentPosition animated:(BOOL)animated {
    [self willChangeValueForKey:@"currentPosition"];
    CGFloat pos = (currentPosition - self.scaleView.stepsStart) / self.scaleView.stepSize;
    CGFloat newOffset = [self.scaleView offsetForPosition:pos] - self.scrollView.frame.size.width / 2;
    [self.scrollView setContentOffset:CGPointMake(newOffset, self.scrollView.contentOffset.y) animated:animated];
    self.scaleView.highlightPos = pos;
    [self didChangeValueForKey:@"currentPosition"];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(300, 100);
}

@end
