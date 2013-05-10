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
#import "CardData.h"

#define NOT_SORTED 3
@interface SecondQsortViewController ()<CardIsSorting,iCarouselDataSource,iCarouselDelegate>
@property (nonatomic,strong) UIScrollView *unsortedGroup;
@property (nonatomic,strong) iCarousel *sortedGroup;
@end

@implementation SecondQsortViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
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

    self.unsortedGroup = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 500, 768)];
    self.unsortedGroup.contentSize = CGSizeMake(500, 768*3);
    self.unsortedGroup.pagingEnabled = YES;
    self.unsortedGroup.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.unsortedGroup];

 
    //first three cardViews are unsorted
    self.cardsViews = [NSMutableArray array];
    for (int i = 0; i<3; i++) {
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, i*768, 500, 600)];
        carousel.type = iCarouselTypeRotary;
        carousel.backgroundColor = [UIColor cyanColor];
        carousel.tag = i;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.vertical = YES;
        //cards.backgroundColor = [UIColor blueColor];
        carousel.contentOffset = CGSizeMake(-400, 0);
        carousel.viewpointOffset = CGSizeMake(-300,0);

        [self.cardsViews addObject:carousel];
    }
    
    for (int i=0; i<9; i++) {
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 500, 150)];
        carousel.type = iCarouselTypeInvertedTimeMachine;
        carousel.tag = NOT_SORTED + i;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.backgroundColor = [UIColor blackColor];
        [self.cardsViews addObject:carousel];

    }
    self.sortedGroup = [[iCarousel alloc] initWithFrame:CGRectMake(500, 0, 600, 768)];
    self.sortedGroup.type = iCarouselTypeLinear;
    self.sortedGroup.vertical = YES;
    self.sortedGroup.delegate = self;
    self.sortedGroup.dataSource = self;
    self.sortedGroup.backgroundColor = [UIColor redColor];
    self.sortedGroup.centerItemWhenSelected = NO;
    [self.view addSubview:self.sortedGroup];

    for (int i=0; i<NOT_SORTED; i++) {
        [self.unsortedGroup addSubview:[self.cardsViews objectAtIndex:i]];
    }
    //TODO: setup labelViews
}

#pragma mark - CardIsSorting Delegate Function
-(void)isMoving:(CardView *)card{
    
    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
    int sortedIndex = 0;
    
    [self.view bringSubviewToFront:[self.cardsViews objectAtIndex:card.tag]];
    if (cardPosition.origin.x + card.frame.size.width > 512) {
        card.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
    }else{
        card.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }
    for (UIView *scoreBox in self.cardsViews) {
        if (scoreBox.tag < NOT_SORTED) {
            continue;
        }else{
            ////            NSLog(@"scorebox position (x,y) = (%f, %f)",scoreBox.frame.origin.x,scoreBox.frame.origin.y);
            ////            NSLog(@"card position (x,y) = (%f, %f)",card.frame.origin.x,card.frame.origin.y);
            ////            NSLog(@"converted postition (x,y) = (%f, %f)",cardPosition.origin.x,cardPosition.origin.y);
            //
            //if overlap
            if (CGRectIntersectsRect(scoreBox.frame, cardPosition)) {
                            scoreBox.backgroundColor = [UIColor blueColor];
                sortedIndex = scoreBox.tag;
            }else{
                            scoreBox.backgroundColor = [UIColor blueColor];
            }
        }
    }
}
-(void)cardMovingEnd:(CardView *)card{
    int sortedToGroup = 0;
    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
    
    //NSLog(@"card.tag = %d",card.tag);
    //check overlap
    for (UIView *scoreBox in self.cardsViews) {
        if (scoreBox.tag < NOT_SORTED) {
            continue;
        }
        if (CGRectIntersectsRect(scoreBox.frame, cardPosition)) {
            //assign to that group
            //            scoreBox.highlighted = NO;
            sortedToGroup = scoreBox.tag;
            break;
        }
    }
    
    NSInteger cardLeft = 1;
    if (sortedToGroup == card.tag) {
        //put it back to its origin position
        card.frame = [card superview].frame;
    }else{
        cardLeft = [self moveCard:card fromGroup:card.tag toGroup:sortedToGroup];
        card.tag = sortedToGroup;
    }
    
    //NSLog(@"unsorted cards %d",self.unsortedCards);
    //NSLog(@"the card sorted to group %d",sortedToGroup);
    
    if (cardLeft == 0) {
        //TODO:fuck I finished!!
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
    if (from == NOT_SORTED) {
        return [oldDatas count];
    }else{
        return 1;
    }
    
}
#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    if (carousel == self.sortedGroup){
        return 9;
    }else{
        NSMutableArray *carouselDatas;
//        NSLog(@"carousel %d",carousel.tag);
//        for (NSString *path in carouselDatas) {
//            NSLog(@"data %@",path);
//        }
        carouselDatas = [self.cardsDatas objectAtIndex:carousel.tag];
        return [carouselDatas count];
    }
    
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    //TODO: handle the nested iCarousel View
    UILabel *label = nil;
    CardView *card = nil;
    
    if (carousel == self.sortedGroup) {
        //NSLog(@"index %d",index);
        //configure inner view
        view = [self.cardsViews objectAtIndex:index + NOT_SORTED];
    }else{
    //NSLog(@"carousel number %d",carousel.tag);
    //create new view if no view is available for recycling
    //    if (view == nil)
    //    {
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, 250.0f)];
    //view.image = [UIImage imageNamed:@"card.png"];
    //view.backgroundColor = [UIColor whiteColor];
    view.contentMode = UIViewContentModeCenter;
    
    label = [[UILabel alloc] initWithFrame:view.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [label.font fontWithSize:8];
    label.tag = -1;
    [view addSubview:label];
    
    card = [[CardView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    card.delegate = self;
    card.tag = carousel.tag;
    if (carousel.type == iCarouselTypeInvertedTimeMachine) {
        card.transform = CGAffineTransformMakeScale(0.7f, 0.7f);
        card.frame = view.frame;
    }
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
    card.imageView.image = [UIImage imageWithContentsOfFile:[item objectAtIndex:index]];
    //NSLog(@"index = %d",index);
    }
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
            if (_carousel.type == iCarouselTypeRotary) {
                return value;
            }else if (_carousel.type == iCarouselTypeLinear){
                return value*1.5;
            }else{
                return 0.0f;
            }
        }
        case iCarouselOptionArc:{
            return value;
        }
        case iCarouselOptionFadeMax:
        {
            return value;
        }
        case iCarouselOptionRadius:
        {
            return value*1.25f;
        }
        case iCarouselOptionTilt:{
            return value*2.25f;
        }
        default:
        {
            return value;
        }
    }
}

@end
