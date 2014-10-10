//
//  JVCEditChannelInfoTableViewController.m
//  CloudSEE_II
//
//  Created by Yanghu on 10/9/14.
//  Copyright (c) 2014 Yanghu. All rights reserved.
//

#import "JVCEditChannelInfoTableViewController.h"
#import "JVCDeviceModel.h"
#import "JVCChannelModel.h"
#import "JVCDeviceHelper.h"
#import "JVCChannelScourseHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "JVCRGBHelper.h"
#import "JVCRGBColorMacro.h"
#import "JVCPredicateHelper.h"

@interface JVCEditChannelInfoTableViewController ()
{
    NSMutableArray *arrayChannelsList;//通道数组
    
    UIView *modifyChannelNickNameView;
    
    JVCChannelModel *channelModel;
    
    UITableView *tableViewChannels;
    
    BOOL bShowEditChannelNickNameValue;//是否显示编辑昵称界面
    
    UITextField *channelNickNameField;
    
}

@end

@implementation JVCEditChannelInfoTableViewController
@synthesize YstNum;

static const    int     kOffSet_x                = 25;//左边距
static const    int     KChannelTextFieldFont    = 16;//字体大小
static const    int     kChannelTextFieldWith    = 200;//textfield的宽度
static const    int     kChannelTextFieldTag     = 201;//textfieldTAG
static const    int     kAddChannelCount         = 4;//通道添加的个数
static const    int     kAddChannelSuccesss      = 0;//通道添加成功的返回值
static const    int     kSeperate                = 10;//间隔
static const    int     kTextFieldOff_y          = 40;//text的y坐标
static const    int     kTextFieldHeight         = 50;//text的高度
static const    int     kTextFieldborderWidth    = 1;//text的边框
static const    int     kTextFieldLeftViewWith   = 60;//左侧lable的宽度
static const    NSTimeInterval  kAmimationTimer  = 0.75;//动画时间
static const    int     kTextFieldSeperate       = 30;//间隔


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"通道管理";
    
    arrayChannelsList = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *array =  [[JVCChannelScourseHelper shareChannelScourseHelper] channelModelWithDeviceYstNumber:self.YstNum];
    [arrayChannelsList addObjectsFromArray:array];
    
    [tableViewChannels reloadData];
    
    //添加按钮
    UIImage *imageRight = [UIImage imageNamed:@"dev_add.png"];
    UIButton *RightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, imageRight.size.width, imageRight.size.height)];
    [RightBtn setImage:imageRight forState:UIControlStateNormal];
    [RightBtn addTarget:self action:@selector(addChannelsToAccount) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:RightBtn];
    self.navigationItem.rightBarButtonItem=rightBarBtn;
    [RightBtn release];
    [rightBarBtn release];
    
    modifyChannelNickNameView = [[UIView alloc] initWithFrame:self.view.bounds];
    modifyChannelNickNameView.backgroundColor = self.view.backgroundColor;
    modifyChannelNickNameView.hidden = YES;
    
    UITapGestureRecognizer *gesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tranfromanimation)];
    [modifyChannelNickNameView addGestureRecognizer:gesture];
    [gesture release];
    
    channelNickNameField = [[UITextField alloc] initWithFrame:CGRectMake(kOffSet_x, kTextFieldOff_y, self.view.width-2*kOffSet_x, kTextFieldHeight)];
    channelNickNameField.delegate = self;
    channelNickNameField.keyboardType = UIKeyboardTypeASCIICapable;
    channelNickNameField.layer.borderWidth = kTextFieldborderWidth;
    UIColor *boardColor  = [[JVCRGBHelper shareJVCRGBHelper] rgbColorForKey:kJVCRGBColorMacroNavBackgroundColor];
    if (boardColor) {
        channelNickNameField.layer.borderColor = boardColor.CGColor;
    }
    
    UILabel *labelLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kTextFieldLeftViewWith, kTextFieldHeight)];
    labelLeft.backgroundColor = [UIColor clearColor];
    labelLeft.textAlignment = UITextAlignmentCenter;
    labelLeft.text = @"昵称:";
    channelNickNameField.leftViewMode = UITextFieldViewModeAlways;
    channelNickNameField.leftView = labelLeft;
    [modifyChannelNickNameView addSubview:channelNickNameField];
    [labelLeft release];
    
  
    
    NSString *imgPath = [UIImage imageBundlePath:@"addDev_btnHor.png"];
    UIImage *imageBtn =[[UIImage alloc] initWithContentsOfFile:imgPath];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(kOffSet_x, channelNickNameField.bottom+kTextFieldSeperate, self.view.width-2*kOffSet_x, kTextFieldHeight);
    [btn addTarget:self action:@selector(editChannelNickName) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    [btn setBackgroundImage:imageBtn forState:UIControlStateNormal];
    [modifyChannelNickNameView addSubview:btn];
    [imageBtn release];
    
    [self.view addSubview:modifyChannelNickNameView];
    
    tableViewChannels = [[UITableView alloc] initWithFrame:self.view.frame];
    tableViewChannels.dataSource = self;
    tableViewChannels.delegate   = self;
    [self.view addSubview:tableViewChannels];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [channelNickNameField release];
    [tableViewChannels release];
    [modifyChannelNickNameView release];
    [self.YstNum release];
    [arrayChannelsList release];
    
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayChannelsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentiyf";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    
    if (cell==nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify] autorelease];
    }
    
    for (UIView *contentView in cell.contentView.subviews) {
        [contentView removeFromSuperview];
    }
    
    //摄像头
    NSString *pathImage = [UIImage imageBundlePath:@"edi_camer.png" ];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:pathImage];
    UIImageView *canmerImage = [[UIImageView alloc] initWithFrame:CGRectMake(kOffSet_x, (cell.height-image.size.height)/2,image.size.width, image.size.height)];
    [canmerImage setImage:image];
    [cell.contentView addSubview:canmerImage];
    [canmerImage release];
    
    //textField
    JVCChannelModel *tCellNode = [arrayChannelsList objectAtIndex:indexPath.row];
    UILabel *channelNickNameLab = [[UILabel alloc] initWithFrame:CGRectMake(kOffSet_x+kSeperate+canmerImage.frame.size.width, canmerImage.frame.origin.y, kChannelTextFieldWith, image.size.height)];
    channelNickNameLab.tag = kChannelTextFieldTag;
    channelNickNameLab.text = tCellNode.strNickName;
    channelNickNameLab.enabled = NO;
    //     channelNickNameFid.returnKeyType = UIReturnKeyDone;
    channelNickNameLab.font = [UIFont systemFontOfSize:KChannelTextFieldFont];
    channelNickNameLab.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:channelNickNameLab];
    [channelNickNameLab release];
    
    [image release];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    channelModel =  [arrayChannelsList objectAtIndex:indexPath.row];
    
    [self tranfromanimation];
}

- (void)tranfromanimation
{
    CATransition *transition = [CATransition animation];
    transition.duration = kAmimationTimer;
    transition.type = @"oglFlip";
    transition.subtype = kCATransitionFromRight;
    bShowEditChannelNickNameValue = !bShowEditChannelNickNameValue;
    if (bShowEditChannelNickNameValue) {
        
        modifyChannelNickNameView.hidden = NO;
        [self.view bringSubviewToFront:modifyChannelNickNameView];
        [self.view bringSubviewToFront:channelNickNameField];
        [channelNickNameField becomeFirstResponder];
    }else{
        
        modifyChannelNickNameView.hidden = YES;
        [channelNickNameField resignFirstResponder];
    }

    [self.view.layer addAnimation:transition forKey:nil];
    [UIView setAnimationDelegate:self];

}

#pragma mark 添加设备的方法
-(void)addChannelsToAccount
{
    [[JVCAlertHelper shareAlertHelper] alertShowToastOnWindow];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int result = [[JVCDeviceHelper sharedDeviceLibrary] addChannelToDevice:YstNum addChannelCount:kAddChannelCount];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (kAddChannelSuccesss == result) {
                
                [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"添加成功"];
                
                [self getAllChannels];//重新获取这个设备下面对应的所有的通道数
                
            }else{
                [[JVCAlertHelper shareAlertHelper] alertHidenToastOnWindow];
                
                [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"添加失败"];
            }
        });
        
    });
}

/**
 *  获取设备下面的所有通道数
 */
- (void)getAllChannels
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *channelAllInfoMdic=[[JVCDeviceHelper sharedDeviceLibrary] getDeviceChannelListData:self.YstNum];
        DDLogInfo(@"获取设备的所有通道信息=%@",channelAllInfoMdic);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL result = [[JVCSystemUtility shareSystemUtilityInstance] JudgeGetDictionIsLegal:channelAllInfoMdic];
            
            [[JVCAlertHelper shareAlertHelper] alertHidenToastOnWindow];
            
            if (result ) {//成功
                
                [[JVCChannelScourseHelper shareChannelScourseHelper]deleteChannelsWithDeviceYstNumber:self.YstNum];
                
                [[JVCChannelScourseHelper shareChannelScourseHelper] channelInfoMDicConvertChannelModelToMArrayPoint:channelAllInfoMdic deviceYstNumber:self.YstNum];
                
                [self updateTableview];
                
            }else{
                
                [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"添加失败"];
                
            }
            
        });
        
    });
    
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JVCChannelModel *deleteChannelModel = [arrayChannelsList objectAtIndex:indexPath.row];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int reuslt =  [[JVCDeviceHelper sharedDeviceLibrary] deleteChannelbyChannelValue:deleteChannelModel.strDeviceYstNumber channelValue:deleteChannelModel.nChannelValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (kAddChannelSuccesss == reuslt) {//成功
                
                [[JVCChannelScourseHelper shareChannelScourseHelper] deleteSingleChannelWithDeviceYstNumber:deleteChannelModel];
                [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"删除成功"];
                
                //跟新
                [self updateTableview];
                
            }else{
                
                [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"删除失败"];
                
            }
        });
        
    });
}

/**
 *  修改通道昵称
 */
- (void)editChannelNickName
{
 
    int resultPredicate = [[JVCPredicateHelper shareInstance] predicateChannelNickName:channelNickNameField.text];
    
    if (kAddChannelSuccesss == resultPredicate) {//成功
        [[JVCAlertHelper shareAlertHelper]alertShowToastOnWindow];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            int result =  [[JVCDeviceHelper sharedDeviceLibrary] modifyDeviceChannelNickName:channelModel.strDeviceYstNumber channelNickName:channelNickNameField.text  channelValue:channelModel.nChannelValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[JVCAlertHelper shareAlertHelper]alertHidenToastOnWindow];
                
                if (kAddChannelSuccesss == result) {//成功
                    
                    [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"修改成功"];
                    
                    channelModel.strNickName = channelNickNameField.text;
                    
                    //转过去
                    [self tranfromanimation];
                    //跟新
                    [self updateTableview];
                    
                }else{
                    
                    [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"修改失败"];
                    
                }
            });
            
            
            
        });

    }else{
        
        [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:@"昵称不合法"];

    }
}

#pragma mark 删除和添加设备之后的刷新方法
- (void)updateTableview
{
    [arrayChannelsList removeAllObjects];
    
    NSMutableArray *array =  [[JVCChannelScourseHelper shareChannelScourseHelper] channelModelWithDeviceYstNumber:self.YstNum];
    [arrayChannelsList addObjectsFromArray:array];
    
    [tableViewChannels reloadData];
}

#pragma mark  textfield的委托事件
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

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