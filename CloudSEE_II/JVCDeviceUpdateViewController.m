//
//  JVCDeviceUpdateViewController.m
//  CloudSEE_II
//
//  Created by Yanghu on 11/17/14.
//  Copyright (c) 2014 Yanghu. All rights reserved.
//

#import "JVCDeviceUpdateViewController.h"
#import "JVCControlHelper.h"
#import "JVCHomeIPCUpdate.h"
#import "CustomIOS7AlertView.h"

typedef NS_ENUM(int , deviceUpdateAlertType) {
    
    deviceUpdateAlertType_update    = 0,//设备更新的
    
    deviceUpdateAlertType_reset     = 1,//设备重置的
    
};

@interface JVCDeviceUpdateViewController ()
{
    UITextField *textFieldDevice;
    
    UITextField *textFieldVersion;
    
    __block JVCHomeIPCUpdate *homeIPC;
    
    UIAlertView *alertDown;
    
     UIAlertView *alertWrite;
    
    UIProgressView *_progressView;
    
    CustomIOS7AlertView *alertViewios7;

}

@end

@implementation JVCDeviceUpdateViewController
@synthesize modelDevice;

static const  kOriginOff_y      = 20;//距离顶端的距离
static const  kSizeSeperate     = 20;//2个textfield的间距

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    "EditDeviceDetailViewController_device_cancel" = "Download cancel";
//    "JvcDeviceUpdateModel"= " model：";
//    "JvcDeviceUpdatedevice"= " device：";
    //设备的
    textFieldDevice = [[JVCControlHelper shareJVCControlHelper] textFieldWithLeftLabelText:LOCALANGER(@"JvcDeviceUpdatedevice") backGroundImage:@"tex_field.png"];
    textFieldDevice.frame = CGRectMake((self.view.width - textFieldDevice.width)/2.0, kOriginOff_y, textFieldDevice.width, textFieldDevice.height);
    textFieldDevice.textAlignment = UITextAlignmentLeft;
    textFieldDevice.text = modelDevice.deviceUpdateType;
    textFieldDevice.userInteractionEnabled = NO;
    [self.view addSubview:textFieldDevice];
    //版本的
    textFieldVersion = [[JVCControlHelper shareJVCControlHelper] textFieldWithLeftLabelText:LOCALANGER(@"JvcDeviceUpdateModel") backGroundImage:@"tex_field.png"];
    textFieldVersion.frame = CGRectMake((self.view.width - textFieldVersion.width)/2.0, textFieldDevice.bottom+kSizeSeperate, textFieldVersion.width, textFieldVersion.height);
    textFieldVersion.userInteractionEnabled = NO;
    textFieldVersion.textAlignment = UITextAlignmentLeft;
    textFieldVersion.text = modelDevice.deviceVersion;
    [self.view addSubview:textFieldVersion];
    //升级的btn的
    UIButton *btnUpDate = [[JVCControlHelper shareJVCControlHelper] buttonWithTitile:LOCALANGER(@"home_device_advance_update") normalImage:@"btn_Bg.png" horverimage:nil];
    btnUpDate.frame = CGRectMake(textFieldVersion.left, textFieldVersion.bottom+kSizeSeperate, textFieldVersion.width, btnUpDate.height);
    [btnUpDate addTarget:self  action:@selector(updateDevieVersion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnUpDate];
    
}

- (void)BackClick
{
    [homeIPC release];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

//升级
- (void)updateDevieVersion
{
    homeIPC = [[JVCHomeIPCUpdate alloc] init:self.modelDevice.deviceType withDeviceModelInt:self.modelDevice.deviceModelInt withDeviceVersion:self.modelDevice.deviceVersion withYstNumber:self.modelDevice.yunShiTongNum withLoginUserName:kkUserName];

    DDLogVerbose(@"%d===0001=%d==",self.retainCount,homeIPC.retainCount);

    JVCHomeIPCUpdateCheckVersionStatusBlock CheckVersionStatusBlock = ^(int result){
    
        DDLogVerbose(@"__%s==%d",__FUNCTION__,result);
        
        if (result == JVCHomeIPCUpdateCheckoutNewVersionHighVersion) {//最新
        
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:LOCALANGER(@"EditDeviceDetailViewController_device_no_new_version")];
                
            });
            
        }else{//升级

             [homeIPC CancelDownloadUpdate];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[JVCAlertHelper shareAlertHelper] alertControllerWithTitle:LOCALANGER(@"home_device_advance_titile") delegate:self selectAction:@selector(startDown) cancelAction:nil selectTitle:LOCALANGER(@"home_device_advance_update") cancelTitle:LOCALANGER(@"jvc_DeviceList_APquit") alertTage:deviceUpdateAlertType_update];

            });
        }
    };
    
    
    JVCHomeIPCDownloadUpdateProgressBlock JVCHomeIPCDownloadUpdateProgressBlock = ^(int result){
        
        DDLogVerbose(@"__%s=JVCHomeIPCDownloadUpdateProgressBlock=%d",__FUNCTION__,result);
        dispatch_async(dispatch_get_main_queue(), ^{
 
        if (alertViewios7 == nil ) {
            
            [self creatAlertWithProgress:YES andTitle:LOCALANGER(@"EditDeviceDetailViewController_device_downing")];
        }else{
            
            [self updataPregressView:result];
        }
    });
    
    };
    
    JVCHomeIPCErrorBlock errorBlock = ^(int result){
        
        DDLogVerbose(@"__%s=JVCHomeIPCErrorBlock=%d",__FUNCTION__,result);
        
        NSString *errorString = nil;
        switch (result) {
            case JVCHomeIPCErrorUpdateError:
                errorString = LOCALANGER(@"EditDeviceDetailViewController_device_down_upload_error");
                break;
            case JVCHomeIPCErrorTimeout:
                errorString = LOCALANGER(@"EditDeviceDetailViewController_device_down_upload_error");
                break;
            case JVCHomeIPCErrorWriteError:
                errorString = LOCALANGER(@"EditDeviceDetailViewController_device_update_error");
                break;
                
            default:
                errorString = LOCALANGER(@"EditDeviceDetailViewController_device_down_upload_error");
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self dismissAlertViewAndProgressView];
            
            [[JVCAlertHelper shareAlertHelper] alertToastWithKeyWindowWithMessage:errorString];
        });
    };
    
    JVCHomeIPCFinshedBlock FinshedBlock = ^(int result){
        
        DDLogVerbose(@"__%s=JVCHomeIPCFinshedBlock=%d",__FUNCTION__,result);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self dismissAlertViewAndProgressView];


        switch (result) {
            case JVCHomeIPCFinshedDownload:
                break;
            case JVCHomeIPCFinshedWrite:
            {
                [[JVCAlertHelper shareAlertHelper] alertControllerWithTitle:LOCALANGER(@"EditDeviceDetailViewController_device_restart") delegate:self selectAction:@selector(startReset) cancelAction:nil selectTitle:LOCALANGER(@"EditDeviceDetailViewController_device_restart_click") cancelTitle:LOCALANGER(@"jvc_DeviceList_APquit") alertTage:deviceUpdateAlertType_reset];

            }
                break;
            case JVCHomeIPCFinshedCancelDownload:
                [[JVCAlertHelper shareAlertHelper]alertToastWithKeyWindowWithMessage:LOCALANGER(@"EditDeviceDetailViewController_device_cancel")];
                break;
                
            default:
                break;
        }
        
     });
};
    
    JVCHomeIPCWriteProgressBlock WriteProgressBlock = ^(int result){
        
        DDLogVerbose(@"__%s=JVCHomeIPCWriteProgressBlock=%d",__FUNCTION__,result);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (alertViewios7 == nil ) {
                
                [self creatAlertWithProgress:NO andTitle:LOCALANGER(@"EditDeviceDetailViewController_device_downing")];
            }else{
                
                [self updataPregressView:result];
            }
        });
    };
    
    JVCHomeIPCResetBlock ResetBlock = ^(int result){
        
        DDLogVerbose(@"__%s=JVCHomeIPCResetBlock=%d",__FUNCTION__,result);
    };

    
    homeIPC.homeIPCUpdateCheckVersionStatusBlock = CheckVersionStatusBlock;
    
    homeIPC.homeIPCErrorBlock = errorBlock;
    
    homeIPC.homeIPCDownloadUpdateProgressBlock = JVCHomeIPCDownloadUpdateProgressBlock;
    
    homeIPC.homeIPCFinshedBlock = FinshedBlock;
    
    homeIPC.homeIPCWriteProgressBlock = WriteProgressBlock;
    
    homeIPC.homeIPCResetBlock = ResetBlock;
    
    DDLogVerbose(@"%d===0002=%d==",self.retainCount,homeIPC.retainCount);
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if(alertView.tag == deviceUpdateAlertType_update)
   {
       if (buttonIndex == 0) {
           
           [self startDown];
       }
   }else if(alertView.tag == deviceUpdateAlertType_reset)
   {
       if (buttonIndex == 0) {
           
           [self startDown];
       }
   }
}


- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [self cancelDeviceDown];
    
    [alertView close];
}

/**
 *  重启设备
 */
- (void)startReset
{
    [homeIPC resetDevice];
}

/**
 *  开始下载
 */
- (void)startDown
{
     [homeIPC DownloadUpdatePacket];
}

/**
 *  取消下载事件
 */
- (void)cancelDeviceDown
{
    [homeIPC CancelDownloadUpdate];
}


/**
 * 让alerview 取消
 */
- (void)dismissAlertViewAndProgressView
{
    _progressView.progress = 0.0;

    if (IOS_VERSION>=7.0) {
        [alertViewios7 close];
        alertViewios7 = nil;
        
    }else{
        [alertDown dismissWithClickedButtonIndex:0 animated:YES];
        
        if (alertDown) {
            [alertDown release];
            alertDown = nil;
            
            [_progressView release];
            _progressView = nil;
        }
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 *  初始化alertview ，带着进度条，取消按钮的
 */
- (void)creatAlertWithProgress:(BOOL)hasProgress  andTitle:(NSString *)title
{
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    
   // if (IOS_VERSION>=7.0) {
        
        if (hasProgress) {
            
            alertViewios7= [[CustomIOS7AlertView alloc] initwithCancel:NO];
            
        }else{
            alertViewios7= [[CustomIOS7AlertView alloc] initwithCancel:YES];
            
        }
        UIView *_contentview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 100)];
        
        UILabel *_lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10,20, 240, 40)];
        _lblTitle.numberOfLines = 0;
        _lblTitle.font = [UIFont systemFontOfSize:15];
        _lblTitle.lineBreakMode = UILineBreakModeCharacterWrap;
        _lblTitle.textAlignment = UITextAlignmentCenter;
        _lblTitle.text = title;
        _lblTitle.backgroundColor = [UIColor clearColor];
        [_contentview addSubview:_lblTitle];
        [_lblTitle release];
        
        _progressView.frame = CGRectMake(20, 80, 220, 30);
        alertViewios7.tag = 100000;
        [_contentview addSubview:_progressView];
        
        // Add some custom content to the alert view
        [alertViewios7 setContainerView:_contentview];
        [_contentview release];
        
        [alertViewios7 setDelegate:self];
        
        // You may use a Block, rather than a delegate.
        [alertViewios7 setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            [homeIPC CancelDownloadUpdate];
            [alertView close];
        }];
        [alertViewios7 setUseMotionEffects:true];
        
        // And launch the dialog
        [alertViewios7 show];
        [alertViewios7 release];
        
//    }else{
//        if (hasProgress) {
//            alertDown = [[UIAlertView alloc] initWithTitle:LOCALANGER(title) message:@"\n" delegate:self cancelButtonTitle:LOCALANGER(@"Cancel") otherButtonTitles: nil];
//            _progressView.frame = CGRectMake(30, 80, 230, 30);
//            alertDown.tag = 100000;
//        }else{
//            alertDown = [[UIAlertView alloc] initWithTitle:LOCALANGER(title) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
//            _progressView.frame = CGRectMake(30, 90, 230, 30);
//            
//        }
//        
//        [alertDown addSubview:_progressView];
//        
//        [alertDown show];
//        
//    }
}

/**
 *  更新progressveiw
 */
-(void)updataPregressView:(int )progressNum
{
    _progressView.progress =  progressNum/100.0;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc
{
    
    [modelDevice release];
    
    [super dealloc];
}

@end
