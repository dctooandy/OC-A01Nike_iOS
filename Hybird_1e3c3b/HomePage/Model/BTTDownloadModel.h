//
//  BTTDownloadModel.h
//  Hybird_1e3c3b
//
//  Created by Domino on 17/11/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTBaseModel.h"

@class BTTIconModel;

NS_ASSUME_NONNULL_BEGIN

@interface BTTDownloadModel : BTTBaseModel

@property (nonatomic, copy) NSString *androidLink;

@property (nonatomic, copy) NSString *iosLink;

@property (nonatomic, copy) NSString *params;

@property (nonatomic, strong) BTTIconModel *icon;

@property (nonatomic, copy) NSString *name;

@end

@interface BTTIconModel : BTTBaseModel

@property (nonatomic, copy) NSString *path;

@property (nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
