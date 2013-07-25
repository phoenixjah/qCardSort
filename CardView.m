//
//  Card.m
//  qsort card
//
//  Created by Chia Lin on 13/4/23.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import "CardView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // Add gesture recognizer
        UIImageView *background = [[UIImageView alloc] initWithFrame:frame];
        background.contentMode = UIViewContentModeScaleAspectFit;
        background.image = [UIImage imageNamed:@"card.png"];
        [self addSubview:background];
        background = nil;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
        //[panGesture setDelegate:self];
        [panGesture setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panGesture];
        
        [self addSubview:self.imageView];
    }
    return self;
}

-(UIImageView*)imageView{
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, self.frame.size.width-10, self.frame.size.height-25)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}
#pragma mark - Touch handling

//adjust anchor point also bring view to front
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
        
        [[piece superview] bringSubviewToFront:piece];
    }
}

- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    //[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
        //piece.transform = CGAffineTransformMakeScale((piece.center.y-200)/1024, (piece.center.y-200)/1024);
        [self.delegate isMoving:self];
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self.delegate cardMovingEnd:self];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{    
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    return YES;
}

#pragma mark - Scale Function

-(void)scaleTo:(CGFloat)size{
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self setTransform:CGAffineTransformMakeScale(size, size)];
                     }
     ];

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
