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
//        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 30, frame.size.width, frame.size.height - 20)];
//        self.imageView.backgroundColor = [UIColor grayColor];
//        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, frame.size.width, 20)];
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
