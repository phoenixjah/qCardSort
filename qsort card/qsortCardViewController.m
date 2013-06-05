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
#import "SettingViewController.h"
#import "SecondQsortViewController.h"
#import "LabelView.h"
#import "ShowProgressImageView.h"

#define maskViewTag 10
#define NOT_SORTED 0
#define KEY_FROM @"FROM"
#define KEY_TO @"TO"
#define FILENAME @"Cards.plist"
#define LABEL_FILENAME @"Labels.plist"
@interface qsortCardViewController ()<CardIsSorting,iCarouselDataSource,iCarouselDelegate,GetSettingProtocol>
@property (nonatomic,strong) UIButton *goSettingBtn;
@property (nonatomic,strong) UIButton *loadCardsFromFileBtn;
@property (nonatomic,strong) NSArray *middleLables;
@property (nonatomic,strong) ShowProgressImageView *littleMan;
@end

@implementation qsortCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    self.view.clipsToBounds = YES;
    
    self.littleMan = [[ShowProgressImageView alloc] initWithImage:[UIImage imageNamed:@"progress.png"]];
}

-(void)viewDidAppear:(BOOL)animated{
    //NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), LABEL_FILENAME];
	//NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];

    //Has cards?
        
        //TODO:adjust loadCardsBtn frame
//        self.loadCardsFromFileBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
//        [self.loadCardsFromFileBtn  addTarget:self action:@selector(loadCardFromFile:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:self.loadCardsFromFileBtn];
    if ([self.allCards count] == 0 || ![fileManager fileExistsAtPath:outputPath]) {
        //Has set adj?
        UIImageView *beginScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"begin.png"]];
        beginScreen.tag = maskViewTag;
        [self.view addSubview:beginScreen];
        [self.view addSubview:self.goSettingBtn];
    }else{
        //both adj and cards is set, ready to start
        [[self.view viewWithTag:maskViewTag] removeFromSuperview];

        //self.goSettingBtn.frame = CGRectMake(900, 600, 100, 50);
        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:outputPath];
        ((LabelView*)[self.labelViews objectAtIndex:0]).label.text = [data objectForKey:KEY_FROM];
        ((LabelView*)[self.labelViews objectAtIndex:1]).label.text = @"Medium";
        ((LabelView*)[self.labelViews objectAtIndex:2]).label.text = [data objectForKey:KEY_TO];
        
        for (UIImageView *imageView in self.middleLables) {
            [self.view addSubview:imageView];
        }
        
        for (LabelView *label in self.labelViews) {
            [self.view addSubview:label];
        }
        //add cards
        for (iCarousel* cards in self.cardsViews) {
            [self.view addSubview:cards];
            cards.delegate = self;
            cards.dataSource = self;
        }
        

        UIImageView *maskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chia_black.png"]];
        maskView.tag = maskViewTag;

        UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        startBtn.frame = CGRectMake(86, 550, 108, 108);
        [startBtn setImage:[UIImage imageNamed:@"ready_btn"] forState:UIControlStateNormal];
        [startBtn setImage:[UIImage imageNamed:@"go_btn.png"] forState:UIControlStateHighlighted];
        [startBtn addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
        [maskView addSubview:startBtn];
        [maskView addSubview:self.goSettingBtn];
        maskView.userInteractionEnabled = YES;
        [self.view addSubview:maskView];
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
            _allCards = nil;
            return _allCards;
        }else{
            [_allCards addObjectsFromArray:files];
            NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(),FILENAME];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createFileAtPath:outputPath contents:nil attributes:nil];

            NSDictionary *dictionary = [[NSDictionary alloc] initWithObjects:files forKeys:files];

            [dictionary writeToFile:outputPath atomically:YES];
            dictionary = nil;
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
            cards = [[iCarousel alloc] initWithFrame:CGRectMake(600, 117+i*260, 500, 100)];
            cards.type = iCarouselTypeCoverFlow2;
            cards.contentOffset = CGSizeMake(-50, 0);
            //cards.clipsToBounds = YES;
            cards.tag = i+1;

            [_cardsViews addObject:cards];
        }
    }
    return _cardsViews;
}

-(NSMutableArray*)cardsDatas{
    
    if (_cardsDatas == nil) {
        _cardsDatas = [NSMutableArray array];
        NSMutableArray *initDatas = [NSMutableArray array];
        [initDatas addObjectsFromArray:self.allCards];
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
            LabelView *label = [[LabelView alloc] initWithFrame:CGRectMake(500, i*260, 140, 50)];
            UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"bar_0%d.png",i+2]]];
            [label insertSubview:background atIndex:0];
            [_labelViews addObject:label];
        }
    }
    return _labelViews;
}

-(UIButton*)goSettingBtn{
    
    if (_goSettingBtn == nil) {
        _goSettingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //TODO:adjust goSettingBtn's frame
        _goSettingBtn.frame = CGRectMake(900, 100, 90, 90);
        [_goSettingBtn setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
        [_goSettingBtn addTarget:self action:@selector(goSettingView:) forControlEvents:UIControlEventTouchUpInside];

    }
    
    return _goSettingBtn;
}
-(NSArray*)middleLables{
    if (_middleLables == nil) {
        UIImageView *labelImage_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bars_04.png"]];
        labelImage_1.center = CGPointMake(756, 390);
        UIImageView *labelImage_2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bars_05.png"]];
        labelImage_2.center = CGPointMake(756, 390);
        UIImageView *labelImage_3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bars_06.png"]];
        labelImage_3.center = CGPointMake(756, 390);
        
        _middleLables = [[NSArray alloc] initWithObjects:labelImage_1,labelImage_2,labelImage_3, nil];
    }


    return _middleLables;
}
-(void)goSettingView:(id)sender{
    SettingViewController *settingViewController = [[SettingViewController alloc] init];
    settingViewController.settingDelegate = self;
    settingViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //settingViewController.modalPresentationStyle = UIModalPresentationPageSheet;
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
                            scoreBox.backgroundColor = nil;
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
        if (CGRectIntersectsRect(scoreBox.frame, cardPosition)) {
            //assign to that group
            //TODO:scorebox highlight color
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
    
//    for (int i=0;i<[self.cardsDatas count];i++) {
//        NSMutableArray *data = [self.cardsDatas objectAtIndex:i];
//        for (NSString *path in data) {
//            NSLog(@"carousel %d, cardDataPath = %@",i,path);
//        }
//    }

    if (cardLeft == 0) {
        [self toNextStage];
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
    if (carousel.type == iCarouselTypeCoverFlow2) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180.0f, 180.0f)];
    }else{
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280.0f, 280.0f)];
    }
        //view.backgroundColor = [UIColor blackColor];
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
    label.text = [NSString stringWithFormat:@"left %d",[[self.cardsDatas objectAtIndex:NOT_SORTED] count]];
    
    //NSError *error;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    card.imageView.image = [UIImage imageWithContentsOfFile:[documentPath stringByAppendingPathComponent:[item objectAtIndex:index]]];
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
    //NSLog(@"index = %d",index);
    if (index % 3 == 0) {
        [self setLittleManAnimation];
    }
    return NO;
}

#pragma mark - SettingView Controller Protocol
-(void)settingisDone:(NSArray *)settingDatas{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.labelDatas = [NSArray arrayWithArray:settingDatas];
    
    //save label datas in Temporary Dir
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), LABEL_FILENAME];
	NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:outputPath contents:nil attributes:nil];
    NSDictionary *data = [self.labelDatas objectAtIndex:0];
    [data writeToFile:outputPath atomically:YES];
}

-(void)settingisCanceled{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)start:(id)sender{
    UIImageView *beginView = (UIImageView*)[self.view viewWithTag:maskViewTag];
    [UIView animateWithDuration:0.5
                     animations:^{
                         beginView.transform = CGAffineTransformMakeTranslation(1000, 0);
                     }
                     completion:^(BOOL finished){
                         [beginView removeFromSuperview];
                         self.view.userInteractionEnabled = YES;
                         iCarousel *unsortedCards = [self.cardsViews objectAtIndex:NOT_SORTED];
                         [unsortedCards scrollByNumberOfItems:10 duration:1.25];
                     }
     ];
}

#pragma mark - Transition to next stage sorting

-(void)toNextStage{
    
    __block iCarousel *carousel;
    
//    for (int i = 1; i<[self.cardsViews count]; i++) {
//        iCarousel *scrollCarousel = [self.cardsViews objectAtIndex:i];
//        [scrollCarousel scrollByNumberOfItems:-100 duration:1.5];
//    }
    [UIView animateWithDuration:0.6
                          delay:2
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         //collect cards
                         for (int i = 1; i<[self.cardsViews count]; i++) {
                             carousel = [self.cardsViews objectAtIndex:i];
                             carousel.type = iCarouselTypeLinear;
                         }
                     }
                     completion:^(BOOL finished){
                         carousel = nil;
                         [self moveFirstAndLastCards];
                     }
     ];

}

-(void)moveFirstAndLastCards{
    iCarousel *carousel = [self.cardsViews objectAtIndex:1];
    
    //create curve path
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:carousel.center];
    [movePath addQuadCurveToPoint:CGPointMake(0, -200)
                     controlPoint:CGPointMake(20, carousel.center.y + 10)];
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = movePath.CGPath;
    moveAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    moveAnim.duration = 0.8;
    [carousel.layer addAnimation:moveAnim forKey:@"position"];
    carousel.center = CGPointMake(0, -200);
    
    iCarousel *carousel_2 = [self.cardsViews objectAtIndex:3];
    movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:carousel_2.center];
    [movePath addQuadCurveToPoint:CGPointMake(0, 1000) controlPoint:CGPointMake(20, carousel_2.center.y-10)];
    moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = movePath.CGPath;
    moveAnim.duration = 0.9;
    [carousel_2.layer addAnimation:moveAnim forKey:@"postition"];
    carousel_2.center = CGPointMake(0, 968);
    
    carousel = nil;
    carousel_2 = nil;
    
    [self performSelector:@selector(moveLabels) withObject:nil afterDelay:1];
}

-(void)moveLabels{
    LabelView *firstLabel = [self.labelViews objectAtIndex:0];
    LabelView *thirdLabel = [self.labelViews objectAtIndex:2];
    
    UIImageView *middleLabel_1 = [self.middleLables objectAtIndex:0];
    UIImageView *middleLabel_2 = [self.middleLables objectAtIndex:2];
    
    [UIView animateWithDuration:0.8
                     animations:^{
                         firstLabel.transform = CGAffineTransformMakeTranslation(0, -260);
                         thirdLabel.transform = CGAffineTransformMakeTranslation(0, 260);
                         
                         middleLabel_1.transform = CGAffineTransformMakeTranslation(0, -260);
                         middleLabel_2.transform = CGAffineTransformMakeTranslation(0, 260);
                     }
                     completion:^(BOOL finished){
                         [self moveMiddleCardsAndToNext];
                     }
     ];
}

-(void)moveMiddleCardsAndToNext{
    iCarousel *carousel = [self.cardsViews objectAtIndex:2];
    [UIView animateWithDuration:0.8
                     animations:^{
                         carousel.transform = CGAffineTransformMakeTranslation(-1000, 0);
                     }
                     completion:^(BOOL finished){
                         SecondQsortViewController *newController = [[SecondQsortViewController alloc] init];
                        newController.currentIndexs = [NSArray arrayWithObjects:[NSNumber numberWithInteger:((iCarousel*)[self.cardsViews objectAtIndex:1]).currentItemIndex],[NSNumber numberWithInteger:((iCarousel*)[self.cardsViews objectAtIndex:2]).currentItemIndex],[NSNumber numberWithInteger:((iCarousel*)[self.cardsViews objectAtIndex:3]).currentItemIndex], nil];
//                         for (NSNumber *index in newController.currentIndexs) {
//                             NSLog(@"currentIndex = %d",index.integerValue);
//                         }
                         [self.cardsDatas removeObjectAtIndex:0];
                         [newController setUpDatas:self.cardsDatas label:self.labelDatas];
                         [self.navigationController pushViewController:newController animated:NO];
                         
                         //clean all datas
                         for (UIView *card in self.cardsViews) {
                             [card removeFromSuperview];
                         };
                         for (UIView *label in self.labelViews) {
                             [label removeFromSuperview];
                         }
                         self.allCards = nil;
                         self.cardsDatas = nil;
                         self.cardsViews = nil;
                         self.labelDatas = nil;
                         self.labelViews = nil;
                     }
     ];
}

#pragma mark - animation
-(void)setLittleManAnimation{
    //NSLog(@"setLittleManAnimation");
    int leftCards = [[self.cardsDatas objectAtIndex:NOT_SORTED] count];
    //CGFloat positionX = ((CGFloat)([self.allCards count]-leftCards))/((CGFloat)[self.allCards count])*1024*0.5;
    //NSLog(@"%f",positionX);
    [self.view addSubview:self.littleMan];
    [self.littleMan setLabel:[NSString stringWithFormat:@"%d left!",leftCards]];
    //[self.littleMan setPositionX:positionX];
    [self.littleMan action];
}
@end
