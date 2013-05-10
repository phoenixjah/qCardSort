//
//  SortingViewController.m
//  qsort card
//
//  Created by Chia Lin on 13/5/6.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import "SortingViewController.h"
#import "iCarousel.h"
#import "CardView.h"
#import "CardData.h"
#import "Constant.h"
#import "SettingViewController.h"
@interface SortingViewController ()<CardIsSorting,iCarouselDataSource,iCarouselDelegate,GetSettingProtocol>
@property (nonatomic,strong) UIButton *goSettingBtn;
@property (nonatomic,strong) UIButton *loadCardsFromFileBtn;

@end

@implementation SortingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor grayColor];
}

-(void)viewDidAppear:(BOOL)animated{
       if ([self.cardsDatas count] == 0) {
        //TODO:adjust loadCardsBtn frame
        self.loadCardsFromFileBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [self.loadCardsFromFileBtn  addTarget:self action:@selector(loadCardFromFile:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.loadCardsFromFileBtn];
    }else{
        //add cards
        for (iCarousel* cards in self.cardsViews) {
            [self.view addSubview:cards];
            cards.delegate = self;
            cards.dataSource = self;
        }
        [self.loadCardsFromFileBtn removeFromSuperview];
        self.loadCardsFromFileBtn = nil;
    }
    
    if ([self.labelDatas count] == 0) {
        self.goSettingBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        //TODO:adjust goSettingBtn's frame
        [self.goSettingBtn addTarget:self action:@selector(goSettingView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.goSettingBtn];
    }else{
        [self.goSettingBtn removeFromSuperview];
        self.goSettingBtn = nil;
        NSDictionary *data = [self.labelDatas objectAtIndex:0];
        ((UILabel*)[self.labelViews objectAtIndex:0]).text = [data objectForKey:KEY_FROM];
        ((UILabel*)[self.labelViews objectAtIndex:1]).text = @"MEDIUM";
        ((UILabel*)[self.labelViews objectAtIndex:2]).text = [data objectForKey:KEY_TO];
        for (UILabel *label in self.labelViews) {
            [self.view addSubview:label];
        }
        
    }
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
        if ([files count]==0) {
            return _allCards;
        }else{
            for (NSString *file in files) {
                //NSLog(@"file path = %@",file);
                CardData *card = [[CardData alloc] init];
                card.imageDataPath = [documentPath stringByAppendingPathComponent:file];
                card.group = NOT_SORTED;
                [_allCards addObject:card];
                card = nil;
            }
        }
    }
    
    return _allCards;
}

-(NSMutableArray*)cardsViews{
    
    if (_cardsViews == nil) {
        //NSLog(@"init cardsView");
        int i;
        _cardsViews = [NSMutableArray array];
        
        //This is unsorted cards
        iCarousel *cards = [[iCarousel alloc] initWithFrame:CGRectMake(0, 250, 1024, 768)];
        cards.tag = NOT_SORTED;
        cards.type = iCarouselTypeRotary;
        cards.backgroundColor = [UIColor blueColor];
        [_cardsViews addObject:cards];
        cards = nil;
        
        for (i=0; i<3; i++) {
            cards = [[iCarousel alloc] initWithFrame:CGRectMake(20 + i*400, 30, 200, 200)];
            cards.type = iCarouselTypeTimeMachine;
            cards.tag = i+1;
            cards.backgroundColor = [UIColor blackColor];
            [_cardsViews addObject:cards];
            cards = nil;
        }
    }
    return _cardsViews;
}

-(NSMutableArray*)cardsDatas{
    
    if (_cardsDatas == nil) {
        _cardsDatas = [NSMutableArray array];
        NSMutableArray *initDatas = [NSMutableArray array];
        for (CardData* cardData in self.allCards) {
            [initDatas addObject:cardData.imageDataPath];
        }
        [_cardsDatas insertObject:initDatas atIndex:NOT_SORTED];
        initDatas = nil;
        
        int i;
        for (i=0; i<3; i++) {
            initDatas = [NSMutableArray array];
            [_cardsDatas addObject:initDatas];
        }
    }
    return _cardsDatas;
}

-(NSMutableArray*)labelViews{
    if (_labelViews == nil) {
        _labelViews = [NSMutableArray array];
        for (int i=0; i<3; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 50+i*200, 50, 30)];
            [_labelViews addObject:label];
        }
    }
    return _labelViews;
}

-(void)goSettingView:(id)sender{
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    settingViewController.settingDelegate = self;
    settingViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:settingViewController animated:YES completion:nil];
}

-(void)loadCardFromFile:(id)sender{
    //TODO:loadCardFromFile function
}
#pragma mark - CardIsSorting Delegate Function
-(void)isMoving:(CardView *)card{
    
    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
    int sortedIndex = NOT_SORTED;
    
    for (UIView *scoreBox in self.cardsViews) {
        if (scoreBox.tag == NOT_SORTED) {
            continue;
        }else{
            ////            NSLog(@"scorebox position (x,y) = (%f, %f)",scoreBox.frame.origin.x,scoreBox.frame.origin.y);
            ////            NSLog(@"card position (x,y) = (%f, %f)",card.frame.origin.x,card.frame.origin.y);
            ////            NSLog(@"converted postition (x,y) = (%f, %f)",cardPosition.origin.x,cardPosition.origin.y);
            //
            //if overlap
            if (CGRectIntersectsRect(scoreBox.frame, cardPosition)) {
                //TODO:give some feedback for sorting
                //            scoreBox.highlighted = YES;
                sortedIndex = scoreBox.tag;
            }else{
                //            scoreBox.highlighted = NO;
            }
        }
    }
}
-(void)cardMovingEnd:(CardView *)card{
    int sortedToGroup = NOT_SORTED;
    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
    
    //NSLog(@"card.tag = %d",card.tag);
    //check overlap
    for (UIView *scoreBox in self.cardsViews) {
        if (scoreBox.tag == NOT_SORTED) {
            continue;
        }
        if (CGRectIntersectsRect(scoreBox.frame, cardPosition)) {
            //TODO:reset the image of scorebox
            //assign to that group
            //            scoreBox.highlighted = NO;
            sortedToGroup = scoreBox.tag;
            break;
        }
    }
    
    NSInteger cardLeft = 1;
    if (sortedToGroup == card.tag) {
        //TODO:move card back to its origin position
    }else{
        cardLeft = [self moveCard:card fromGroup:card.tag toGroup:sortedToGroup];
        card.tag = sortedToGroup;
    }
    
    //NSLog(@"unsorted cards %d",self.unsortedCards);
    //NSLog(@"the card sorted to group %d",sortedToGroup);
    
    if (cardLeft == 0) {
        //TODO:start second stage sorting
        //to second stage sorting
                
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
    [newDatas insertObject:imagePath atIndex:index];
    [newGroupView insertItemAtIndex:index animated:YES];
    //NSLog(@"insert new item succefully");
    
    //remove it from old group
    if (oldGroupView.numberOfItems > 0) {
        NSInteger index = oldGroupView.currentItemIndex;
        [oldGroupView removeItemAtIndex:index animated:YES];
        [oldDatas removeObjectAtIndex:index];
        //NSLog(@"remove item succefully");
    }
    
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
    NSMutableArray *carouselDatas;
    
    carouselDatas = [self.cardsDatas objectAtIndex:carousel.tag];
    return [carouselDatas count];
    
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIImageView *)view
{
    UILabel *label = nil;
    CardView *card = nil;
    
    //NSLog(@"carousel number %d",carousel.tag);
    //create new view if no view is available for recycling
    //    if (view == nil)
    //    {
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, 250.0f)];
    //view.image = [UIImage imageNamed:@"card.png"];
    view.backgroundColor = [UIColor whiteColor];
    view.contentMode = UIViewContentModeCenter;
    
    label = [[UILabel alloc] initWithFrame:view.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [label.font fontWithSize:8];
    label.tag = -1;
    [view addSubview:label];
    
    card = [[CardView alloc] initWithFrame:CGRectMake(10, 10, 150, 150)];
    card.delegate = self;
    card.tag = carousel.tag;
    [view addSubview:card];
    //    }else{
    //        //get a reference to the label in the recycled view
    //        label = (UILabel *)[view viewWithTag:-1];
    //        card = (CardView*)[view viewWithTag:carousel.tag];
    //        card.tag = carousel.tag;
    //    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    NSMutableArray *item;
    
    item = [self.cardsDatas objectAtIndex:carousel.tag];
    label.text = [item objectAtIndex:index];
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

#pragma mark - SettingView Controller Protocol
-(void)settingisDone:(NSArray *)settingDatas{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.labelDatas = [NSArray arrayWithArray:settingDatas];
}

-(void)settingisCanceled{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
