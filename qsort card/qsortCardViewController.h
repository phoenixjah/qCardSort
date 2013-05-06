//
//  qsortCardViewController.h
//  qsort card
//
//  Created by Chia Lin on 13/4/22.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class iCarousel;

@interface qsortCardViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *cardsDatas;
@property (nonatomic,strong) NSMutableArray *cardsViews;
@property (nonatomic,strong) NSMutableArray *allCards;
@property (nonatomic,strong) NSMutableArray *labelViews;
@property (nonatomic,strong) NSArray *labelDatas;

@end
