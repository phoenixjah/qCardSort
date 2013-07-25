//
//  LabelView.m
//  qsort card
//
//  Created by Chia Lin on 13/5/23.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import "LabelView.h"

@implementation LabelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 68, 170)];
//        self.imageView.backgroundColor = [UIColor grayColor];
        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 68, 20)];
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
    }
    return self;
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
