//
//  TimeLog.m
//  BIFService
//
//  Created by chenglong on 16/12/6.
//  Copyright © 2016年 Plan B Inc. All rights reserved.
//

#import "TimeLog.h"
#import "TimeRecordMode.h"
#import "BIFAppConfig.h"
#import "RealmWrite.h"
#import "BIFLogger.h"
#import "ActionLogApi.h"

@interface TimeLog ( )<BIFApiDelegate,BIFRESTfulApiDataSource>
@property (nonatomic, strong) NSString *appAction; //必填参数
@property (nonatomic, assign) NSInteger maxWritesSendNumber;
@property (nonatomic, assign) BOOL upLoadState;
@property (nonatomic, strong) NSMutableArray *allArr; //数据库查出来的数组

@end

@implementation TimeLog

+ (TimeLog *)shareWriteTimMet{
    static TimeLog *method = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        method = [[[self class] alloc] init];
    });
    return method;
}

- (void)addCurrentAppAction:(NSString *)appAction maxWritesSendNumber:(NSInteger)maxWritesSendNumber
{
    self.appAction = appAction;
    if (maxWritesSendNumber == 0) {
        self.maxWritesSendNumber = maxWritesSendNumber = 30;
    } else{
        self.maxWritesSendNumber = maxWritesSendNumber;
    }
}

- (void)viewWriteTimeType:(StartOrFinishRecordType)writeTime ViewId:(NSString *)viewId{
    if (viewId.length > 0) {
        TimeRecordMode *nbModel = [[TimeRecordMode alloc] init];
        if (writeTime == StartRecord) {
            nbModel.startTime = [self currentTime];
            nbModel.finishTime = @"";
        } else if (writeTime == FinishRecord) {
            nbModel.finishTime = [self currentTime];
            nbModel.startTime = @"";
        } else {
            return;
        }
        BIFAppConfig *appConfig = [BIFAppConfig shared];
        NSString *geo = @"";
        if (appConfig.lat.length > 0 && appConfig.lng > 0) {
            geo = [NSString stringWithFormat:@"%@-%@",appConfig.lat,appConfig.lng];
        }
        nbModel.uid = appConfig.userId ? appConfig.userId : @"";
        nbModel.net = appConfig.net ? appConfig.net : @"";
        nbModel.ip =  appConfig.ip ? appConfig.ip : @"";
        nbModel.ccid = appConfig.ccid ? appConfig.ccid : @"";
        nbModel.gcid = appConfig.gcid ? appConfig.gcid : @"";
        nbModel.geo = geo;
        nbModel.viewId = viewId;
        // 插入数据库
        [RealmWrite realmWriteRecordType:ViewRecord NBModel:nbModel];
    }
    
    // 判断是否要上传
    if (self.upLoadState == NO && [RealmWrite realmCurrentMaxRecord] > self.maxWritesSendNumber) {
        NSMutableArray *logArr = [RealmWrite realmCurrentSucessViewRecord];
        if (logArr.count > 0) {
            [self recordToServer:logArr];
        }
    }
}

- (void)apiWriteTimeType:(StartOrFinishRecordType)writeTime ViewId:(NSString *)viewId ApiPath:(NSString *)apiPath{
    if (viewId.length > 0 && apiPath.length > 0) {
        TimeRecordMode *nbModel = [[TimeRecordMode alloc] init];
        if (writeTime == StartRecord) {
            nbModel.apiStartTime = [self currentTime];
            nbModel.apiFinishTime = @"";
        } else if (writeTime == FinishRecord) {
            nbModel.apiFinishTime = [self currentTime];
            nbModel.apiStartTime = @"";
        } else {
            return;
        }
        nbModel.viewId = viewId;
        nbModel.apiPath = apiPath;
        // 插入数据库
        [RealmWrite realmWriteRecordType:ApiRecord NBModel:nbModel];
    }
}

- (NSString *)currentTime{
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    UInt64 recordTime = a*1000;
    NSString *timeString = [NSString stringWithFormat:@"%llu", recordTime];
    return timeString ? timeString: @"";
}

- (void)recordToServer:(NSMutableArray *)logArr{
    // 1. 添加参数，换成上传的数据结构
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [[NSString  stringWithFormat:@"%f", a] substringWithRange:NSMakeRange(0, 10)];
    
    self.allArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < logArr.count ; i ++) {
        @autoreleasepool {
            NSDictionary *extendDict = logArr[i];
            NSDictionary *extend = @{
                                     @"viewId": extendDict[@"viewId"],
                                     @"startTime": extendDict[@"startTime"],
                                     @"finishTime": extendDict[@"finishTime"],
                                     @"spend": extendDict[@"spend"],
                                     @"api": extendDict[@"api"]
                                     };
            NSDictionary *log = @{
                                  @"action": self.appAction,
                                  @"clickTime": timeString,
                                  @"extend": extend,
                                  };
            NSDictionary *argument = @{
                                       @"uid": extendDict[@"uid"],
                                       @"net": extendDict[@"net"],
                                       @"ip": extendDict[@"ip"],
                                       @"ccid": extendDict[@"ccid"],
                                       @"gcid": extendDict[@"gcid"],
                                       @"geo": extendDict[@"geo"],
                                       @"logs": @[log],
                                       };
            [self.allArr addObject:argument];
        }
    }
    
    //  2. 查找出uid、net、ip、ccid、gcid、geo相同的字典
    NSInteger allArrCount = self.allArr.count;
    NSMutableArray *sameArr= [[NSMutableArray alloc] init];
    for (int i = 0; i < allArrCount; i ++) {
        @autoreleasepool {
            if (self.allArr.count == 0) {
                break;
            }
            if (self.allArr.count > 0) {
                [sameArr addObject:[self compareTwoValuesArr:self.allArr]];
            }
        }
    }
    // 3. 赋值usages
    NSMutableArray *usageArr = [[NSMutableArray alloc] init];
    for (NSMutableArray *endArr in sameArr) {
        @autoreleasepool {
            NSMutableArray *newArr = [[NSMutableArray alloc] init];
            for (NSDictionary *endDict in endArr) {
                NSArray *logs = endDict[@"logs"];
                [newArr addObject:logs.firstObject];
            }
            // 相同的uid、net、ip、ccid、gcid、geo塞到同一个logs字典中
            NSMutableDictionary *sucessDict =[NSMutableDictionary dictionaryWithDictionary:endArr.firstObject];
            sucessDict[@"logs"] = newArr;
            [usageArr addObject:sucessDict];
        }
    }
    BIFLogConfig  *configParams = [[BIFLogConfig alloc] init];
    configParams.usages = [NSArray arrayWithArray:usageArr];
    [sameArr removeAllObjects];
    [self.allArr removeAllObjects];
    
    // 4. 添加device、app 参数
    BIFAppConfig *appConfig = [BIFAppConfig shared];
    configParams.device.mac = @"02:00:00:00:00:00";
    configParams.device.dvid = appConfig.uuid;
    configParams.device.model = appConfig.pm;
    configParams.device.os = appConfig.osv;
    configParams.app.name = appConfig.appName;
    configParams.app.ch  = appConfig.chanalId;
    configParams.app.ver = appConfig.appVerSion;
    NSMutableDictionary *jsonDict = [configParams dictionaryRepresentation];
    
    // 5. 上传服务器
    ActionLogApi *actionLogApi = [ActionLogApi appActionLogApi];
    actionLogApi.apiDelegate = self;
    actionLogApi.postParamForApiBlock = ^NSDictionary *(BIFApi *api) {
        return jsonDict;
    };
    self.upLoadState = YES;
    [actionLogApi requestAsync];
}

// 返回uid、net、ip、ccid、gcid、geo相同的字典
- (NSMutableArray *)compareTwoValuesArr:(NSMutableArray *)argumentArr{
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    [newArr addObjectsFromArray:argumentArr];
    
    NSDictionary *argument = newArr.firstObject;
    NSMutableArray *sameArr = [[NSMutableArray alloc] init];
    [sameArr addObject:argument];
    [self.allArr removeObject:argument];
    for (int i = 1; i < newArr.count; i ++) {
        NSDictionary *newDict = newArr[i];
        if (![self isOneStr:newDict[@"uid"] TwoStr:argument[@"uid"]] ) {
            continue;
        }
        if (![self isOneStr:newDict[@"net"] TwoStr:argument[@"net"]] ) {
            continue;
        }
        if (![self isOneStr:newDict[@"ip"] TwoStr:argument[@"ip"]] ) {
            continue;
        }
        if (![self isOneStr:newDict[@"ccid"] TwoStr:argument[@"ccid"]] ) {
            continue;
        }
        if (![self isOneStr:newDict[@"gcid"] TwoStr:argument[@"gcid"]] ) {
            continue;
        }
        if (![self isOneStr:newDict[@"geo"] TwoStr:argument[@"geo"]] ) {
            continue;
        }
        [sameArr addObject:newDict];
        [self.allArr removeObject:newDict];
    }
    return sameArr;
}

- (BOOL)isOneStr:(NSString *)onestr TwoStr:(NSString *)twoStr{
    if ([onestr isEqualToString:twoStr]) {
        return YES;
    }
    return NO;
}

- (void)api:(ActionLogApi *)api didFinishWithResponse:(BIFURLResponse *)response reformedData:(id)result
{
    if (api.apiType == ActionLogApiTypeActionLog) {
        [RealmWrite upLoadSucessRealmRecord];
        self.upLoadState = NO;
    }
}

- (void)api:(ActionLogApi *)api didFailWithResponse:(BIFURLResponse *)response
{
    if (api.apiType == ActionLogApiTypeActionLog) {
        self.upLoadState = NO;
    }
}

- (NSString *)appAction{
    if (!_appAction) {
        _appAction = [[NSString alloc] init];
        _appAction = @"";
    }
    return _appAction;
}

@end
