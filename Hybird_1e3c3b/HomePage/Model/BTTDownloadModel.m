//
//  BTTDownloadModel.m
//  Hybird_1e3c3b
//
//  Created by Domino on 17/11/2018.
//  Copyright © 2018 BTT. All rights reserved.
//

#import "BTTDownloadModel.h"

@implementation BTTDownloadModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"icon":[BTTIconModel class]};
}

- (NSString *)iosLink {
    if (_iosLink.length) {
        NSRange range = [_iosLink rangeOfString:@"download_app"];
        NSInteger location = range.location;
        if (location == NSNotFound) {
            return _iosLink;
        }
        NSString *link = [_iosLink substringFromIndex:location];
        _iosLink = [NSString stringWithFormat:@"%@%@",[IVNetwork h5Domain],link];
        NSLog(@"%@",_iosLink);
    }
    return _iosLink;
}

@end

@implementation BTTIconModel

- (NSString *)path {
    if (![_path hasPrefix:@"http"]) {
        return [PublicMethod nowCDNWithUrl:_path];
    }
    return _path;
}

@end
