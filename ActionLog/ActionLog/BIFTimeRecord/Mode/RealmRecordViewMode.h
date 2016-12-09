//
//  RealmRecordViewMode.h
//  BIFService
//
//  Created by chenglong on 16/12/6.
//  Copyright © 2016年 Plan B Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

/** view 的realm模型
 */
@interface RealmRecordViewMode : RLMObject

/// 本记录是否完整 (YES: 完成， NO:不完整记录)
@property (nonatomic, assign) BOOL sucessRecord;

/// 上传状态(YES上传)
@property (nonatomic, assign) BOOL uploadSty;

/// 页面的 id
@property (nonatomic, strong) NSString *viewId;

/// 界面开始的时间
@property (nonatomic, strong) NSString *startTime;

/// 界面完成的时间
@property (nonatomic, strong) NSString *finishTime;

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
