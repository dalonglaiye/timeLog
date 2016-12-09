//
//  TimeRecordMode.h
//  BIFService
//
//  Created by chenglong on 16/12/6.
//  Copyright © 2016年 Plan B Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/** view和api 的数据mode
 */
@interface TimeRecordMode : NSObject

/// viewId  页面的id
@property (nonatomic, strong) NSString *viewId;

/// 界面开始的时间
@property (nonatomic, strong) NSString *startTime;

/// 界面完成的时间
@property (nonatomic, strong) NSString *finishTime;

/// api的请求路径
@property (nonatomic, strong) NSString *apiPath;

/// api请求开始的时间
@property (nonatomic, strong) NSString *apiStartTime;

/// api请求完成的时间
@property (nonatomic, strong) NSString *apiFinishTime;

/// userId 名称
@property (nonatomic, strong) NSString *uid;

/// net 网络类型
@property (nonatomic, strong) NSString *net;

/// 本机的ip
@property (nonatomic, strong) NSString *ip;

/// 用户选择的城市id
@property (nonatomic, strong) NSString *ccid;

/// 定位获得的城市id
@property (nonatomic, strong) NSString *gcid;

/// 经纬度
@property (nonatomic, strong) NSString *geo;

@end
