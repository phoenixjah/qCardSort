//
//  SettingViewController.m
//  qsort card
//
//  Created by Chia Lin on 13/5/3.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import "SettingViewController.h"
#import "Constant.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,strong) UIButton *goBtn;
@property (nonatomic,strong) UIButton *addNewBtn;
@property (nonatomic,strong) UIButton *editCellBtn;
@end

@implementation SettingViewController
@synthesize settingViewCell;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view = self.tableView;
    
    self.datas = [NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithCapacity:2]];
    [self setAddAndEditBtns];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.datas count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"SettingViewTableCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SettingViewTableCell" owner:self options:nil];
        cell = settingViewCell;
        self.settingViewCell = nil;
    }
    UITextField *from = (UITextField*)[cell viewWithTag:1];
    UITextField *to = (UITextField*)[cell viewWithTag:2];
    
    NSDictionary *data = (NSDictionary*)[self.datas objectAtIndex:indexPath.row];
    from.text = [data objectForKey:KEY_FROM];
    to.text = [data objectForKey:KEY_TO];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 165;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"did you select me?");
}

#pragma mark - UITextField Delegate Function
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //When cell is more than 2, keyboard will overlap the textField
    if ([self.datas count]>2) {
        UITableViewCell *cell = (UITableViewCell*)[[textField superview] superview];
        [self.tableView setContentOffset:CGPointMake(0, cell.frame.size.height) animated:YES];
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    UITableViewCell *cell = (UITableViewCell*)[[textField superview] superview];
    NSMutableDictionary *data = [self.datas objectAtIndex:[self.tableView indexPathForCell:cell].row];
    if (textField.tag == 1) {
        [data setObject:textField.text forKey:KEY_FROM];
        //TODO:go to the other textField if it is blank
    }else if(textField.tag == 2){
        [data setObject:textField.text forKey:KEY_TO];
        //TODO:go to the other textField if it is blank
    }
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    //if user already fill at least first pair of ADJ, sorting could begin
    NSString *fromAdj = [[self.datas objectAtIndex:0] objectForKey:KEY_FROM];
    NSString *toAdj = [[self.datas objectAtIndex:0] objectForKey:KEY_TO];
    if ([fromAdj length]>0 && [toAdj length]>0) {
        self.goBtn.userInteractionEnabled = YES;
    }else{
        self.goBtn.userInteractionEnabled = NO;
    }
}

#pragma mark - Edit and Add btn
-(UIButton*)addNewBtn{
    if (_addNewBtn == nil) {
        _addNewBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [_addNewBtn addTarget:self action:@selector(addNewExperiment:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addNewBtn;
}

-(UIButton*)editCellBtn{
    if (_editCellBtn == nil) {
        _editCellBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _editCellBtn.frame = CGRectMake(500, 20, 100, 20);
        [_editCellBtn setTitle:@"Edit" forState:UIControlStateNormal];
        [_editCellBtn addTarget:self action:@selector(setCellEditable:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editCellBtn;
}

-(UIButton*)goBtn{
    if (_goBtn == nil) {
        _goBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _goBtn.frame = CGRectMake(500, 600, 100, 50);
        [_goBtn setTitle:@"Go" forState:UIControlStateNormal];
        _goBtn.userInteractionEnabled = NO;
        [_goBtn addTarget:self action:@selector(startSorting:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goBtn;
}

-(void)setAddAndEditBtns{
    //Setup Add Btn
    [self.view addSubview:self.addNewBtn];
    
    //Setup Edit Btn
    [self.view addSubview:self.editCellBtn];
    
    //Setup Go Btn
    [self.view addSubview:self.goBtn];
}

-(void)addNewExperiment:(id)sender{
    NSMutableDictionary *newData = [NSMutableDictionary dictionaryWithCapacity:2];
    //[self.tableView beginUpdates];
    [self.datas addObject:newData];
    [self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.datas count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    //[self.tableView endUpdates];
}

-(void)setCellEditable:(id)sender{
    //TODO: change the Edit btn image according to editable or not
    if (self.tableView.editing == NO) {
        [self.tableView setEditing:YES animated:YES];
        self.addNewBtn.hidden = YES;
        self.goBtn.hidden = YES;
        //self.editCellBtn;
    }else{
        [self.tableView setEditing:NO animated:YES];
        self.addNewBtn.hidden = NO;
        self.goBtn.hidden = NO;
        //self.editCellBtn;
    }
}

-(void)startSorting:(id)sender{
    //pass the setting data to super view controller
    [self.settingDelegate settingisDone:self.datas];
}
#pragma mark - UITableView Edit Function
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //delete functions
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.datas removeObjectAtIndex:indexPath.row];
    [self.tableView endUpdates];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    [self.tableView setEditing:NO animated:YES];
    //manage data
    NSMutableDictionary *yubi = [self.datas objectAtIndex:sourceIndexPath.row];
    [self.datas replaceObjectAtIndex:sourceIndexPath.row  withObject:[self.datas objectAtIndex:destinationIndexPath.row]];
    [self.datas insertObject:yubi atIndex:destinationIndexPath.row];
}

//-(NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
//    
//    //the moving element can only move to second place at most, as top is reserved for profile cell
//    if (proposedDestinationIndexPath.row == 0) {
//        return [NSIndexPath indexPathForRow:1 inSection:proposedDestinationIndexPath.section];
//    }else{
//        return proposedDestinationIndexPath;
//    }
//    
//}
@end
