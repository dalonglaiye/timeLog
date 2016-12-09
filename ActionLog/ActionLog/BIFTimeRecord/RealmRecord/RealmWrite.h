//
//  RealmWrite.h
//  BIFService
//
//  Created by chenglong on 16/12/6.
//  Copyright © 2016年 Plan B Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeRecordMode.h"

// 记录对象类型
typedef NS_ENUM(NSInteger,WriteRecordMode) {
    ViewRecord = 0,// view记录
    ApiRecord,// API 记录
};

@interface RealmWrite : NSObject

/**
 *  存储所有时间记录
 *
 *  @param recordType view或者api 类型
 *  @param nbModel   记录内容模型
 */
+ (void)realmWriteRecordType:(WriteRecordMode )recordType NBModel:(TimeRecordMode *)nbModel;

// 查询当前数据库的记录个数
+ (NSInteger)realmCurrentMaxRecord;

// 查询当前数据库可以上传的完整数据
+ (NSMutableArray *)realmCurrentSucessViewRecord;

//上传成功后，删除数据库数据
+ (void)upLoadSucessRealmRecord;

//上传失败后，恢复数据库数据，接着再传(暂时不用)
+ (void)upLoadFailRealmRecord;

@end
