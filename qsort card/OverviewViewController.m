//
//  OverviewViewController.m
//  qsort card
//
//  Created by Chia Lin on 13/5/16.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import "OverviewViewController.h"
#import "CardView.h"
#import "iCarousel.h"
#import <MessageUI/MessageUI.h>

#define FILENAME @"Cards.plist"
@interface OverviewViewController ()<MFMailComposeViewControllerDelegate,iCarouselDataSource,iCarouselDelegate,CardIsSorting,UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic) CGFloat ghost;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) UIButton *doneBtn;
@property (nonatomic,strong) UIButton *emailBtn;
@property (nonatomic,strong) UIButton *nextBtn;
@end

@implementation OverviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    //display btns
    self.emailBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.emailBtn.frame = CGRectMake(-50, 500, 100, 50);
    [self.emailBtn setTitle:@"E-Mail" forState:UIControlStateNormal];
    [self.emailBtn addTarget:self action:@selector(sendMail:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.nextBtn.frame = CGRectMake(-150, 600, 100, 50);
    [self.nextBtn setTitle:@"To Next" forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(toNext:) forControlEvents:UIControlEventTouchUpInside];
    
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.doneBtn.frame = CGRectMake(-100, 500, 100, 50);
    [self.doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(fuckFinished:) forControlEvents:UIControlEventTouchUpInside];
    
    //TODO:setup pageControl
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 300, 20, 100)];
    [self.view addSubview:self.pageControl];
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 1;
    self.pageControl.backgroundColor = [UIColor blackColor];
    
    self.ghost = 1;
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
#pragma mark - init datas and views method
-(UIScrollView*)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        _scrollView.contentSize = CGSizeMake(1024, 768*3);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}
-(void)setUpDatas:(NSArray *)cardDatas label:(NSArray *)labelDatas{
    self.labelDatas = [NSArray arrayWithArray:labelDatas];
    self.cardsDatas = [NSMutableArray arrayWithArray:cardDatas];
    //        for (int i=0;i<[self.cardsDatas count];i++) {
    //            NSMutableArray *data = [self.cardsDatas objectAtIndex:i];
    //            for (NSString *path in data) {
    //                NSLog(@"carousel %d, cardDataPath = %@",i,path);
    //            }
    //        }
}
-(void)setupViews{
    self.cardsViews = [NSMutableArray array];
    
    for (int i=0; i<9; i++) {
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(1024, 30+i*250, 1024, 100)];
        carousel.type = iCarouselTypeInvertedTimeMachine;
        carousel.tag = i;
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

    //move it out
    for (iCarousel *cardView in self.cardsViews) {
        [UIView animateWithDuration:0.5
                              delay:1
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             cardView.transform = CGAffineTransformMakeTranslation(-1124, 0);
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.35
                                                   delay:0.1 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  cardView.transform = CGAffineTransformMakeTranslation(-1000, 0);
                                              }
                                              completion:^(BOOL finished){
                                                  //spread it out
                                                  [UIView animateWithDuration:0.5
                                                                   animations:^{
                                                  cardView.type = iCarouselTypeCoverFlow2;
                                                                       self.ghost = 1.8;
                                                  //self.timer = [NSTimer scheduledTimerWithTimeInterval:0.0005 target:self selector:@selector(increaseGhost:) userInfo:nil repeats:YES];
//                                                  [self.timer fire];
//                                                  
//                                                  mediumCards = nil;
                                                                   }
                                                   ];
                                              }
                              ];
                         }
         ];
    }
}

-(void)increaseGhost:(NSTimer*)timer{
    //NSLog(@"ghost = %f",self.ghost);
    if (self.ghost > 2) {
        self.ghost = 2;
        [self.timer invalidate];
        self.timer = nil;
        [((iCarousel*)[self.cardsViews objectAtIndex:1]) reloadData];
        //[((iCarousel*)[self.cardsViews objectAtIndex:1]) scrollByNumberOfItems:1 duration:0.2];
    }else if(self.ghost > 1.8){
        self.ghost = self.ghost + 0.1;
        [((iCarousel*)[self.cardsViews objectAtIndex:1]) reloadData];
    }else{
        self.ghost = self.ghost + 0.1;
        [((iCarousel*)[self.cardsViews objectAtIndex:1]) reloadData];
    }
}

-(void)setScrollViewOffset:(CGPoint)offset{
    self.scrollView.contentOffset = offset;
}
#pragma mark - CardIsSorting Delegate Function
-(void)isMoving:(CardView *)card{
    
    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
    int sortedIndex = 0;
    
    [self.scrollView bringSubviewToFront:[self.cardsViews objectAtIndex:card.tag]];
    
    //    NSArray *nowOnDisplay = [self.sortedGroup indexesForVisibleItems];
    //    for (NSNumber *i in nowOnDisplay) {
    //        NSLog(@"visible index = %d",i.integerValue);
    //    }
    for (int i = 0;i<[self.cardsViews count];i++) {
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
    
    if (sortedToGroup == card.tag) {
        //put it back to its origin position
        [UIView animateWithDuration:0.3
                         animations:^{
                             card.frame = [card superview].frame;
                         }
         ];
    }else{
        [self moveCard:card fromGroup:card.tag toGroup:sortedToGroup];
        card.tag = sortedToGroup;
    }
    
    //NSLog(@"unsorted cards %d",self.unsortedCards);
    //NSLog(@"the card sorted to group %d",sortedToGroup);
}

-(void)moveCard:(CardView*)card fromGroup:(int)from toGroup:(int)to{
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
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180.0f, 180.0f)];

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
            if (_carousel.type == iCarouselTypeInvertedTimeMachine) {
                return 0.2;
            }else{
                return value;
            }
        }
        case iCarouselOptionArc:{
            //NSLog(@"self.spread %f",self.ghost.frame.origin.x);
            return value*0.6;
        }
        case iCarouselOptionRadius:
        {
            return value*2;
        }
        case iCarouselOptionTilt:{
            return value*0.75;
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
    if ([[self.view subviews] containsObject:self.doneBtn] == YES) {
                [UIView animateWithDuration:0.5
                         animations:^{
                             self.doneBtn.transform = CGAffineTransformMakeTranslation(-100, 0);
                         }
                                 completion:^(BOOL finished){
                                     [self.doneBtn removeFromSuperview];

                                 }
         ];
    }

    return NO;
}

#pragma mark - Ending Function
-(void)sendMail:(UIButton*)btn{
    // Email Subject
    NSString *emailTitle = @"Sorting Result";
    // TODO: Email Content
    NSString *messageBody = @"iOS programming is so fun!";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    
    [mc setMessageBody:messageBody isHTML:NO];

    //TODO:attach file
//    NSString *filePath;
//    NSData *data = [NSData dataWithContentsOfFile:filePath];
    //[mc addAttachmentData:data mimeType:@"text/plain" fileName:@"result.txt"];
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)toNext:(UIButton*)btn{
    UIImageView *thankView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thanks.png"]];
    thankView.alpha = 0;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.view.transform = CGAffineTransformMakeScale(0.0, 0.0);
                     }
                     completion:^(BOOL finished){
                         [UIView transitionFromView:self.view
                                             toView:thankView
                                           duration:0
                                            options:UIViewAnimationOptionBeginFromCurrentState completion:^(BOOL finished){
                                                
                                                self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                [UIView animateWithDuration:1
                                                                 animations:^{
                                                                     thankView.alpha = 1.0;
                                                }
                                                 ];
                                            }
                          ];
                     }
     ];
}

-(void)fuckFinished:(UIButton*)btn{
    self.scrollView.userInteractionEnabled = NO;
    UIImageView *mask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mask.png"]];
    mask.alpha = 0.0;
    [self.view addSubview:mask];
    
    //write sorting result to file
    [self writeResult];
    //[self.view addSubview:self.emailBtn];
    [self.view addSubview:self.nextBtn];
    [UIView transitionFromView:self.doneBtn
                        toView:self.emailBtn
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:nil
     ];
    [UIView animateWithDuration:0.5
                     animations:^{
                         for (iCarousel *cards in self.cardsViews) {
                             cards.type = iCarouselTypeLinear;
                         }

                         self.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
                         mask.alpha = 0.8;
                         self.nextBtn.transform = CGAffineTransformMakeTranslation(100, 0);
                     }
                     completion:^(BOOL finished){
                         self.doneBtn = nil;
                     }
     ];
}
-(void)writeResult{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[documentPath stringByAppendingPathComponent:FILENAME]];
    for (int i=0;i<[self.cardsDatas count];i++){
        NSArray *cards = [self.cardsDatas objectAtIndex:i];
        for (NSString *group in cards) {
            [dictionary setValue:[NSString stringWithFormat:@"%d",i] forKey:group];
        }
    }
    
    [dictionary writeToFile:[documentPath stringByAppendingPathComponent:FILENAME] atomically:YES];
    dictionary = nil;
}
#pragma mark - scrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([[self.view subviews] containsObject:self.doneBtn] == NO) {
        [self.view addSubview:self.doneBtn];
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.doneBtn.transform = CGAffineTransformMakeTranslation(100, 0);
        }
         ];
    }
}
@end
