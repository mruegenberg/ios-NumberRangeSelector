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

@end
