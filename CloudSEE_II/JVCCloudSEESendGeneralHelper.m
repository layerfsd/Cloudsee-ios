//
//  JVCCloudSEESendGeneralHelper.m
//  CloudSEE_II
//
//  Created by chenzhenyang on 14-9-30.
//  Copyright (c) 2014年 chenzhenyang. All rights reserved.
//

#import "JVCCloudSEESendGeneralHelper.h"
#import "JVCCloudSEENetworkMacro.h"
#import "JVCCloudSEENetworkInterface.h"
#import "JVNetConst.h"
#import  <Arpa/inet.h>

@implementation JVCCloudSEESendGeneralHelper

static JVCCloudSEESendGeneralHelper *jvcCloudSEESendGeneralHelper = nil;

/**
 *  单例
 *
 *  @return 返回JVCCloudSEESendGeneralHelper 单例
 */
+ (JVCCloudSEESendGeneralHelper *)shareJVCCloudSEESendGeneralHelper
{
    @synchronized(self)
    {
        if (jvcCloudSEESendGeneralHelper == nil) {
            
            jvcCloudSEESendGeneralHelper = [[self alloc] init ];
            
        }
        
        return jvcCloudSEESendGeneralHelper;
    }
    
    return jvcCloudSEESendGeneralHelper;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (jvcCloudSEESendGeneralHelper == nil) {
            
            jvcCloudSEESendGeneralHelper = [super allocWithZone:zone];
            
            return jvcCloudSEESendGeneralHelper;
        }
    }
    
    return nil;
}


/**
 *  远程发送的命令（仅仅发送 没有返回结果）
 *
 *  @param nJvChannelID           控制本地连接的通道号
 *  @param remoteOperayionType    控制的类型
 *  @param remoteOperayionCommand 控制的命令
 */
-(void)onlySendRemoteOperation:(int)nJvChannelID remoteOperationType:(int)remoteOperationType remoteOperationCommand:(int)remoteOperationCommand{
    
    switch (remoteOperationType) {
            
        case RemoteOperationType_YTO:{
            
            [self remoteOperationYTO:nJvChannelID remoteOperationCommand:remoteOperationCommand];
        }
            break;
            
        case RemoteOperationType_TextChat:
        case RemoteOperationType_VoiceIntercom:{
            
            [self remoteOperationVoiceChat:nJvChannelID remoteOperationCommand:remoteOperationCommand];
        }
            break;
            
        case RemoteOperationType_RemotePlaybackSEEK:{
            
            [self remotePlaybackSEEK:nJvChannelID remoteOperationCommand:remoteOperationCommand];
        }
            break;
        case TextChatType_NetWorkInfo:{
            
            [self RemoteDeviceNetworkInfo:nJvChannelID];
        }
            break;
            
        case TextChatType_ApList:{
            
            [self RemoteDeviceAplistInfo:nJvChannelID];
            
        }
            break;
        case TextChatType_paraInfo:{
            
            [self RemoteDeviceSettingInfo:nJvChannelID];
        }
            break;
        case  TextChatType_ApSetResult:{
            
            [self RemoteGetApOldsetResult:nJvChannelID];
        }
            break;
        default:
            break;
    }
}


#pragma mark 远程操作的函数

/**
 *  云台控制命令
 *
 *  @param nJvChannelID           控制本地连接的通道号
 *  @param remoteOperationCommand 云台命令
 */
-(void)remoteOperationYTO:(int)nJvChannelID remoteOperationCommand:(int)remoteOperationCommand{
    
    unsigned char data[4]={0};
	memcpy(&data[0],&remoteOperationCommand,4);
    
	JVC_SendData(nJvChannelID, JVN_CMD_YTCTRL, (unsigned char *)data, 4);
    
}

/**
 *  远程发送音频数据
 *
 *  @param nJvChannelID  本地连接的通道号
 *  @param Audiodata     音频数据
 *  @param AudiodataSize 音频数据的大小
 */
-(void)SendAudioDataToDevice:(int)nJvChannelID Audiodata:(char *)Audiodata AudiodataSize:(int)AudiodataSize {
    
    JVC_SendData(nJvChannelID,JVN_RSP_CHATDATA,(unsigned char *)Audiodata,AudiodataSize);
}

/**
 *  远程控制指令
 *
 *  @param nJvChannelID           本地连接的通道号
 *  @param remoteOperationCommand 控制的命令
 */
-(void)RemoteOperationSendDataToDevice:(int)nJvChannelID remoteOperationCommand:(int)remoteOperationCommand {
    
    JVC_SendData(nJvChannelID, remoteOperationCommand, NULL, 0);
    
}

/**
 *  语音聊天
 *
 *  @param nJvChannelID           本地连接的通道号
 *  @param remoteOperayionCommand 控制的命令
 *
 */
-(void)remoteOperationVoiceChat:(int)nJvChannelID remoteOperationCommand:(int)remoteOperationCommand {
    
    JVC_SendData(nJvChannelID, remoteOperationCommand, NULL, 4);
}


/**
 *  远程发送的命令
 *
 *  @param nJvChannelID               控制本地连接的通道号
 *  @param remoteOperayionType        控制的类型
 *  @param remoteOperationCommandData 控制的内容
 */
-(void)remoteSendDataToDevice:(int)nJvChannelID remoteOperationType:(int)remoteOperationType remoteOperationCommandData:(char *)remoteOperationCommandData {
    
    JVC_SendData(nJvChannelID, remoteOperationType, (unsigned char *)remoteOperationCommandData, strlen(remoteOperationCommandData));
    
}

/**
 *  远程回放快进
 *
 *  @param nJvChannelID           本地连接的通道号
 *  @param remoteOperayionCommand 控制的命令
 */
-(void)remotePlaybackSEEK:(int)nJvChannelID remoteOperationCommand:(int)remoteOperationCommand{
    
    unsigned long frameNumber=remoteOperationCommand;
    
    JVC_SendData(nJvChannelID, JVN_CMD_PLAYSEEK, (Byte*)&frameNumber, 4);
    
}

/**
 *  获取设备的网络配置信息
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteDeviceNetworkInfo:(int)nJvChannelID{
    
    PAC	g_stPacket;
    
    memset(&g_stPacket, 0, sizeof(PAC));
    g_stPacket.nPacketType	= RC_LOADDLG;
    g_stPacket.nPacketID	= RC_SNAPSLIST;
    *((int*)g_stPacket.acData) =1;
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&g_stPacket, 8);
    
}

/**
 *  获取设备的配置信息
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteDeviceSettingInfo:(int)nJvChannelID{
    
    PAC	g_stPacket;
    
    memset(&g_stPacket, 0, sizeof(PAC));
    g_stPacket.nPacketType	= RC_LOADDLG;
    g_stPacket.nPacketID	= RC_GETPARAM;
    *((int*)g_stPacket.acData) =1;
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&g_stPacket, 8);
    
}

/**
 *  获取设备附近的网络热点信息
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteDeviceAplistInfo:(int)nJvChannelID{
    
    PAC	g_stPacket;
    memset(&g_stPacket, 0, sizeof(PAC));
    g_stPacket.nPacketType	= RC_EXTEND;
    g_stPacket.nPacketCount	= RC_EX_NETWORK;//IPCAM_NETWORK;
    *((int*)g_stPacket.acData) =EX_WIFI_AP;
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&g_stPacket, 8);
}

/**
 *  获取老的AP配置结果的信息
 *
 *  @param nJvChannelID 本地连接的通道号
 */
-(void)RemoteGetApOldsetResult:(int)nJvChannelID{
    
    PAC	m_stPacket;
    
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_NETWORK;
    
    EXTEND *m_pstExt=(EXTEND*)m_stPacket.acData;
    
    m_pstExt->acData[0]=0;
    m_pstExt->nType=EX_NW_GETRESULT;
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (PAC*)&m_stPacket, 20+strlen(m_pstExt->acData));
}

/**
 *  设置有线网络
 *
 *  @param nJvChannelID      本地连接的通道号
 *  @param nIsEnableDHCP     是否启用自动获取 1:启用 0:手动输入
 *  ************以下参数手动输入时才生效*********************
 *  @param strIpAddress      ip地址
 *  @param strSubnetMaskIp   子网掩码
 *  @param strDefaultGateway 默认网关
 *  @param strDns            DNS服务器地址
 */
-(void)RemoteSetWiredNetwork:(int)nJvChannelID nIsEnableDHCP:(int)nIsEnableDHCP strIpAddress:(NSString *)strIpAddress strSubnetMask:(NSString *)strSubnetMask strDefaultGateway:(NSString *)strDefaultGateway strDns:(NSString *)strDns{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_NETWORK;
    
    EXTEND *m_pstExt=(EXTEND*)m_stPacket.acData;
    m_pstExt->acData[0]=0;
    m_pstExt->nType=EX_NW_SUBMIT;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "ACTIVED=%d;", NetWorkType_Wired);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "bDHCP=%d;", nIsEnableDHCP);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    if(!nIsEnableDHCP){
        
        u_int32_t _uip=inet_addr((const char*)[strIpAddress UTF8String]);
        
        sprintf(acBuffer, "nlIP=%d;", HTONL(_uip));
        strcat(m_pstExt->acData+nOffset, acBuffer);
        nOffset += strlen(acBuffer);
        
        u_int32_t _uNM=inet_addr((const char*)[strSubnetMask UTF8String]);
        
        sprintf(acBuffer, "nlNM=%d;",HTONL(_uNM));
        strcat(m_pstExt->acData+nOffset, acBuffer);
        nOffset += strlen(acBuffer);
        
        u_int32_t _uGW=inet_addr((const char*)[strDefaultGateway UTF8String]);
        
        sprintf(acBuffer, "nlGW=%d;",HTONL(_uGW));
        strcat(m_pstExt->acData+nOffset, acBuffer);
        nOffset += strlen(acBuffer);
        
        u_int32_t _uDns=inet_addr((const char*)[strDns UTF8String]);
        
        sprintf(acBuffer, "nlDNS=%d;",HTONL(_uDns));
        strcat(m_pstExt->acData+nOffset, acBuffer);
    }
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
}

/**
 *  配置设备的无线网络(老的配置方式)
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param strSSIDName     配置的热点名称
 *  @param strSSIDPassWord 配置的热点密码
 *  @param strWifiAuth     热点的认证方式
 *  @param strWifiEncryp   热点的加密方式
 */
-(void)RemoteOldSetWiFINetwork:(int)nJvChannelID strSSIDName:(NSString *)strSSIDName strSSIDPassWord:(NSString *)strSSIDPassWord strWifiAuth:(NSString *)strWifiAuth strWifiEncrypt:(NSString *)strWifiEncrypt{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_NETWORK;
    
    EXTEND *m_pstExt=(EXTEND*)m_stPacket.acData;
    m_pstExt->acData[0]=0;
    m_pstExt->nType=EX_NW_SUBMIT;
    
    int nOffset=0;
    char acBuffer[256]={0};
    
    sprintf(acBuffer, "ACTIVED=%d;", NetWorkType_WiFi);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "WIFI_ID=%s;", [strSSIDName UTF8String]);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "WIFI_PW=%s;",[strSSIDPassWord UTF8String]);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "WIFI_AUTH=%s;",[strWifiAuth UTF8String]);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    nOffset += strlen(acBuffer);
    
    sprintf(acBuffer, "WIFI_ENC=%s;",[strWifiEncrypt UTF8String]);
    strcat(m_pstExt->acData+nOffset, acBuffer);
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+strlen(m_pstExt->acData));
    
}

/**
 *  配置设备的无线网络(新的配置方式)
 *
 *  @param nJvChannelID    本地连接的通道号
 *  @param strSSIDName     配置的热点名称
 *  @param strSSIDPassWord 配置的热点密码
 *  @param nWifiAuth       热点的认证方式
 *  @param nWifiEncryp     热点的加密方式
 */
-(void)RemoteNewSetWiFINetwork:(int)nJvChannelID strSSIDName:(NSString *)strSSIDName strSSIDPassWord:(NSString *)strSSIDPassWord nWifiAuth:(int)nWifiAuth nWifiEncrypt:(int)nWifiEncrypt{
    
    PAC	m_stPacket;
    memset(&m_stPacket, 0, sizeof(PAC));
    m_stPacket.nPacketType=RC_EXTEND;
    m_stPacket.nPacketCount=RC_EX_NETWORK;
    
    EXTEND *m_pstExt=(EXTEND*)m_stPacket.acData;
    m_pstExt->acData[0]=0;
    m_pstExt->nType=EX_WIFI_AP_CONFIG;//wifiType  9命令
    
    WIFI_INFO wifi_info;
    memset(&wifi_info, 0, sizeof(WIFI_INFO));
    
    snprintf(wifi_info.wifiSsid, sizeof(wifi_info.wifiSsid),"%s", [strSSIDName UTF8String]);
    snprintf(wifi_info.wifiPwd,  sizeof(wifi_info.wifiPwd),"%s" , [strSSIDPassWord UTF8String]);
    
    wifi_info.wifiAuth   = nWifiAuth;
    wifi_info.wifiEncryp = nWifiEncrypt;
    
    wifi_info.wifiChannel=0;
    wifi_info.wifiIndex=0;
    wifi_info.wifiRate=0;
    
    memcpy(m_pstExt->acData, &wifi_info, sizeof(WIFI_INFO));
    
    JVC_SendData(nJvChannelID, JVN_RSP_TEXTDATA, (const char*)&m_stPacket, 20+sizeof(WIFI_INFO));
    
}

@end