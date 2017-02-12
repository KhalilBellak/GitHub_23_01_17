//
//  PicPranckActivityItemProvider.m
//  PicPranck
//
//  Created by El Khalil Bellakrid on 12/02/2017.
//  Copyright © 2017 El Khalil Bellakrid. All rights reserved.
//

#import "PicPranckActivityItemProvider.h"

@implementation PicPranckActivityItemProvider
//-(NSString *) activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
//    return @"";
//}
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    //NSLog(@"%@",activityType);
    if(_viewController)
    {
        if ([activityType isEqualToString:@"com.apple.UIKit.activity.Message"])
        {
            [_viewController generateImageToSendWithActivityType:@"iMessage"];
        }
        else if ([activityType isEqualToString:@"net.whatsapp.WhatsApp.ShareExtension"])
        {
            [_viewController generateImageToSendWithActivityType:@"WhatsApp"];
            NSString    * savePath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.png"];
            [UIImageJPEGRepresentation([_viewController getImage], 1.0) writeToFile:savePath atomically:YES];
            return [NSURL fileURLWithPath:savePath];
        }
        else if ([activityType isEqualToString:@"com.facebook.Messenger.ShareExtension"])
        {
            [_viewController generateImageToSendWithActivityType:@"Facebook"];
        }
    }
    return [_viewController getImage];
}
@end
