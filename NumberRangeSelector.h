//
//  DLEnterWeightView.h
//  Weightely
//
//  Created by Marcel Ruegenberg on 28.10.13.
//  Copyright (c) 2013 Dustlab. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A view for selecting from a numeric range.
 */
@interface NumberRangeSelector : UIView <UIScrollViewDelegate>

@property (nonatomic) CGFloat currentPosition;
- (void)setCurrentPosition:(CGFloat)currentPosition animated:(BOOL)animated;

/// size in horizontal pixels of a sub step. for each full step, 10 substeps are shown
@property (nonatomic) CGFloat fullStepSize;

/// minimum value on the scale
@property (nonatomic) NSInteger stepsStart;

/// maximum value on the scale. should be larger than `stepsStart`.
@property (nonatomic) NSInteger stepsEnd;

/// how large is each step? (i.e the user can select every n-th value between `stepsStart` and `stepsEnd`.)
@property (nonatomic) NSUInteger stepSize;

@end
