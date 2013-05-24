//
//  SecondQsortViewController.m
//  qsort card
//
//  Created by Chia Lin on 13/5/6.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import "SecondQsortViewController.h"
#import "iCarousel.h"
#import "CardView.h"
#import "OverviewViewController.h"
#import <MessageUI/MessageUI.h>

#define NOT_SORTED 3
@interface SecondQsortViewController ()<CardIsSorting,iCarouselDataSource,iCarouselDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIPageControl *pageControl;
@end

@implementation SecondQsortViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    //TODO:setup pageControl
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 300, 20, 100)];
    [self.view addSubview:self.pageControl];
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 1;
    self.pageControl.backgroundColor = [UIColor blackColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.scrollView.contentSize = CGSizeMake(1024, 768*3);
    self.scrollView.pagingEnabled = YES;
    [self.scrollView setContentOffset:CGPointMake(0, 768)];
    [self.view addSubview:self.scrollView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setupViews];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Datas
-(void)setUpDatas:(NSArray *)cardDatas label:(NSArray *)labelDatas{
    self.labelDatas = [NSArray arrayWithArray:labelDatas];
    self.cardsDatas = [NSMutableArray arrayWithArray:cardDatas];
//        for (int i=0;i<[self.cardsDatas count];i++) {
//            NSMutableArray *data = [self.cardsDatas objectAtIndex:i];
//            for (NSString *path in data) {
//                NSLog(@"carousel %d, cardDataPath = %@",i,path);
//            }
//        }
    for (int i=0; i<9; i++) {
        [self.cardsDatas addObject:[NSMutableArray array]];
    }
 
}

-(void)setupViews{ 
    //first three cardViews are unsorted
    self.cardsViews = [NSMutableArray array];
    for (int i = 0; i<3; i++) {
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(20, 30 + i*768, 400, 600)];
        carousel.type = iCarouselTypeLinear;
        //carousel.backgroundColor = [UIColor cyanColor];
        carousel.tag = i;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.vertical = YES;
        //carousel.backgroundColor = [UIColor blueColor];

        [self.cardsViews addObject:carousel];
    }
    
    for (int i=0; i<9; i++) {
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(600, 30+i*250, 500, 100)];
        carousel.type = iCarouselTypeCoverFlow2;
        carousel.tag = NOT_SORTED + i;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1+0.15*i];
        [self.cardsViews addObject:carousel];

    }
    for (iCarousel *cards in self.cardsViews) {
        [self.scrollView addSubview:cards];
    }
    //TODO: setup labelViews
    [self openAnimation];
}

-(void)openAnimation{
    __block iCarousel *mediumCards = [self.cardsViews objectAtIndex:1];
    [mediumCards scrollByNumberOfItems:[mediumCards numberOfItems]/2 duration:0];
    mediumCards.center = CGPointMake(mediumCards.center.x - 450, mediumCards.center.y);
    //[mediumCards reloadData];
    //move it out
    [UIView animateWithDuration:0.8
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         mediumCards.transform = CGAffineTransformMakeTranslation(650, 0);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.35
                          delay:0.1 options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              mediumCards.transform = CGAffineTransformMakeTranslation(450, 0);
                                          }
                                          completion:^(BOOL finished){
                                              //spread it out
                                              [UIView animateWithDuration:0.5
                                                               animations:^{
                                                                   for (iCarousel *carousel in self.cardsViews) {
                                                                       carousel.type = iCarouselTypeWheel;
                                                                   }
                                                               }
                                               ];
                                              //self.timer = [NSTimer scheduledTimerWithTimeInterval:0.0005 target:self selector:@selector(increaseGhost:) userInfo:nil repeats:YES];
                                              //[self.timer fire];
                                              
                                              mediumCards = nil;
                                          }
                          ];
                     }
     ];
}

#pragma mark - CardIsSorting Delegate Function
-(void)isMoving:(CardView *)card{
    
    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
    int sortedIndex = 0;
    
    [self.scrollView bringSubviewToFront:[self.cardsViews objectAtIndex:card.tag]];
    if (cardPosition.origin.x > 400 && card.tag < NOT_SORTED) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             card.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
                         }
         ];
    }else if(cardPosition.origin.x < 400 && card.tag > NOT_SORTED){
        [UIView animateWithDuration:0.25
                         animations:^{
                             card.transform = CGAffineTransformMakeScale(1.0/0.6, 1.0/0.6);
                         }
         ];
    }else{
        [UIView animateWithDuration:0.25
                         animations:^{
                             card.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }
         ];
    }

//    NSArray *nowOnDisplay = [self.sortedGroup indexesForVisibleItems];
//    for (NSNumber *i in nowOnDisplay) {
//        NSLog(@"visible index = %d",i.integerValue);
//    }
    for (int i = NOT_SORTED;i<[self.cardsViews count];i++) {
        iCarousel *scoreBox = [self.cardsViews objectAtIndex:i];
        CGRect boxPosition = [scoreBox convertRect:scoreBox.bounds toView:self.view];
//        NSLog(@"scorebox position (x,y) = (%f, %f)",boxPosition.origin.x,boxPosition.origin.y);
//        NSLog(@"card position (x,y) = (%f, %f)",card.frame.origin.x,card.frame.origin.y);
//        NSLog(@"converted postition (x,y) = (%f, %f)",cardPosition.origin.x,cardPosition.origin.y);
        
            //if overlap
        //TODO: change the highlight image
            if (CGRectIntersectsRect(boxPosition, cardPosition)) {
                            scoreBox.backgroundColor = [UIColor lightGrayColor];
                sortedIndex = scoreBox.tag;
            }else{
                            scoreBox.backgroundColor = [UIColor whiteColor];
            }
        
    }
}
-(void)cardMovingEnd:(CardView *)card{
    int sortedToGroup = card.tag;
    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
    
    //NSLog(@"card.tag = %d",card.tag);
    //check overlap
    for (UIView *scoreBox in self.cardsViews) {
        CGRect boxPosition = [scoreBox convertRect:scoreBox.bounds toView:self.view];
        if (CGRectIntersectsRect(boxPosition, cardPosition)) {
            //assign to that group
            scoreBox.backgroundColor = [UIColor lightGrayColor];
            sortedToGroup = scoreBox.tag;
            break;
        }
    }
    
    NSInteger cardLeft = 1;
    if (sortedToGroup == card.tag) {
        //put it back to its origin position
        [UIView animateWithDuration:0.3
                         animations:^{
                             card.frame = [card superview].frame;
                         }
         ];
    }else{
        cardLeft = [self moveCard:card fromGroup:card.tag toGroup:sortedToGroup];
        card.tag = sortedToGroup;
    }
    
    //NSLog(@"unsorted cards %d",self.unsortedCards);
    //NSLog(@"the card sorted to group %d",sortedToGroup);
    
    if (cardLeft == 0) {
        //TODO:fuck I finished!!
        [self fuckIFinished];
    }
}

-(NSInteger)moveCard:(CardView*)card fromGroup:(int)from toGroup:(int)to{
    iCarousel *oldGroupView = [self.cardsViews objectAtIndex:from];
    iCarousel *newGroupView = [self.cardsViews objectAtIndex:to];
    
    NSMutableArray *oldDatas = [self.cardsDatas objectAtIndex:from];
    NSMutableArray *newDatas = [self.cardsDatas objectAtIndex:to];
    
    //NSLog(@"%@",[NSString stringWithFormat:@"card %d moves from %d to %d",oldGroupView.currentItemIndex,from,to]);
    //add it to new group
    NSInteger index = MAX(0, newGroupView.currentItemIndex);
    NSString *imagePath = [NSString stringWithFormat:@"%@",[oldDatas objectAtIndex:oldGroupView.currentItemIndex]];
    //    if ([newDatas count]>0) {
    //        index = index-1;
    //    }
    [newDatas insertObject:imagePath atIndex:index];
    [newGroupView insertItemAtIndex:index animated:YES];
    //[newGroupView scrollToItemAtIndex:index animated:YES];
    //NSLog(@"insert new item succefully");
    
    //remove it from old group
    if (oldGroupView.numberOfItems > 0) {
        NSInteger index = oldGroupView.currentItemIndex;
        [oldDatas removeObjectAtIndex:index];
        [oldGroupView removeItemAtIndex:index animated:YES];
        //NSLog(@"remove item succefully");
    }
    //TODO:counts how many cards left unsorted
    if (from < NOT_SORTED) {
        NSInteger lefts = 0;
        for (int i = 0; i<NOT_SORTED; i++) {
            lefts = lefts + [[self.cardsDatas objectAtIndex:i] count];
        }
        return lefts;
    }else{
        return 1;
    }
    
}
#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
        NSMutableArray *carouselDatas;
//        NSLog(@"carousel %d",carousel.tag);
//        for (NSString *path in carouselDatas) {
//            NSLog(@"data %@",path);
//        }
        carouselDatas = [self.cardsDatas objectAtIndex:carousel.tag];
        return [carouselDatas count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    //TODO: handle the nested iCarousel View
    UILabel *label = nil;
    CardView *card = nil;
    

    //NSLog(@"carousel number %d",carousel.tag);
    //create new view if no view is available for recycling
    //    if (view == nil)
    //    {
    if (carousel.type == iCarouselTypeInvertedTimeMachine) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180.0f, 180.0f)];
    }else{
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 300.0f)];
    }
    //view.image = [UIImage imageNamed:@"card.png"];
    view.contentMode = UIViewContentModeCenter;
    
    label = [[UILabel alloc] initWithFrame:view.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [label.font fontWithSize:8];
    label.tag = -1;
    [view addSubview:label];
    
    card = [[CardView alloc] initWithFrame:view.frame];
    card.delegate = self;
    card.tag = carousel.tag;
    
    [view addSubview:card];
    //    }else{
    //        //get a reference to the label in the recycled view
    //        label = (UILabel *)[view viewWithTag:-1];
    //        card = (CardView*)[view viewWithTag:carousel.tag];
    ////        card.tag = carousel.tag;
    //    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    NSMutableArray *item;
    
    //    if (carousel.type == iCarouselTypeInvertedTimeMachine) {
    //        view.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    //    }
    item = [self.cardsDatas objectAtIndex:carousel.tag];
    label.text = [NSString stringWithFormat:@"index %d",index];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    card.imageView.image = [UIImage imageWithContentsOfFile:[documentPath stringByAppendingPathComponent:[item objectAtIndex:index]]];    //NSLog(@"index = %d",index);

    return view;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //NSLog(@"value = %f",value);
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return NO;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            if (_carousel.type == iCarouselTypeCoverFlow2) {
                return value*1.5;
            }else if(_carousel.type == iCarouselTypeLinear){
                return 0.01;
            }else{
                return value*0.7;
            }
        }
        case iCarouselOptionArc:{
            return value*0.6;
        }
        case iCarouselOptionRadius:
        {
            return value*2;
        }
        case iCarouselOptionTilt:{
            return 0.75;
        }
        case iCarouselOptionFadeMin:{
            //if (_carousel.type == iCarouselTypeWheel) {
            return -0.2;
            //}
        }
        case iCarouselOptionFadeMax:
            //if (_carousel.type == iCarouselTypeWheel) {
            return 0.2;
            //}
        case iCarouselOptionFadeRange:
            //if (_carousel.type == iCarouselTypeWheel) {
            return 2;
            //}
            //        case iCarouselOptionAngle:
            //            return value*0.8;
        default:
        {
            return value;
        }
    }
}

-(BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index{
    if (index != carousel.currentItemIndex) {
        [carousel scrollToItemAtIndex:index animated:YES];
    }
   
    return NO;
}
#pragma mark - End Sorting

-(void)fuckIFinished{
    //move away
    for (int i = NOT_SORTED; i<[self.cardsViews count]; i++) {
        iCarousel *carousel = [self.cardsViews objectAtIndex:i];
        [carousel scrollByNumberOfItems:-10 duration:1];
    }

    [UIView animateWithDuration:1
                          delay:0.3
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         for (int i = NOT_SORTED; i<[self.cardsViews count]; i++) {
                             iCarousel *carousel = [self.cardsViews objectAtIndex:i];
                             carousel.transform = CGAffineTransformMakeTranslation(500, 0);
                         }
                                             }
                     completion:^(BOOL finished){
                         OverviewViewController *newViewController = [[OverviewViewController alloc] init];
                         NSRange range;
                         range.location = 0;
                         range.length = 3;
                         [self.cardsDatas removeObjectsInRange:range];
                         [newViewController setUpDatas:self.cardsDatas label:self.labelDatas];
                         [newViewController setScrollViewOffset:self.scrollView.contentOffset];
                         [self.navigationController pushViewController:newViewController animated:NO];

                     }
     ];
}
@end
