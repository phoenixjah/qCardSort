//
//  SettingViewController.h
//  qsort card
//
//  Created by Chia Lin on 13/5/3.
//  Copyright (c) 2013年 Chia Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GetSettingProtocol <NSObject>
-(void)settingisDone:(NSArray*)settingDatas;
-(void)settingisCanceled;
@end

@interface SettingViewController : UIViewController
@property (nonatomic,assign) IBOutlet UITableViewCell *settingViewCell;
@property (nonatomic,weak) id <GetSettingProtocol> settingDelegate;
@end
