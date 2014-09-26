//
//  JVCDeviceListViewController.m
//  CloudSEE_II
//
//  Created by Yanghu on 9/24/14.
//  Copyright (c) 2014 Yanghu. All rights reserved.
//

#import "JVCDeviceListViewController.h"
#import "MJRefreshHeaderView.h"
#import "UIScrollView+MJRefresh.h"
#import "JVCDeviceListAdvertCell.h"
#import "JVCRGBHelper.h"
#import "JVCDeviceListDeviceVIew.h"
#import "JVCAppHelper.h"
#import "JVCDeviceHelper.h"
#import "JVCHandleDeviceMaths.h"
#import "JVCDeviceModel.h"
#import "JVCSystemUtility.h"

static const int  kTableViewCellInViewColumnCount    = 2 ; //判断设备的颜色值是第几个数组
static const int  kTableViewCellColorTypeCount       = 4 ; //判断设备的颜色值是第几个数组


@interface JVCDeviceListViewController ()
{
    UITableView *_tableView;

    NSMutableArray *_arrayColorFirstList;//存放颜色数据的数组
    NSMutableArray *_arrayColorSecondList;//存放颜色数据的数组
}

@end

@implementation JVCDeviceListViewController
@synthesize arrayDeviceList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UITabBarItem *moreItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"设备列表", nil) image:nil tag:1];
        [moreItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_device_select.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_device_unselect.png"]];
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
    self.view.backgroundColor = [UIColor grayColor];
    
    self.navigationController.navigationBar.hidden = NO;
        
    //初始化颜色数组
    _arrayColorFirstList = [[NSMutableArray alloc] initWithObjects:kJVCRGBColorMacroSkyBlue,kJVCRGBColorMacroPurple,kJVCRGBColorMacroGreen,kJVCRGBColorMacroOrange,nil];
    
    _arrayColorSecondList = [[NSMutableArray alloc] initWithObjects:kJVCRGBColorMacroGreen,kJVCRGBColorMacroOrange,nil];

    
    /**
     *  初始化tableview
     */
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    
    //添加下拉刷新
    [self setupRefresh];
    
    //添加数据，为了测试
    arrayDeviceList = [[NSMutableArray alloc] init];
    
    [self getDeviceList];
    
}

/**
*  集成刷新控件
*/
- (void)setupRefresh
{
    
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [_tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    //自动下拉刷新
    //[_tableView headerBeginRefreshing];

    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _tableView.headerPullToRefreshText = @"下拉可以刷新了";
    _tableView.headerReleaseToRefreshText = @"松开马上刷新了";
    _tableView.headerRefreshingText = @"杨虎哥正在帮你刷新中,不客气";


}
#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
  
    
    // 2.2秒后刷新表格UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [_tableView headerEndRefreshing];
    });
}


#pragma mark  tableView 的方法

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 1;
    }
    DDLogInfo(@"_%s==%d=",__FUNCTION__,self.arrayDeviceList.count%kTableViewCellInViewColumnCount == 0 ? self.arrayDeviceList.count/kTableViewCellInViewColumnCount:self.arrayDeviceList.count/kTableViewCellInViewColumnCount+1);
    return self.arrayDeviceList.count%kTableViewCellInViewColumnCount == 0 ? self.arrayDeviceList.count/kTableViewCellInViewColumnCount:self.arrayDeviceList.count/kTableViewCellInViewColumnCount+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return 180;
    }
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogInfo(@"indexPath=%@",indexPath);
    if (indexPath.section == 0) {//新品展示图片
        
        static NSString *cellAdverIdentify = @"cellAdevetIndetify";
        
        JVCDeviceListAdvertCell *cell = [tableView dequeueReusableCellWithIdentifier:cellAdverIdentify];
        
        if (cell == nil) {
            
            cell = [[[JVCDeviceListAdvertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellAdverIdentify] autorelease];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        [cell initCellContent];
        
        return cell;
        
    }else{
    
        static NSString *cellIdentify = @"cellIndetify";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        
        if (cell == nil) {
            
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify] autorelease];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
                
        for (int index = indexPath.row * kTableViewCellInViewColumnCount; index < (indexPath.row +1 )* kTableViewCellInViewColumnCount ; index++) {
            
            
            if (index < arrayDeviceList.count) {
                
                JVCDeviceModel *modelCell = [self.arrayDeviceList objectAtIndex:index];

                int viewIndex  = index % kTableViewCellInViewColumnCount;
                int colorIndex = index % kTableViewCellColorTypeCount;
                
                JVCRGBHelper *rgbHelper  = [JVCRGBHelper shareJVCRGBHelper];
                
                UIImage *deviceImage     = [UIImage imageNamed:@"dev_device_bg.png"];
                UIImage *iconDeviceImage = [UIImage imageNamed:@"dev_device_default_icon.png"];
                
                CGRect position;
                position.size.width  = deviceImage.size.width;
                position.size.height = deviceImage.size.height;
                
                [[JVCAppHelper shareJVCRGBHelper] viewInThePositionOfTheSuperView:cell.width viewCGRect:position nColumnCount:kTableViewCellInViewColumnCount viewIndex:viewIndex+1];
                
                
                UIColor *deviceDeviceViewColor = [rgbHelper rgbColorForKey:[_arrayColorFirstList objectAtIndex:colorIndex]];
    
                if (deviceDeviceViewColor) {
                    
                    JVCDeviceListDeviceVIew *deviceView = [[JVCDeviceListDeviceVIew alloc] initWithFrame:position backgroundColor:deviceDeviceViewColor cornerRadius:6.0f];
                    deviceView.tag = index;
                    
                    UIColor *borderColor    = [rgbHelper rgbColorForKey:kJVCRGBColorMacroWhite alpha:0.3];
                    UIColor *titleGontColor = [rgbHelper rgbColorForKey:kJVCRGBColorMacroWhite];
                    
                    if (borderColor) {
                        
                        [deviceView initWithLayoutView:iconDeviceImage borderColor:borderColor titleFontColor:titleGontColor];
                        [deviceView setAtObjectTitles:modelCell.yunShiTongNum onlineStatus:@"在线" wifiStatus:@"WI-FI"];
                    }
                    
                    //添加选中设备的事件
                    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectDeviceToPlay:)];
                    [deviceView addGestureRecognizer:gesture];
                    [gesture release];
                    
                    [cell.contentView addSubview:deviceView];
                    [deviceView release];
                }
            }
        }
        
        return cell;
    }
}

#pragma mark 选中相应设备的按下事件
/**
 *  选中相应的设备
 */
- (void)selectDeviceToPlay:(UITapGestureRecognizer *)gesture
{
    
    DDLogInfo(@"==%s==gesture.view.tag=%d",__FUNCTION__,gesture.view.tag);
    

}

#pragma mark 获取设备
- (void)getDeviceList
{
    [[JVCAlertHelper shareAlertHelper] alertShowToastOnWindow];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSDictionary *tdicDevice =[[JVCDeviceHelper sharedDeviceLibrary] getAccountByDeviceList];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[JVCAlertHelper shareAlertHelper] alertHidenToastOnWindow];

            
            if (![[JVCAppHelper shareJVCRGBHelper]judgeDictionIsNil:tdicDevice]) {//非空
                
                DDLogInfo(@"_%s===%@",__func__,tdicDevice);
                
               NSArray *deviceListArray =  [[JVCHandleDeviceMaths shareHandleDeviceMaths] convertDeviceListDictionToModelArray:tdicDevice];
                
                [self.arrayDeviceList removeAllObjects];
                
                [self.arrayDeviceList addObjectsFromArray:deviceListArray];
                
                [_tableView reloadData];
                
            }else{//空
            
                
                [[JVCAlertHelper shareAlertHelper]  alertToastWithKeyWindowWithMessage:LOCALANGER(@"JDCSVC_GetDevice_Error")];

            
            }
            
        });

    });
}

#pragma mark  点击设备的回调
/**
 *  选中要播放的设备的回调
 *
 *  @param selectIndex 选中的播放设备号
 */
- (void)selectDeviceToPlayWithIndex:(int)selectIndex
{
    DDLogInfo(@"===%s===%d",__FUNCTION__,selectIndex);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [_arrayColorFirstList release];
    _arrayColorFirstList = nil;
    
    [_arrayColorSecondList release];
    _arrayColorSecondList = nil;
    
    [_tableView release];
    _tableView = nil;
    
    [arrayDeviceList release];
    arrayDeviceList = nil;
    
    [super dealloc];
}

@end