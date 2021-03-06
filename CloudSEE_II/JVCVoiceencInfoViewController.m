//
//  JVCVoiceencInfoViewController.m
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-10-23.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCVoiceencInfoViewController.h"
#import "JVCControlHelper.h"
#import "JVCVoiceencInputSSIDWithPasswordViewController.h"
#import "JVCSystemSoundHelper.h"

@interface JVCVoiceencInfoViewController ()

@end

@implementation JVCVoiceencInfoViewController

static const CGFloat kImageIconWithTop       = 100.0f;
static const CGFloat kInfoTVWithFontSize     = 14.0f;
static const CGFloat kInfoTVWithTop          = 30.0f;
static const CGFloat kVoiceTVWithWidth       = 50.0f;
static const CGFloat kVoiceTVWithPading      = 60.0f;
static const int     kInfoTVWithNumberOfLine = 3;
static const CGFloat kInfoTVWithLineOfHeight = kInfoTVWithFontSize + 6.0f;
static const int     kInfoTVOffx             = 20;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        self.title = LOCALANGER(@"jvc_voice_add_title");
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JVCControlHelper *controlHelperObj = [JVCControlHelper shareJVCControlHelper];
    
    UIImageView *imageView = [controlHelperObj imageViewWithIamge:@"voi_info_icon.png"];

    CGRect imageRect     = imageView.frame;
    
    imageRect.origin.x   = (self.view.frame.size.width - imageView.frame.size.width)/2.0;
    imageRect.origin.y   =  kImageIconWithTop;
    imageView.frame      = imageRect;
    
    [self.view addSubview:imageView];
    
    UILabel *voiceTV        = [controlHelperObj labelWithText:LOCALANGER(@"jvc_voice_add_tick")];
    voiceTV.frame           = CGRectMake(imageView.frame.size.width-kVoiceTVWithPading, imageView.frame.size.height - kVoiceTVWithPading, kVoiceTVWithWidth , kInfoTVWithLineOfHeight*kInfoTVWithNumberOfLine);
    voiceTV.textAlignment   = NSTextAlignmentCenter;
    voiceTV.lineBreakMode   = NSLineBreakByWordWrapping;
    voiceTV.textColor       = [UIColor whiteColor];
    
    voiceTV.font            = [UIFont systemFontOfSize:kInfoTVWithFontSize+2.0];
    
    [imageView addSubview:voiceTV];
    
    
    UILabel *infoTV        = [controlHelperObj labelWithText:LOCALANGER(@"jvc_voice_add_help")];
    infoTV.frame           = CGRectMake(kInfoTVOffx, kInfoTVWithTop, self.view.width -2*kInfoTVOffx , kInfoTVWithLineOfHeight*kInfoTVWithNumberOfLine);
    infoTV.textAlignment   = NSTextAlignmentCenter;
    infoTV.numberOfLines   = kInfoTVWithNumberOfLine;
    infoTV.lineBreakMode   = NSLineBreakByWordWrapping;

    infoTV.font            = [UIFont systemFontOfSize:kInfoTVWithFontSize];
    
    [self.view addSubview:infoTV];
    
    UIButton *nextButton = [controlHelperObj buttonWithTitile:LOCALANGER(@"jvc_voice_add_next") normalImage:@"voi_input_next.png" horverimage:nil];
    
    CGRect NextBtnRect = nextButton.frame;
    
    NextBtnRect.origin.x  = (self.view.frame.size.width - NextBtnRect.size.width)/2.0;
    NextBtnRect.origin.y  = imageView.frame.size.height + imageView.frame.origin.y + 50.0f;
    nextButton.frame      = NextBtnRect;
    [nextButton addTarget:self action:@selector(gotoVoicConfig) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
}

/**
 *  播放音效
 */
-(void)playSound {
    
    NSString *path = [[NSBundle mainBundle ] pathForResource:NSLocalizedString(@"jvc_voice_add_info", nil) ofType:@"mp3"];
    
    if (path) {
        
        [[JVCSystemSoundHelper shareJVCSystemSoundHelper] playSound:path withIsRunloop:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    [self playSound];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    [[JVCSystemSoundHelper shareJVCSystemSoundHelper] stopSound];
}

/**
 *  前往声波配置界面
 */
-(void)gotoVoicConfig {

    JVCVoiceencInputSSIDWithPasswordViewController *jvcVoiceencViewcontroller = [[JVCVoiceencInputSSIDWithPasswordViewController alloc] init];
    
    [self.navigationController pushViewController:jvcVoiceencViewcontroller animated:YES];
    
    [jvcVoiceencViewcontroller release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}


@end
