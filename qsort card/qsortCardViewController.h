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

@property (nonatomic,strong) iCarousel *unsortedCardsView;
@property (nonatomic,strong) NSMutableArray *unsortedCardsData;
@property (nonatomic,strong) NSMutableArray *scoreBoxsData;
@property (nonatomic,strong) NSMutableArray *scoreBoxsView;//totally three iCarousel views
@property (nonatomic,strong) NSMutableArray *allCards;

@end
