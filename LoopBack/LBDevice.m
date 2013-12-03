#import "LBDevice.h"

@implementation LBDevice

+ (NSString *)deviceToken: (NSData *) token {
    // 1. Convert device token from NSData to NSString
    const unsigned *tokenBytes = [token bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    return hexToken;
}

+ (void)registerDevice: (LBDevice *) device
               success: (SLSuccessBlock) success
               failure: (SLFailureBlock) failure {
    // 4. Save!
    [device saveWithSuccess:^{
        NSLog(@"Successfully saved %@", device._id);
        success(device);
    } failure:^(NSError *error) {
        NSLog(@"Failed to save %@ with %@", device, error);
        failure(error);
    }];
}

/**
 * Saves the desired Device model to the server with all values pulled from the UI.
 */
+ (void)registerDevice:(LBRESTAdapter *) adapter
           deviceToken: (NSData *)deviceToken
        registrationId: (NSNumber *)registrationId
                 appId: (NSString *) appId
            appVersion: (NSString * ) appVersion
                userId: (NSString *) userId
                 badge: (NSNumber *) badge
               success: (SLSuccessBlock) success
               failure: (SLFailureBlock) failure {
    
    NSString* hexToken = [LBDevice deviceToken:deviceToken];
    
    LBDeviceRepository *repository = (LBDeviceRepository *) [adapter repositoryWithModelClass:[LBDeviceRepository class]];
    
    // 3. From that repository, create a new LBDevice.
    LBDevice *model = (LBDevice *)[repository modelWithDictionary:@{
                                           @"appId": appId,
                                           @"appVersion": appVersion,
                                           @"userId": userId,
                                           @"deviceType": @"ios",
                                           @"deviceToken": hexToken,
                                           @"status": @"Active",
                                           @"badge": badge}];
    
    if(registrationId) {
        model.id = registrationId;
    }
    
    [LBDevice registerDevice:model success:success failure:failure];
}

@end


@implementation LBDeviceRepository

+ (instancetype)repository {
    LBDeviceRepository *repository = [self repositoryWithClassName:@"devices"];
    repository.modelClass = [LBDevice class];
    return repository;
}

@end

