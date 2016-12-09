//
//  RealmRecordApiMode.h
//  BIFService
//
//  Created by chenglong on 16/12/6.
//  Copyright © 2016年 Plan B Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

/** api 的Realm的模型
 */
@interface RealmRecordApiMode : RLMObject

/// api所对应页面的viewId
@property (nonatomic, strong) NSString *viewId;

/// api所绑定的view的开始时间
@property (nonatomic, strong) NSString *viewStartTime;

/// 本记录是否完整 (YES 完成， NO 不完整记录 )
@property (nonatomic, assign) BOOL sucessRecord;

/// 请求路径
@property (nonatomic, strong) NSString *apiPath;

/// 请求开始的时间
@property (nonatomic, strong) NSString *apiStartTime;

/// 请求完成的时间
@property (nonatomic, strong) NSString *apiFinishTime;

@end
