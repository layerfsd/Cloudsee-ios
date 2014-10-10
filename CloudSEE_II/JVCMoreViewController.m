//
//  JVCMoreViewController.m
//  JVCEditDevice
//  更多界面
//  Created by chenzhenyang on 14-9-24.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCMoreViewController.h"
#import "JVCMoreUserCell.h"
#import "JVCMoreSettingHelper.h"
#import "JVCMoreSettingModel.h"
#import "JVCMoreContentCell.h"
//账号
#import "JVCAccountHelper.h"
//tableview的选中事件
#import "JVCApHelpViewController.h"
#import "JVCMoreUserSettingViewController.h"
//登录
#import "JVCLoginViewController.h"

#import "JVCDataBaseHelper.h"

static const int CELLHEIGHT_USERHEADER = 120;//账号名称以及头像的cell高度
static const int CELLHEIGHT_CONTENTH = 44;   //里面内容的cell高度
static const int CELLHEIGHT_HEADSECTION = 20;   //section的高度
static const int KUserLoginOutState_Success= 0;   //账号注册成功

@interface JVCMoreViewController ()
{
    UITableView *_tableView;
    
    NSMutableArray *arrayList;
}

@end

@implementation JVCMoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        UITabBarItem *moreItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"更多", nil) image:nil tag:1];
        [moreItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_more_select.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_more_unselect.png"]];
        self.tabBarItem = moreItem;
        [moreItem release];
        
        self.title = self.tabBarItem.title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    
    //初始化arrayList
    arrayList = [[NSMutableArray alloc] initWithCapacity:10];
    [arrayList addObjectsFromArray:[[JVCMoreSettingHelper shareDataBaseHelper]getMoreSettingList]];
    
    //初始化tableview
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
}

#pragma mark  tableview 的代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return CELLHEIGHT_USERHEADER;
        
    }
    return CELLHEIGHT_CONTENTH;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  
    return arrayList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0||section ==1) {
        
        return 0;
    }
    
    return CELLHEIGHT_HEADSECTION;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int height = 0.0;
    if (section !=0||section !=1) {
        height =  CELLHEIGHT_HEADSECTION;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.width,height)];
    view.backgroundColor = [UIColor clearColor];
    //横线
    UIImage *imgLine = [UIImage imageNamed:@"mor_line.png"];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.width- imgLine.size.width)/2.0, imgLine.size.height, imgLine.size.width, imgLine.size.height)];
    lineImageView.image = imgLine;
    [view addSubview:lineImageView];
    [lineImageView release];
    
    return [view autorelease];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 1;
        
    }

    NSMutableArray *array = [arrayList objectAtIndex:section];
    
    return array.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {//用户信息
        
        static NSString *cellIndentify = @"cellUserIndentifiy";
        
        JVCMoreUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        
        if (cell == nil) {
            
            cell = [[[JVCMoreUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell initMoreCellContentView];
        
        return cell;
        
    }else  {
        
        static NSString *cellIndentify = @"cellIndentifiy";
        
        JVCMoreContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
        
        if (cell == nil) {
            
            cell = [[[JVCMoreContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify] autorelease];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        for (UIView *viewContent in cell.contentView.subviews) {
            
            [viewContent removeFromSuperview];
        }
        
        NSMutableArray *arraySection = [arrayList objectAtIndex:indexPath.section];
        JVCMoreSettingModel *cellModel = [arraySection objectAtIndex:indexPath.row];
       
        if (!cellModel.bBtnState) {//正常显示
            
            [cell initContentCells:cellModel];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }else{//按钮显示
        
        UIImage *iamgeBtn = [UIImage imageNamed:@"mor_logOut.png"];
        UIButton *btnLoginOut = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLoginOut.frame =CGRectMake((self.view.width - iamgeBtn.size.width)/2.0, (cell.height- iamgeBtn.size.height)/2.0, iamgeBtn.size.width, iamgeBtn.size.height);
        [btnLoginOut addTarget:self action:@selector(userLoginOut) forControlEvents:UIControlEventTouchUpInside];
        [btnLoginOut setTitle:@"注销" forState:UIControlStateNormal];
        [btnLoginOut setBackgroundImage:iamgeBtn forState:UIControlStateNormal];
        [cell.contentView addSubview:btnLoginOut];
            
            
        }
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {//账号信息
        
        JVCMoreUserSettingViewController *moreUserSettingVC = [[JVCMoreUserSettingViewController alloc] init] ;
        [self.navigationController pushViewController:moreUserSettingVC animated:YES];
        moreUserSettingVC.hidesBottomBarWhenPushed = YES;
        [moreUserSettingVC release];
    }
    
    if (indexPath.section == 1 ) {//
        
        if (indexPath.row == 0) {//帮助
            
            JVCApHelpViewController *apHelper = [[JVCApHelpViewController alloc] init] ;
            [self.navigationController pushViewController:apHelper animated:YES];
            apHelper.hidesBottomBarWhenPushed = YES;
            [apHelper release];
        }
    }else if(indexPath.section == 3)
    {
        if (indexPath.row == 0) {//打开评论
            
            NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",kAPPIDNUM];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:str]];
        }
    }
}

/**
 *  账号注销
 */
- (void)userLoginOut
{
    [[JVCAlertHelper shareAlertHelper]alertShowToastOnWindow];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int reuslt = 0 ;// [[JVCAccountHelper sharedJVCAccountHelper] UserLogout];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            DDLogVerbose(@"注销收到的返回值=%d",reuslt);
            
            [[JVCAlertHelper shareAlertHelper]alertHidenToastOnWindow];

            if (KUserLoginOutState_Success == reuslt) {//成功,弹出注册界面
                
                JVCLoginViewController *loginVC = [[JVCLoginViewController alloc] init];
                UINavigationController *navLoginVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [self presentModalViewController:navLoginVC animated:YES];
                [loginVC release];
                [navLoginVC release];
                
                //并且把秘密置换成功
                [[JVCDataBaseHelper shareDataBaseHelper] updateUserAutoLoginStateWithUserName:kkUserName loginState:kLoginStateOFF];
                
            }else{//失败
            
                [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"注销失败"];
            }
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_tableView release];
    _tableView = nil;
    
    [arrayList release];
    arrayList = nil;
    
    [super dealloc];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
