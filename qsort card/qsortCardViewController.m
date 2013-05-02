//
//  qsortCardViewController.m
//  qsort card
//
//  Created by Chia Lin on 13/4/22.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import "qsortCardViewController.h"
#import "iCarousel.h"
#import "CardView.h"
#import "CardData.h"
#import "Constant.h"

@interface qsortCardViewController ()<CardIsSorting,iCarouselDataSource,iCarouselDelegate>
@end

@implementation qsortCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //init datas
    self.scoreBoxsData = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    for (iCarousel* scoreBox in self.scoreBoxsView) {
        [self.view addSubview:scoreBox];
    }
    [self.view addSubview:self.unsortedCardsView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Prepare Getter

-(NSMutableArray*)allCards{
    
    if (_allCards == nil) {
        _allCards = [NSMutableArray array];
        
        //load cards from file
        NSError *error;
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentPath
                                                                         error:&error];
        //TODO:handle some error when loading file
        for (NSString *file in files) {
            //NSLog(@"file path = %@",file);
            CardData *card = [[CardData alloc] init];
            card.imageDataPath = [documentPath stringByAppendingPathComponent:file];
            card.group = NOT_SORTED;
            [_allCards addObject:card];
            card = nil;
        }
    }
    
    return _allCards;
}

-(NSMutableArray*)scoreBoxsView{
    
    if (_scoreBoxsView == nil) {
        int i;
        _scoreBoxsView = [NSMutableArray array];
        for (i=0; i<3; i++) {
            iCarousel *scoreBoxView = [[iCarousel alloc] initWithFrame:CGRectMake(20 + i*400, 30, 180, 180)];
            scoreBoxView.type = iCarouselTypeTimeMachine;
            scoreBoxView.dataSource = self;
            scoreBoxView.delegate = self;
            scoreBoxView.backgroundColor = [UIColor blackColor];
            scoreBoxView.tag = i;
            [_scoreBoxsView addObject:scoreBoxView];
            scoreBoxView = nil;
        }
    }
    return _scoreBoxsView;
}

-(iCarousel*)unsortedCardsView{
    
    if (_unsortedCardsView == nil) {
        _unsortedCardsView = [[iCarousel alloc] initWithFrame:CGRectMake(0, 200, 1024, 768)];
        _unsortedCardsView.type = iCarouselTypeRotary;
        _unsortedCardsView.delegate = self;
        _unsortedCardsView.dataSource = self;
        _unsortedCardsView.backgroundColor = [UIColor blueColor];
    }
    
    return _unsortedCardsView;
}

-(NSMutableArray*)unsortedCardsData{
    
    if (_unsortedCardsData == nil) {
        _unsortedCardsData = [NSMutableArray array];
        for (CardData* cardData in self.allCards) {
            [_unsortedCardsData addObject:cardData.imageDataPath];
        }
    }
    return _unsortedCardsData;
}
#pragma mark - CardIsSorting Delegate Function
-(void)isMoving:(CardView *)card{

    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
    int sortedIndex = NOT_SORTED;
   
        for (UIView *scoreBox in self.scoreBoxsView) {
////            NSLog(@"scorebox position (x,y) = (%f, %f)",scoreBox.frame.origin.x,scoreBox.frame.origin.y);
////            NSLog(@"card position (x,y) = (%f, %f)",card.frame.origin.x,card.frame.origin.y);
////            NSLog(@"converted postition (x,y) = (%f, %f)",cardPosition.origin.x,cardPosition.origin.y);
//        
            //if overlap
        if (CGRectIntersectsRect(scoreBox.frame, cardPosition)) {
//            scoreBox.highlighted = YES;
//            sortedIndex = [self.scoreBoxs indexOfObject:scoreBox];
            break;
        }else{
//            scoreBox.highlighted = NO;
        }
    }
//    
    if (sortedIndex != NOT_SORTED) {
//        //card move inside box
//        [card scaleTo:0.6];
//        //display scorebox content
//        //ScoreBox *scoreboxNow = [self.scoreBoxs objectAtIndex:sortedIndex];
//        //[scoreboxNow displayCards];
//    }else{
//        [card scaleTo:1.0];
    }
}
-(void)cardMovingEnd:(CardView *)card{
    int sortedToGroup = NOT_SORTED;
    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
//    Card *sortedCard = nil;
//    
//    //check overlap
    for (UIView *scoreBox in self.scoreBoxsView) {
//      //check overlap
        if (CGRectIntersectsRect(scoreBox.frame, cardPosition)) {
            //assign to that group
//            scoreBox.highlighted = NO;
            sortedToGroup = [self.scoreBoxsView indexOfObject:scoreBox];
//            if (card.group != NOT_SORTED) {
//                //it was sorted before, we have to clean its old record in scorebox
//                ScoreBox *oldScoreBox = [self.scoreBoxs objectAtIndex:card.group];
//                [oldScoreBox.cards removeObject:card];
//                self.unsortedCards++;
//                oldScoreBox = nil;
//            }else{
//                [self removeItem];
//                sortedCard = card;
//                sortedCard.frame = cardPosition;
//                sortedCard.backgroundColor = [UIColor blackColor];
//                [self.view addSubview:sortedCard];
//            }
//            //NSLog(@"at group %d",sortedToGroup);
//            card.group = sortedToGroup;
//            [scoreBox.cards addObject:card];
//            self.unsortedCards--;
//            //move cards closer to pile
//            [UIView animateWithDuration:0.25
//                             animations:^{
//                                 [card scaleTo:0.3];
//                                 [card setCenter:scoreBox.center];
//                             }
//             ];
//            //[scoreBox endDisplayCards];
            break;
        }
    }
//    
    if (sortedToGroup == NOT_SORTED) {
        //card is not sorted
//        //if is sorted before, clean its record, and put it back to unsorted group
//        if (card.group != NOT_SORTED) {
//            ScoreBox *oldScoreBox = [self.scoreBoxs objectAtIndex:card.group];
//            [oldScoreBox.cards removeObject:card];
//            self.unsortedCards++;
//            oldScoreBox = nil;
//            //[card removeFromSuperview];
//            [self insertItem];
//        }else{
//            //put it back to its origin place
//            [UIView animateWithDuration:0.25
//                             animations:^{
//                                 card.frame = CGRectMake([card superview].frame.origin.x, [card superview].frame.origin.y, card.frame.size.width, card.frame.size.height);
//                             }
//             ];
//        }
//        card.group = NOT_SORTED;
    }
//    //NSLog(@"unsorted cards %d",self.unsortedCards);
    //NSLog(@"the card sorted to group %d",sortedToGroup);
//    
//    if (self.unsortedCards == 0) {
//        //to second stage sorting
//    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    if (carousel == self.unsortedCardsView) {
        return [self.unsortedCardsData count];
    }else if ([self.scoreBoxsView containsObject:carousel]){
        NSMutableArray *scoreBoxData = [self.scoreBoxsData objectAtIndex:carousel.tag];
        return [scoreBoxData count];
    }else{
        return -1;
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIImageView *)view
{
    UILabel *label = nil;
    CardView *card = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 500.0f, 500.0f)];
        view.image = [UIImage imageNamed:@"card.png"];
        view.contentMode = UIViewContentModeCenter;
        
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:50];
        label.tag = 1;
        [view addSubview:label];
        
        card = [[CardView alloc] initWithFrame:CGRectMake(10, 10, 380, 380)];
        card.delegate = self;
        card.tag = 2;
        [view addSubview:card];
    }else{
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
        card = (CardView*)[view viewWithTag:2];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    NSMutableArray *item;
    
    if (carousel == self.unsortedCardsView) {
        item = [NSMutableArray arrayWithArray:self.unsortedCardsData];
    }else if ([self.scoreBoxsView containsObject:carousel]){
        item = [self.scoreBoxsData objectAtIndex:carousel.tag];
    }
    label.text = [NSString stringWithFormat:@"%d",[self.unsortedCardsData count]];
    card.imageView.image = [UIImage imageWithContentsOfFile:[item objectAtIndex:index]];
    //NSLog(@"index = %d",index);
    item = nil;
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
            return value * 0.85f;
        }
        case iCarouselOptionArc:{
            return value;
        }
        case iCarouselOptionFadeMax:
        {
            return value;
        }
        default:
        {
            return value;
        }
    }
}

-(BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index{
    NSLog(@"begin");
    return YES;
}
-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"end");
}
//- (void)insertItem
//{
//    NSInteger index = MAX(0, self.carousel.currentItemIndex);
//    [self.items insertObject:[NSNumber numberWithInt:self.carousel.numberOfItems] atIndex:index];
//    [self.carousel insertItemAtIndex:index animated:YES];
//}
//
//- (NSInteger)removeItem
//{
//    if (self.carousel.numberOfItems > 0)
//    {
//        NSInteger index = self.carousel.currentItemIndex;
//        [self.carousel removeItemAtIndex:index animated:YES];
//        [self.items removeObjectAtIndex:index];
//    }
//    
//    return self.carousel.numberOfItems;
//}

@end
