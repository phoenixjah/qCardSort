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
#import "LabelView.h"
#import "Constant.h"
#import <MessageUI/MessageUI.h>

#define ATTACHED @"result.txt"
#define BACKGROUND_TAG 3

@interface OverviewViewController ()<MFMailComposeViewControllerDelegate,iCarouselDataSource,iCarouselDelegate,CardIsSorting,UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIButton *doneBtn;
@property (nonatomic,strong) UIButton *emailBtn;
@property (nonatomic,strong) UIButton *nextBtn;
@property (nonatomic,strong) UIImageView *selectedImage;
@property NSInteger selectedCard;
@end

@implementation OverviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    
    //display btns
    self.emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.emailBtn.frame = CGRectMake(500, 300, 190, 190);
    [self.emailBtn setImage:[UIImage imageNamed:@"mail_btn.png"] forState:UIControlStateNormal];
    [self.emailBtn addTarget:self action:@selector(sendMail:) forControlEvents:UIControlEventTouchUpInside];
        
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneBtn.frame = CGRectMake(1024, 50, 100, 100);
    [self.doneBtn setImage:[UIImage imageNamed:@"done_btn.png"] forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(fuckFinished:) forControlEvents:UIControlEventTouchUpInside];
    
    //TODO:setup pageControl
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(530, 0, 68, 2304)];
    background.image = [UIImage imageNamed:@"labels_all.png"];
    background.tag = BACKGROUND_TAG;
    [self.scrollView addSubview:background];
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
-(UIImageView*)selectedImage{
    if (_selectedImage == nil) {
        _selectedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_long.png"]];
    }
    return _selectedImage;
}
-(UIButton*)nextBtn{
    if (_nextBtn == nil) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.frame = CGRectMake(650, 300, 190, 190);
//        if (self.stage<3) {
//            [_nextBtn setImage:[UIImage imageNamed:@"next_btn.png"] forState:UIControlStateNormal];
//        }else{
            [_nextBtn setImage:[UIImage imageNamed:@"home_btn.png"] forState:UIControlStateNormal];
//        }
        [_nextBtn addTarget:self action:@selector(toNext:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _nextBtn;
}
#pragma mark - init datas and views method
-(UIScrollView*)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        _scrollView.contentSize = CGSizeMake(1024, 768*3);
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}
-(void)setUpDatas:(NSArray *)cardDatas{

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
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(1024, 85+i*260, 1024, 100)];
        carousel.type = iCarouselTypeCoverFlow;
        carousel.tag = i;
        carousel.delegate = self;
        carousel.dataSource = self;
        carousel.centerItemWhenSelected = NO;
        //carousel.contentOffset = CGSizeMake(-200, 0);
//        carousel.backgroundColor = [UIColor blackColor];
        [self.cardsViews addObject:carousel];
        
    }
    for (iCarousel *cards in self.cardsViews) {
        [self.scrollView addSubview:cards];
    }
    //TODO: setup labelViews
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), LABEL_FILENAME];
    NSDictionary *data = [NSDictionary dictionaryWithDictionary:([NSArray arrayWithContentsOfFile: outputPath][self.stage])];
    self.labelViews = [NSMutableArray array];


    for (int i =0; i<3; i++) {
        LabelView *label = [[LabelView alloc] initWithFrame:CGRectMake(450, 20+i*768, 140, 50)];
        //label.backgroundColor = [UIColor blackColor];
        //label.label.text = [NSString stringWithFormat:@"%d",i+1];
        [self.labelViews addObject:label];
        [self.scrollView addSubview:label];
//        if (i%3==0) {
//            UILabel *groupTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20+i*250, 100, 50)];
//            groupTitle.text = [NSString stringWithFormat:@"%@",[self.labelDatas objectAtIndex:i%3]];
//            [self.scrollView addSubview:groupTitle];
//        }

    }
    ((LabelView*)[self.labelViews objectAtIndex:0]).label.text = [NSString stringWithFormat:@"%@",[data objectForKey:KEY_FROM]];
    ((LabelView*)[self.labelViews objectAtIndex:1]).label.text = @"Medium";
    ((LabelView*)[self.labelViews objectAtIndex:2]).label.text = [NSString stringWithFormat:@"%@",[data objectForKey:KEY_TO]];


    [self openAnimation];
}

-(void)openAnimation{

    UIImageView *background = (UIImageView*)[self.scrollView viewWithTag:BACKGROUND_TAG];
    //move it out
    for (iCarousel *cardView in self.cardsViews) {
        [UIView animateWithDuration:0.5
                              delay:1
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             background.transform = CGAffineTransformMakeTranslation(-520, 0);
                             cardView.transform = CGAffineTransformMakeTranslation(-1124, 0);
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.35
                                                   delay:0.1
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:^{
                                                  cardView.transform = CGAffineTransformMakeTranslation(-1000, 0);
                                              }
                                              completion:^(BOOL finished){
                                                  //spread it out
                                                  [UIView animateWithDuration:0.5
                                                                   animations:^{
                                                //cardView.type = iCarouselTypeCoverFlow2;
                                                                       cardView.type = iCarouselTypeLinear;
                                                                   }
                                                                   completion:^(BOOL finished){
                                                                       [cardView scrollByNumberOfItems:[cardView numberOfItems]/2
                                                                                              duration:0.5*[cardView numberOfItems]];
                                                                   }
                                                   ];
                                              }
                              ];
                         }
         ];
    }
}


-(void)setScrollViewOffset:(CGPoint)offset{
    self.scrollView.contentOffset = offset;
}
#pragma mark - CardIsSorting Delegate Function
-(void)isMoving:(CardView *)card{
    
    CGRect cardPosition = [card convertRect:card.bounds toView:self.view];
    
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
    NSString *imagePath = [NSString stringWithFormat:@"%@",[oldDatas objectAtIndex:self.selectedCard]];
    //    if ([newDatas count]>0) {
    //        index = index-1;
    //    }
    [newDatas insertObject:imagePath atIndex:index];
    [newGroupView insertItemAtIndex:index animated:YES];
    //[newGroupView scrollToItemAtIndex:index animated:YES];
    //NSLog(@"insert new item succefully");
    
    //remove it from old group
    if (oldGroupView.numberOfItems > 0) {
        //NSInteger index = oldGroupView.currentItemIndex;
        NSInteger index = self.selectedCard;
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
    carouselDatas = [self.cardsDatas objectAtIndex:carousel.tag];
    return [carouselDatas count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    CardView *card = nil;
    
    
    //NSLog(@"carousel number %d",carousel.tag);
    //create new view if no view is available for recycling
    //    if (view == nil)
    //    {
    view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150.0f, 150.0f)];

    view.contentMode = UIViewContentModeCenter;
    
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
    
    item = [self.cardsDatas objectAtIndex:carousel.tag];
    
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
            if (_carousel.type == iCarouselTypeLinear) {
                return 1.5;
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
            if (_carousel.type == iCarouselTypeInvertedTimeMachine) {
                return 1.0;
            }else{
                return 0.75;
            }
        }
        case iCarouselOptionFadeMin:{
            return -1.0;
        }
        case iCarouselOptionFadeRange:
            return 2;
        
        default:
        {
            return value;
        }
    }
}

-(BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index{
    
    self.selectedCard = index;
    if ([[self.view subviews] containsObject:self.doneBtn] == YES) {
                [UIView animateWithDuration:0.5
                         animations:^{
                             self.doneBtn.transform = CGAffineTransformMakeTranslation(100, 0);
                         }
                                 completion:^(BOOL finished){
                                     [self.doneBtn removeFromSuperview];
                                 }
         ];
    }

    return YES;
}

#pragma mark - Ending Function
-(void)sendMail:(UIButton*)btn{
    // Email Subject
    NSString *emailTitle = @"Sorting Result";
    // TODO: Email Content
    NSString *messageBody = @"Name:";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    
    [mc setMessageBody:messageBody isHTML:NO];

    NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), ATTACHED];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:filePath])
	{
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [mc addAttachmentData:data mimeType:@"text/plain" fileName:ATTACHED];
	}else{
        //TODO:file does not exist
    }

    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:{
            //NSLog(@"Mail sent");
            //Delete the result file
            NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), ATTACHED];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            if ([fileManager removeItemAtPath:outputPath error:&error] == NO){
                    //Error - handle if required
                NSLog(@"remove attached file error");
            }
            break;
        }
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

    [UIView animateWithDuration:1.0
                     animations:^{
                         self.view.transform = CGAffineTransformMakeScale(0.0, 0.0);
                     }
                     completion:^(BOOL finished){
                         self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         [self.navigationController popToRootViewControllerAnimated:NO];
                         self.nextBtn = nil;
                         self.doneBtn = nil;
                         self.emailBtn = nil;
                         self.selectedImage = nil;
                         
                         self.cardsViews = nil;
                         self.cardsDatas = nil;
                         self.labelViews = nil;
                     }
     ];
}

-(void)fuckFinished:(UIButton*)btn{
    self.scrollView.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         for (iCarousel *cards in self.cardsViews) {
                             cards.type = iCarouselTypeLinear;
                         }
                         
                         self.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
                         self.nextBtn.transform = CGAffineTransformMakeTranslation(100, 0);
                     }
                     completion:^(BOOL finished){
                         self.doneBtn = nil;
                     }
     ];

    UIImageView *mask = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thanks.png"]];
    mask.alpha = 0.9;
    
    //write sorting result to file
    [self writeResult];

    [UIView transitionFromView:self.doneBtn
                        toView:mask
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL finished){
                        [self.doneBtn removeFromSuperview];
                        [self.view addSubview:self.nextBtn];
//                        if (self.stage == 3) {
                            [self.view addSubview:self.emailBtn];
//                        }
                    }
     ];
}
-(void)writeResult{
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingPathComponent:FILENAME]];
    for (int i=0;i<[self.cardsDatas count];i++){
        NSArray *cards = [self.cardsDatas objectAtIndex:i];
        for (NSString *group in cards) {
            [dictionary setValue:[NSString stringWithFormat:@"%d",i+1] forKey:group];
        }
    }
    
    //TODO:delete this when correctness is for sure, there is no need to keep this plist
    [dictionary writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:FILENAME] atomically:YES];

    //prepare the attached file
    NSString *output = [NSString stringWithFormat:@"Filename/Results\t%@(1)-%@(9)\n",((LabelView*)self.labelViews[0]).label.text,((LabelView*)self.labelViews[2]).label.text];
    for (NSString *key in [dictionary allKeys]) {
        //NSLog(@"%@ -> %@",key,[dictionary valueForKey:key]);
        output = [output stringByAppendingFormat:@"%@\t%@\n",key,[dictionary valueForKey:key]];
       //NSLog(@"%@",output);
    }
    
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), ATTACHED];
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:outputPath])
	{
        [fileManager createFileAtPath:outputPath contents:nil attributes:nil];
        [output writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}else{
        //append file
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:outputPath];
        [handle truncateFileAtOffset:[handle seekToEndOfFile]];
        [handle writeData:[output dataUsingEncoding:NSUTF8StringEncoding]];
    }

    dictionary = nil;
}
#pragma mark - scrollView Delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([[self.view subviews] containsObject:self.doneBtn] == NO) {
        [self.view addSubview:self.doneBtn];
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.doneBtn.transform = CGAffineTransformMakeTranslation(-100, 0);
        }
         ];
    }
}
@end
