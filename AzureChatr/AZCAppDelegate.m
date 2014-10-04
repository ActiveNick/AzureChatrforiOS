// ----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// ----------------------------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "AZCAppDelegate.h"
#import "AZCChatListViewController.h"

@implementation AZCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:
                              @"XXXX-InsertYourAzureNotificationHubSharedAccessConnectionStringHere-XXXX" notificationHubPath:@"insertyourpushnotificationhubnamehere"];
    
    [hub registerNativeWithDeviceToken:deviceToken tags:nil completion:^(NSError* error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)alertInfo {
    NSLog(@"%@", alertInfo);
    
    NSString *textMessage = [[alertInfo objectForKey:@"aps"] valueForKey:@"alert"];
    NSString *textUsername = [alertInfo valueForKey:@"username"];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:textMessage
//                        delegate:nil cancelButtonTitle:
//                          @"OK" otherButtonTitles:nil, nil];
//    [alert show];
    
    NSDictionary *item = @{ @"text" : textMessage, @"username" : textUsername };
    
    AZCChatListViewController *rootViewController = (AZCChatListViewController*)self.window.rootViewController;
    [rootViewController addChatItemInView:item];
}

@end
