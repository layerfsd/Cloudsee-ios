//
//  JVCAPConfigPreparaViewController.m
//  CloudSEE_II
//
//  Created by Yanghu on 9/28/14.
//  Copyright (c) 2014 Yanghu. All rights reserved.
//

#import "JVCAPConfigPreparaViewController.h"

static const int  ADDCONFIGHEIGIN = 64;//按钮多出来的那个高度

@interface JVCAPConfigPreparaViewController ()

@end

@implementation JVCAPConfigPreparaViewController

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *iamgeAp = [UIImage imageNamed:LOCALANGER(@"add_apConfig")];
    UIImage *btnBg = [UIImage imageNamed:@"add_ApConfig.png"];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    
    scrollView.contentSize = CGSizeMake(iamgeAp.size.width, iamgeAp.size.height);
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iamgeAp.size.width, iamgeAp.size.height+ADDCONFIGHEIGIN)];
    imageview.image = iamgeAp;
    [scrollView addSubview:imageview];
    [imageview release];
    
    [self.view addSubview:scrollView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((self.view.width -btnBg.size.width)/2.0 , (imageview.height+ADDCONFIGHEIGIN- btnBg.size.height)/2.0, btnBg.size.width, btnBg.size.height);
    [scrollView addSubview:btn];
    [btn addTarget:self action:@selector(exitToAPPConfig) forControlEvents:UIControlEventTouchUpInside];
    [scrollView release];

}

/**
 *  弹出alert提示，看看是否退出程序
 */
- (void)exitToAPPConfig
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LOCALANGER(@"home_ap_Alert_message_ios7") message:nil delegate:self cancelButtonTitle:LOCALANGER(@"home_ap_Alert_GOON") otherButtonTitles:LOCALANGER(@"home_ap_Alert_NO"), nil];
    alertView.delegate = self;
    [alertView show];
    [alertView release];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {//继续
        
        exit(0);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
