//
//  JVCDeviceSourceHelper.h
//  CloudSEE_II
//
//  Created by Yanghu on 9/26/14.
//  Copyright (c) 2014 Yanghu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JVCDeviceModel.h"

/**
 *  判断用户名密码和是否超过最大数的枚举
 */
enum ADDDEVICE_TYPE
{
    ADDDEVICE_HAS_EXIST=0,//存在
    ADDDEVICE_NOT_EXIST,//不存在
    ADDDEVICE_MAX_MUX,//超过最大值
    
};

@interface JVCDeviceSourceHelper : NSObject
{
    NSMutableArray *deviceArray;//存放设备数组
}
@property(nonatomic,assign) NSMutableArray *deviceArray;

/**
 *  单例
 *
 *  @return 返回JVCResultTipsHelper 对象
 */
+(JVCDeviceSourceHelper *)shareDeviceSourceHelper;

/**
 *  把从服务器收到的数据转化成model
 *
 *  @param tdicDevice 服务器收到的数据
 */
- (void)convertServerDictionToModelArray:(NSDictionary *)tdicDevice;


/**
 *  根据云视通号查看云视通号在设备中是否存在
 *
 *  @param YSTNum      云视通号
 *  @param deviceArray 传进来的用户的数组
 *
 *  @return ADDDEVICE_HAS_EXIST:存在  ADDDEVICE_NOT_EXIST:不存在  ADDDEVICE_MAX_MUX:超过最大值
 */
- (int)addDevicePredicateHaveYSTNUM:(NSString *)YSTNum;

#pragma mark  添加设备后，把获取到得数据（字典类型）转化为model类型
/**
 *  添加设备后，把获取到得数据（字典类型）转化为model类型
 *
 *  @param deviceInfoDic 设备的类型
 *
 *  @param YSTNum 云视通号
 *
 *  @return 转化完成后的model类型
 */
- (JVCDeviceModel *)convertDeviceDictionToModel:(NSDictionary *)deviceInfoDic withYSTNUM:(NSString *)YSTNum;

/**
 *  根据云通号获取sourceModel
 *
 *  @param ystNumber 云通号
 *
 *  @return 云通号的sourceModel
 */
-(JVCDeviceModel *)getDeviceModelByYstNumber:(NSString *)ystNumber;
@end