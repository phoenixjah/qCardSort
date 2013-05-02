//
//  Card.h
//  qsort card
//
//  Created by Chia Lin on 13/4/23.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CardView;

@protocol CardIsSorting <NSObject>
-(void)isMoving:(CardView*)card;
-(void)cardMovingEnd:(CardView*)card;
@end

@interface CardView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,weak) id <CardIsSorting> delegate;

-(void)scaleTo:(CGFloat)size;
@end
