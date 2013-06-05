//
//  ShowProgressImageView.m
//  qsort card
//
//  Created by Chia Lin on 13/6/5.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import "ShowProgressImageView.h"

@interface ShowProgressImageView()
@property (nonatomic,strong) UILabel *leftLabel;
@end

@implementation ShowProgressImageView

-(id)initWithImage:(UIImage *)image{
    self = [super initWithImage:image];
    if (self) {
        self.leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 100, 20)];
        [self addSubview:self.leftLabel];
        
        self.center = CGPointMake(500,768);
    }
    return self;
}

#pragma mark - class function
-(void)setLabel:(NSString*)content{
    self.leftLabel.text = content;
}

-(void)setPositionX:(CGFloat)x{
    
    self.center = CGPointMake(20 + x, self.center.y);
}

-(void)action{
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self performSelector:@selector(goBackAnimation:)
                                    withObject:nil
                                    afterDelay:0.5
                          ];
                    }
     ];
}

-(void)goBackAnimation:(id)sender{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
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
