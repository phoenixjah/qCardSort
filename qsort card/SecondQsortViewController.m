//
//  SecondQsortViewController.m
//  qsort card
//
//  Created by Chia Lin on 13/5/6.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import "iCarousel.h"
#import "CardView.h"
#import "LabelView.h"
#import "Constant.h"
#import "OverviewViewController.h"
#import "ShowProgressImageView.h"
#import "SecondQsortViewController.h"


#define NOT_SORTED 3
#define PAGE_1 0
#define PAGE_2 768
#define PAGE_3 1536
#define selectedTag 3

@interface SecondQsortViewController ()<CardIsSorting,iCarouselDataSource,iCarouselDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) ShowProgressImageView *page_1;
@property (nonatomic,strong) ShowProgressImageView *page_2;
@property (nonatomic,strong) ShowProgressImageView *page_3;
@property (nonatomic,strong) UIImageView *selectedImage;
@property NSTimer *timer;
@end

@implementation SecondQsortViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    

    //TODO:setup pageControl
    self.page_1 = [[ShowProgressImageView alloc] initWithFrame:CGRectMake(0, 300, 50, 50)];
    [self.view addSubview:self.page_1];
    self.page_2 = [[ShowProgressImageView alloc] initWithFrame:CGRectMake(0, 350, 50, 50)];
    [self.view addSubview:self.page_2];
    self.page_3 = [[ShowProgressImageView alloc] initWithFrame:CGRectMake(0, 400, 50, 50)];
    [self.view addSubview:self.page_3];

    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.scrollView.contentSize = CGSizeMake(1024, 768*3);
    self.scrollView.delegate = self;
    [self.scrollView setContentOffset:CGPointMake(0, 768)];
    self.scrollView.pagingEnabled = YES;
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(530, 0, 68, 2304)];
    background.image = [UIImage imageNamed:@"labels_all.png"];
    background.contentMode = UIViewContentModeTop;
    [self.scrollView addSubview:background];
    [self.view addSubview:self.scrollView];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //NSLog(@"bounds.heoght %f",self.view.bounds.size.height);
    if (self.cardsDatas != nil) {
        [self setupViews];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIImageView*)selectedImage{
    if (_selectedImage == nil) {
        _selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected.png"]];
    }
    return _selectedImage;
}
#pragma mark - Setup Datas
-(void)setUpDatas:(NSArray *)cardDatas{

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
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(20, 70 + i*768, 350, 650)];
        carousel.type = iCarouselTypeRotary;
        carousel.tag = i;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.vertical = YES;
        carousel.currentItemIndex = ((NSNumber*)[self.currentIndexs objectAtIndex:i]).integerValue;
        //carousel.backgroundColor = [UIColor blueColor];
        //[carousel scrollByNumberOfItems:100 duration:0];
        [self.cardsViews addObject:carousel];
    }
    
    for (int i=0; i<9; i++) {
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(600, 70 + i*260, 500, 90)];
        carousel.type = iCarouselTypeCoverFlow2;
        carousel.tag = NOT_SORTED + i;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.contentOffset = CGSizeMake(-50, 0);
        [self.cardsViews addObject:carousel];

    }
    for (iCarousel *cards in self.cardsViews) {
        [self.scrollView addSubview:cards];
    }
    //TODO: setup labelViews
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), LABEL_FILENAME];
    NSDictionary *data = [NSDictionary dictionaryWithDictionary:([NSArray arrayWithContentsOfFile:outputPath][self.stage])];
    self.labelViews = [NSMutableArray array];
    for (int i =0; i<3; i++) {
        LabelView *label = [[LabelView alloc] initWithFrame:CGRectMake(450, 20 + i*768, 140, 50)];
        [self.labelViews addObject:label];
        [self.scrollView addSubview:label];
    }
    ((LabelView*)[self.labelViews objectAtIndex:0]).label.text = [NSString stringWithFormat:@"%@",[data objectForKey:KEY_FROM]];
    ((LabelView*)[self.labelViews objectAtIndex:1]).label.text = @"Medium";
    ((LabelView*)[self.labelViews objectAtIndex:2]).label.text = [NSString stringWithFormat:@"%@",[data objectForKey:KEY_TO]];
    
    //pageControl numbers
    [self.page_1 setLabel:[NSString stringWithFormat:@"%d",[self.cardsDatas[0] count]]];
    [self.page_2 setLabel:[NSString stringWithFormat:@"%d",[self.cardsDatas[1] count]]];
    [self.page_3 setLabel:[NSString stringWithFormat:@"%d",[self.cardsDatas[2] count]]];
    self.page_2.highlighted = YES;
    
    [self openAnimation];
}

-(void)openAnimation{
    __block iCarousel *mediumCards = self.cardsViews[1];
    //[mediumCards scrollByNumberOfItems:[mediumCards numberOfItems]/2 duration:0];
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
                                              [UIView animateWithDuration:1
                                                               animations:^{
                                                                   for (int i=0;i<NOT_SORTED;i++) {
                                                                       ((iCarousel*)self.cardsViews[i]).type = iCarouselTypeWheel;
                                                                   }
                                                               }
                                                               completion:^(BOOL finished){
                                                                   mediumCards = nil;
                                                               }
                                               ];
                                                                                    }
                          ];
                     }
     ];
}

#pragma mark - CardIsSorting Delegate Function
-(void)isMoving:(CardView *)card{
    
    CGRect cardPosition = [card convertRect:card.bounds toView:self.scrollView];
    
    [self.scrollView bringSubviewToFront:[self.cardsViews objectAtIndex:card.tag]];
    if (cardPosition.origin.x > 380 && card.tag < NOT_SORTED) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             card.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
                         }
         ];
    }else if(cardPosition.origin.x < 380 && card.tag > NOT_SORTED){
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

    if (cardPosition.origin.y + 20 < self.scrollView.contentOffset.y) {
        [self attemptToMoveDiffPage:card];
    }else if(cardPosition.origin.y + card.bounds.size.height - 20 > self.scrollView.contentOffset.y + 768.0){
        [self attemptToMoveDiffPage:card];
    }
//    NSArray *nowOnDisplay = [self.sortedGroup indexesForVisibleItems];
//    for (NSNumber *i in nowOnDisplay) {
//        NSLog(@"visible index = %d",i.integerValue);
//    }
    for (int i = NOT_SORTED;i<[self.cardsViews count];i++) {
        iCarousel *scoreBox = [self.cardsViews objectAtIndex:i];
        CGRect boxPosition = [scoreBox convertRect:scoreBox.bounds toView:self.scrollView];
        
        //if overlap
            if (CGRectIntersectsRect(boxPosition, cardPosition)) {
                        scoreBox.backgroundColor = [UIColor colorWithPatternImage:self.selectedImage.image];
            }else{
                        scoreBox.backgroundColor = nil;
            }
        
    }
}
-(void)cardMovingEnd:(CardView *)card{
    int sortedToGroup = card.tag;
    CGRect cardPosition = [card convertRect:card.bounds toView:self.scrollView];
    
    //NSLog(@"card.tag = %d",card.tag);
    //check overlap
    for (UIView *scoreBox in self.cardsViews) {
        CGRect boxPosition = [scoreBox convertRect:scoreBox.bounds toView:self.scrollView];
        if (CGRectIntersectsRect(boxPosition, cardPosition)) {
            //assign to that group
            scoreBox.backgroundColor = nil;
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
        [self fuckIFinished];
    }
    //update page control
    int indexOfCardsNow = [self whereAmI:self.scrollView.contentOffset.y];
    //NSLog(@"indexOfCardsNow %d",indexOfCardsNow);
    switch (indexOfCardsNow) {
        case 0:
            [self.page_1 setLabel:[NSString stringWithFormat:@"%d",[self.cardsDatas[0] count]]];
            break;
        case 1:
            [self.page_2 setLabel:[NSString stringWithFormat:@"%d",[self.cardsDatas[1] count]]];
            break;
        case 2:
            [self.page_3 setLabel:[NSString stringWithFormat:@"%d",[self.cardsDatas[2] count]]];
            break;
        default:
            break;
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
#pragma mark - card sorting move page function
-(void)attemptToMoveDiffPage:(CardView*)card{
    NSLog(@"try to move page");
    //CGPoint oldPostion = card.center;
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES ];

}
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
    CardView *card;
    

    //NSLog(@"carousel number %d",carousel.tag);
    //create new view if no view is available for recycling
    //    if (view == nil)
    //    {
    if (carousel.type == iCarouselTypeCoverFlow2) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150.0f, 150.0f)];
    }else{
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, 250.0f)];
    }
    //view.image = [UIImage imageNamed:@"card.png"];
    view.contentMode = UIViewContentModeCenter;
    
//    label = [[UILabel alloc] initWithFrame:view.bounds];
//    label.backgroundColor = [UIColor clearColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [label.font fontWithSize:8];
//    label.tag = -1;
//    [view addSubview:label];
    
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
//    label.text = [NSString stringWithFormat:@"index %d",index];
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
            }else if(_carousel.type == iCarouselTypeRotary){
                return 0.01;
            }else if(_carousel.type == iCarouselTypeInvertedWheel){
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
//            if (_carousel.type != iCarouselTypeTimeMachine) {
            return -0.2;
//            }
        }
        case iCarouselOptionFadeMax:
//            if (_carousel.type != iCarouselTypeTimeMachine) {
            return 0.2;
//            }
        case iCarouselOptionFadeRange:
//            if (_carousel.type != iCarouselTypeTimeMachine) {
            return 2;
//            }
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
                          delay:1.5
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
                         [newViewController setUpDatas:self.cardsDatas];
                         newViewController.stage = self.stage;
                         [newViewController setScrollViewOffset:self.scrollView.contentOffset];
                         [self.navigationController pushViewController:newViewController animated:NO];
                         
                         //clean all datas
                         for (UIView *card in self.cardsViews) {
                             [card removeFromSuperview];
                         }
                         for (UIView *label in self.labelViews) {
                             [label removeFromSuperview];
                         }
                         self.cardsDatas = nil;
                         self.cardsViews = nil;
                         self.labelViews = nil;
                         self.currentIndexs = nil;
                         self.page_1 = nil;
                         self.page_2 = nil;
                         self.page_3 = nil;
                         self.selectedImage = nil;
                         self.timer = nil;
                     }
     ];
}

#pragma mark - UIScrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //put away cards when scroll away
    int indexOfCardsNow = [self whereAmI:scrollView.contentOffset.y];
    //NSLog(@"indexOfCardsNow %d",indexOfCardsNow);
    switch (indexOfCardsNow) {
        case 0:
            self.page_1.highlighted = NO;
            break;
        case 1:
            self.page_2.highlighted = NO;
            break;
        case 2:
            self.page_3.highlighted = NO;
            break;
        default:
            break;
    }
    

    [UIView animateWithDuration:0.2
                     animations:^{
                         ((iCarousel*)[self.cardsViews objectAtIndex:indexOfCardsNow]).type = iCarouselTypeInvertedWheel;
                     }
     ];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //NSLog(@"scrollView ContentOffset.y = %f",scrollView.contentOffset.y);
    int indexOfWouldBeCards;
    //enable page scroll by hand
    //NSLog(@"will stop at %f",(*targetContentOffset).y);
    indexOfWouldBeCards = [self whereAmI:scrollView.contentOffset.y];
    
    [UIView animateWithDuration:0.8
                     animations:^{
                         ((iCarousel*)[self.cardsViews objectAtIndex:indexOfWouldBeCards]).type = iCarouselTypeWheel;
                     }
     ];
    
    switch (indexOfWouldBeCards) {
        case 0:
            self.page_1.highlighted = YES;
            break;
        case 1:
            self.page_2.highlighted = YES;
            break;
        case 2:
            self.page_3.highlighted = YES;
            break;
        default:
            break;
    }


}

-(int)whereAmI:(CGFloat)offsetY{
    if (offsetY >= PAGE_1 && offsetY < PAGE_2) {
        return 0;
    }else if (offsetY >= PAGE_2 && offsetY < PAGE_3){
        return 1;
    }else{
        return 2;
    }
}


@end
