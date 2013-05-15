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
#import "SettingViewController.h"
#import "SecondQsortViewController.h"

@interface qsortCardViewController ()<CardIsSorting,iCarouselDataSource,iCarouselDelegate,GetSettingProtocol>
@property (nonatomic,strong) UIButton *goSettingBtn;
@property (nonatomic,strong) UIButton *loadCardsFromFileBtn;
@end

@implementation qsortCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

-(void)viewDidAppear:(BOOL)animated{
    //NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
    
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
    }

    if ([self.labelDatas count] == 0) {
        self.goSettingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //TODO:adjust goSettingBtn's frame
        self.goSettingBtn.frame = CGRectMake(500, 500, 100, 50);
        [self.goSettingBtn setTitle:@"Setting" forState:UIControlStateNormal];
        [self.goSettingBtn addTarget:self action:@selector(goSettingView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.goSettingBtn];
    }else{
        self.goSettingBtn.frame = CGRectMake(900, 600, 100, 50);
        NSDictionary *data = [self.labelDatas objectAtIndex:0];
        ((UILabel*)[self.labelViews objectAtIndex:0]).text = [data objectForKey:KEY_FROM];
        ((UILabel*)[self.labelViews objectAtIndex:1]).text = @"Medium";
        ((UILabel*)[self.labelViews objectAtIndex:2]).text = [data objectForKey:KEY_TO];
        for (UILabel *label in self.labelViews) {
            [self.view addSubview:label];
        }
        iCarousel *unsortedCards = [self.cardsViews objectAtIndex:NOT_SORTED];
        [unsortedCards scrollByNumberOfItems:unsortedCards.numberOfItems-1 duration:1.25];
        
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
        iCarousel *cards = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0,500, 768)];
        cards.tag = NOT_SORTED;
        cards.type = iCarouselTypeWheel;
        cards.vertical = YES;
        //cards.backgroundColor = [UIColor blueColor];
        //cards.contentOffset = CGSizeMake(-300, 0);
        //cards.viewpointOffset = CGSizeMake(-300,0);
        [_cardsViews addObject:cards];
        
        for (i=0; i<3; i++) {
            cards = [[iCarousel alloc] initWithFrame:CGRectMake(650, 125+i*250, 500, 100)];
            cards.type = iCarouselTypeInvertedTimeMachine;
            cards.contentOffset = CGSizeMake(-80, 0);
            cards.tag = i+1;
            cards.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1+0.3*i];
            [_cardsViews addObject:cards];
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
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(515, 90+i*250, 141, 50)];
            label.textAlignment = NSTextAlignmentCenter;
            //TODO:set font
            //[label setFont:[UIFont fontWithName:@"Candara" size:25.0f]];
            [_labelViews addObject:label];
        }
       
//        UILabel *firstLabel = [_labelViews objectAtIndex:0];
//        firstLabel.textColor = [UIColor colorWithRed:88.0/255.0 green:189.0/255.0 blue:236.0/255.0 alpha:1];
//        firstLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"labels_01.png"]];
//        firstLabel = nil;
//        UILabel *secondLabel = [_labelViews objectAtIndex:1];
//        secondLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:182.0/255.0 blue:183.0/255.0 alpha:1];
//        secondLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"labels_04.png"]];
//        secondLabel = nil;
//        UILabel *thirdLabel = [_labelViews objectAtIndex:2];
//        thirdLabel.textColor = [UIColor colorWithRed:91.0/255.0 green:91.0/255.0 blue:96.0/255.0 alpha:1];
//        thirdLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"labels_07.png"]];
//        thirdLabel = nil;
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
   
    [self.view bringSubviewToFront:[self.cardsViews objectAtIndex:card.tag]];
    if (cardPosition.origin.x > 400 && card.tag == NOT_SORTED) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             card.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
                         }
         ];
    }else if(cardPosition.origin.x < 400 && card.tag != NOT_SORTED){
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
                //TODO:scoreBox hilight image
                            scoreBox.backgroundColor = [UIColor lightGrayColor];
                sortedIndex = scoreBox.tag;
            }else{
                            scoreBox.backgroundColor = [UIColor blackColor];
            }
        }
    }
}
-(void)cardMovingEnd:(CardView *)card{
    int sortedToGroup = card.tag;
    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
    
    //NSLog(@"card.tag = %d",card.tag);
    //check overlap
    for (UIView *scoreBox in self.cardsViews) {
        if (scoreBox.tag == NOT_SORTED) {
            continue;
        }
        if (CGRectIntersectsRect(scoreBox.frame, cardPosition)) {
            //assign to that group
            //TODO:scorebox highlight color
            scoreBox.backgroundColor = [UIColor blackColor];
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
    
//    for (int i=0;i<[self.cardsDatas count];i++) {
//        NSMutableArray *data = [self.cardsDatas objectAtIndex:i];
//        for (NSString *path in data) {
//            NSLog(@"carousel %d, cardDataPath = %@",i,path);
//        }
//    }

    if (cardLeft == 0) {
        //TODO:to second sorting
        [self.cardsDatas removeObjectAtIndex:0];
        [UIView animateWithDuration:1.5
                         animations:^{
                             for (UIView *cards in self.cardsViews) {
                                 cards.transform = CGAffineTransformMakeTranslation(500, 0);
                             }
                         }
                         completion:^(BOOL finished){
                             SecondQsortViewController *newViewController = [[SecondQsortViewController alloc] init];
                             [newViewController setUpDatas:self.cardsDatas label:self.labelDatas];
                             [self.navigationController pushViewController:newViewController animated:YES];
                         }
         ];
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
    if (carousel.type == iCarouselTypeInvertedTimeMachine) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180.0f, 180.0f)];
    }else{
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 300.0f)];
    }
        //view.image = [UIImage imageNamed:@"card.png"];
        view.backgroundColor = [UIColor blackColor];
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
//    if (carousel.type == iCarouselTypeInvertedTimeMachine) {
//        card.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
//        card.frame = view.frame;
//    }
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
            if (_carousel.type == iCarouselTypeInvertedTimeMachine) {
                return 0.2;
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
            return value*1.2;
        }
        case iCarouselOptionFadeMin:{
            if (_carousel.type == iCarouselTypeWheel) {
                return -0.2;
            }
        }
        case iCarouselOptionFadeMax:
            if (_carousel.type == iCarouselTypeWheel) {
                return 0.2;
            }
        case iCarouselOptionFadeRange:
            if (_carousel.type == iCarouselTypeWheel) {
                return 2;
            }
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
    //NSLog(@"index = %d",index);
    return NO;
}

#pragma mark - SettingView Controller Protocol
-(void)settingisDone:(NSArray *)settingDatas{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.labelDatas = [NSArray arrayWithArray:settingDatas];
}

-(void)settingisCanceled{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - iCarousel Delegate
//-(void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
//    if (carousel.type == iCarouselTypeWheel) {
//        [UIView animateWithDuration:0.5
//                         animations:^{
//                             carousel.currentItemView.transform = CGAffineTransformMakeTranslation(80, 0);
//        }
//         ];
//    }
//}
//-(void)carouselWillBeginDragging:(iCarousel *)carousel{
//    if (carousel.type == iCarouselTypeWheel) {
//        [UIView animateWithDuration:0.3
//                         animations:^{
//                             carousel.currentItemView.transform = CGAffineTransformMakeTranslation(-80, 0);
//                         }
//         ];
//    }
//}
@end
