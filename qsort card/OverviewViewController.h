//
//  OverviewViewController.h
//  qsort card
//
//  Created by Chia Lin on 13/5/16.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverviewViewController : UIViewController
-(void)setUpDatas:(NSArray*)cardDatas;
-(void)setScrollViewOffset:(CGPoint)offset;

@property (nonatomic,strong) NSMutableArray *cardsViews;
@property (nonatomic,strong) NSMutableArray *cardsDatas;
@property (nonatomic,strong) NSMutableArray *labelViews;
@property (nonatomic) int stage;
@end
