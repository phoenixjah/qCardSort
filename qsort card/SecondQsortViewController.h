//
//  SecondQsortViewController.h
//  qsort card
//
//  Created by Chia Lin on 13/5/6.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "qsortCardViewController.h"
@class iCarousel;

@interface SecondQsortViewController :UIViewController
-(void)setUpDatas:(NSArray*)cardDatas label:(NSArray*)labelDatas;

@property (nonatomic,strong) NSMutableArray *cardsViews;
@property (nonatomic,strong) NSMutableArray *cardsDatas;
@property (nonatomic,strong) NSArray *labelViews;
@property (nonatomic,strong) NSArray *labelDatas;
@end
