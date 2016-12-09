//
//  RealmWrite.m
//  BIFService
//
//  Created by chenglong on 16/12/6.
//  Copyright © 2016年 Plan B Inc. All rights reserved.
//

#import "RealmWrite.h"
#import "RealmRecordViewMode.h"
#import "RealmRecordApiMode.h"
#import <Realm/Realm.h>

@implementation RealmWrite

+ (void)realmWriteRecordType:(WriteRecordMode )recordType NBModel:(TimeRecordMode *)nbModel{
    if (recordType == ViewRecord) {

        // view记录开始，写入所需参数
        if (nbModel.startTime.length > 0 && nbModel.finishTime.length == 0 ) {
            // 创建vieweRealmModel
            RealmRecordViewMode *viewModel = [[RealmRecordViewMode alloc] init];
            viewModel.sucessRecord = NO;
            viewModel.viewId = nbModel.viewId;
            viewModel.startTime = nbModel.startTime;
            viewModel.finishTime = nbModel.finishTime;
            viewModel.uid = nbModel.uid;
            viewModel.net = nbModel.net;
            viewModel.ip = nbModel.ip;
            viewModel.ccid = nbModel.ccid;
            viewModel.gcid = nbModel.gcid;
            viewModel.geo = nbModel.geo;
            // 开启事物写入
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            [realm addObject:viewModel];
            [realm commitWriteTransaction];
            
        // view记录结束，插入结束时间
        } else if (nbModel.finishTime.length > 0 && nbModel.startTime.length == 0) {
            RLMResults *results = [[RealmRecordViewMode objectsWhere:[NSString stringWithFormat:@" viewId = '%@' AND sucessRecord = NO ",nbModel.viewId]] sortedResultsUsingProperty:@"startTime" ascending:NO];
            if (results.count > 0) {
                RealmRecordViewMode *newModel = [[RealmRecordViewMode alloc] init];
                newModel = results.firstObject;
                RLMRealm *realm = [RLMRealm defaultRealm];
                // 开放RLMRealm事务
                [realm beginWriteTransaction];
                newModel.finishTime = nbModel.finishTime;
                newModel.sucessRecord = YES;
                [realm addObject:newModel];
                [realm commitWriteTransaction];
            }
        }
    } else if (recordType == ApiRecord){
        
        // api记录开始，写入所需参数
        if (nbModel.apiStartTime.length>0 && nbModel.apiFinishTime.length == 0) {
            RLMResults *results = [[RealmRecordViewMode objectsWhere:[NSString stringWithFormat:@" viewId = '%@'  ",nbModel.viewId]] sortedResultsUsingProperty:@"startTime" ascending:NO];
            if (results.count > 0) {
                RealmRecordViewMode *viewModel = results.firstObject;
                // 创建apiModel
                RealmRecordApiMode *apiModel = [[RealmRecordApiMode alloc] init];
                apiModel.viewStartTime = viewModel.startTime;
                apiModel.sucessRecord = NO;
                apiModel.viewId = nbModel.viewId;
                apiModel.apiPath = nbModel.apiPath;
                apiModel.apiStartTime = nbModel.apiStartTime;
                apiModel.apiFinishTime = nbModel.apiFinishTime;
                // 开启事物写入
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                [realm addObject:apiModel];
                [realm commitWriteTransaction];
            }
            
        // api记录结束，插入结束时间
        } else if (nbModel.apiFinishTime.length > 0 && nbModel.apiStartTime.length == 0) {
            RLMResults *results = [[RealmRecordApiMode objectsWhere:[NSString stringWithFormat:@" apiPath = '%@' AND sucessRecord = NO AND viewId = '%@' ",nbModel.apiPath, nbModel.viewId]] sortedResultsUsingProperty:@"apiStartTime" ascending:NO];
            if (results.count > 0) {
                RealmRecordApiMode *apiModel = [[RealmRecordApiMode alloc] init];
                apiModel = results.firstObject;
                RLMRealm *realm = [RLMRealm defaultRealm];
                // 开放RLMRealm事务
                [realm beginWriteTransaction];
                apiModel.apiFinishTime = nbModel.apiFinishTime;
                apiModel.sucessRecord = 2;
                [realm addObject:apiModel];
                [realm commitWriteTransaction];
            }
        }
    }
}

+ (NSMutableArray *)realmCurrentSucessViewRecord{
    NSMutableArray *viewLogArr = [[NSMutableArray alloc] init];
    RLMResults *allResults = [RealmRecordViewMode allObjects];
    NSInteger allCount = allResults.count;
    for (int i = 0; i < allCount - 1; i ++) {
        @autoreleasepool {
            RealmRecordViewMode *newModel = allResults[i];
            // 修改状态值
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            newModel.uploadSty = YES;
            [realm addObject:newModel];
            [realm commitWriteTransaction];
            if (newModel.sucessRecord) {
                // 查询view页面下的 所有绑定的api记录
                RLMResults *apiResults = [RealmRecordApiMode objectsWhere:[NSString stringWithFormat:@" sucessRecord = YES  AND viewStartTime = '%@' AND viewId = '%@' ",newModel.startTime, newModel.viewId ]];
                NSMutableArray *apiArr = [[NSMutableArray alloc] init];
                for (RealmRecordApiMode *apiModel in apiResults) {
                    NSString *apiSpend = [[[self alloc] init] getLeadTiemStart:apiModel.apiStartTime finishTime:apiModel.apiFinishTime];
                    if ([[[self alloc] init] checkApiModelRecordWhetherSucess:apiModel spendStr:apiSpend]) {
                        NSDictionary *dict = @{
                                               @"apiPath": apiModel.apiPath,
                                               @"apiStartTime": apiModel.apiStartTime,
                                               @"apiFinishTime": apiModel.apiFinishTime,
                                               @"apiSpend": apiSpend
                                               };
                        [apiArr addObject:dict];
                    }
                }
                // view 页面记录
                NSString *spend = [[[self alloc] init] getLeadTiemStart:newModel.startTime finishTime:newModel.finishTime];
                if ([[[self alloc] init] checkViewModelRecordWhetherSucess:newModel spendStr:spend]) {
                    NSDictionary *viewDict = @{
                                               @"viewId": newModel.viewId,
                                               @"startTime": newModel.startTime,
                                               @"finishTime": newModel.finishTime,
                                               @"spend": spend,
                                               @"uid": newModel.uid ? newModel.uid: @"",
                                               @"net": newModel.net ? newModel.net: @"",
                                               @"ip": newModel.ip ? newModel.ip: @"",
                                               @"ccid": newModel.ccid ? newModel.ccid: @"",
                                               @"gcid": newModel.gcid ? newModel.gcid: @"",
                                               @"geo": newModel.geo ? newModel.geo: @"",
                                               @"api": apiArr
                                               };
                    [viewLogArr addObject:viewDict];
                }
            }
        }
    }
    return viewLogArr;
}

+ (void)upLoadSucessRealmRecord{
    RLMResults *results = [RealmRecordViewMode objectsWhere:@" uploadSty = YES " ];
    for ( RealmRecordViewMode *viewModel in results) {
        @autoreleasepool {
            // 删除对于界面 所对应的api记录
            RLMResults *apiResults = [RealmRecordApiMode objectsWhere:[NSString stringWithFormat:@" viewStartTime = '%@' ", viewModel.startTime] ];
            RLMRealm *realm = [RLMRealm defaultRealm];
            // 开放RLMRealm事务
            [realm beginWriteTransaction];
            [realm deleteObjects:apiResults];
            [realm deleteObject:viewModel];
            [realm commitWriteTransaction];
        }
    }
}

+ (void)upLoadFailRealmRecord{
    RLMResults *results = [RealmRecordViewMode objectsWhere:@" uploadSty = YES " ];
    for ( RealmRecordViewMode *viewModel in results) {
        @autoreleasepool {
            // 修改状态值
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            viewModel.uploadSty = NO;
            [realm addObject:viewModel];
            [realm commitWriteTransaction];
        }
    }
}

+ (NSInteger)realmCurrentMaxRecord {
    // 查询本地记录个数
    RLMResults *results = [RealmRecordViewMode allObjects];
    return results.count;
}

// 计算时间差（毫秒）
- (NSString *)getLeadTiemStart:(NSString *)startTime finishTime:(NSString *)finishTime{
    NSTimeInterval start=[startTime doubleValue];
    NSDate *first = [NSDate dateWithTimeIntervalSince1970:start];
    NSTimeInterval finish =[finishTime doubleValue];
    NSDate *second = [NSDate dateWithTimeIntervalSince1970:finish];
    NSTimeInterval startD = [first timeIntervalSince1970];
    NSTimeInterval finishD = [second timeIntervalSince1970];
    int millisecond = (int)(finishD - startD)%1000;
    return [[NSString alloc] initWithFormat:@"%d", millisecond];
}

// viewRealmModel判空
- (BOOL)checkViewModelRecordWhetherSucess:(RealmRecordViewMode *)dicModel spendStr:(NSString *)spendStr{
    if (dicModel.viewId.length == 0) {
        return NO;
    }
    if (dicModel.startTime.length == 0) {
        return NO;
    }
    if (dicModel.finishTime.length == 0) {
        return NO;
    }
    if (spendStr.length == 0) {
        return NO;
    }
    return YES;
}

// apiRealmModel判空
- (BOOL)checkApiModelRecordWhetherSucess:(RealmRecordApiMode *)dicModel spendStr:(NSString *)spendStr{
    if (dicModel.apiPath.length == 0) {
        return NO;
    }
    if (dicModel.apiStartTime.length == 0) {
        return NO;
    }
    if (dicModel.apiFinishTime.length == 0) {
        return NO;
    }
    if (spendStr.length == 0) {
        return NO;
    }
    return YES;
}

@end
