//
//  TimeLog.h
//  BIFService
//
//  Created by chenglong on 16/12/6.
//  Copyright © 2016年 Plan B Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, StartOrFinishRecordType) {
    StartRecord = 0,//开始记录
    FinishRecord, //结束记录
};

/** 记录界面 和 api 的响应时间点
 */
@interface TimeLog : NSObject

+ (TimeLog *)shareWriteTimMet;

/**
 *  设置所需参数（appaction必填参数）
 *
 *  @param appAction 必填参数：此值是每个app的唯一标识符
 *  @param maxWritesSend   本地保存的最大条数，设置0(默认为30)
 */
- (void)addCurrentAppAction:(NSString *)appAction maxWritesSendNumber:(NSInteger)maxWritesSendNumber;

/**
 *  记录view 界面的开始和完成 时间
 *
 *  @param writeTime 时间类型
 *  @param viewId   页面的id
 */
- (void)viewWriteTimeType:(StartOrFinishRecordType )writeTime ViewId:(NSString *)viewId;

/**
 *  记录api 请求的开始和完成 时间
 *
 *  @param writeTime 时间类型
 *  @param viewId   页面的id
 *  @param apiId   api的path
 */
- (void)apiWriteTimeType:(StartOrFinishRecordType )writeTime ViewId:(NSString *)viewId ApiPath:(NSString *)apiPath;

@end
