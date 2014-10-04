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

#import "AZCChatService.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>


#pragma mark * Private interace


@interface AZCChatService() <MSFilter>

@property (nonatomic, strong)   MSTable *table;
@property (nonatomic)           NSInteger busyCount;

@end


#pragma mark * Implementation


@implementation AZCChatService

@synthesize items;


+ (AZCChatService *)defaultService
{
    // Create a singleton instance of AZCChatService
    static AZCChatService* service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[AZCChatService alloc] init];
    });
    
    return service;
}

-(AZCChatService *)init
{
    self = [super init];
    
    if (self)
    {
        // Initialize the Mobile Service client with your URL and key
        MSClient *client = [MSClient clientWithApplicationURLString:@"https://azurechatr.azure-mobile.net/"
                                                     applicationKey:@"XXXX-INSERTYOURAZUREMOBILESERVICEAPPKEYHERE-XXXX"];
        
        // Add a Mobile Service filter to enable the busy indicator
        self.client = [client clientWithFilter:self];
        
        // Create an MSTable instance to allow us to work with the ChatItem table
        self.table = [_client tableWithName:@"ChatItem"];
        
        self.items = [[NSMutableArray alloc] init];
        self.busyCount = 0;
    }
    
    return self;
}

- (void)refreshDataOnSuccess:(AZCCompletionBlock)completion
{
    // Create a predicate that finds items where complete is false
    //NSPredicate * predicate = [NSPredicate predicateWithFormat:@"complete == NO"];
    
    // Query the ChatItem table and update the items property with the results from the service
    //[self.table readWithPredicate:predicate completion:^(NSArray *results, NSInteger totalCount, NSError *error)
    [self.table readWithCompletion:^(NSArray *results, NSInteger totalCount, NSError *error)
    {
        [self logErrorIfNotNil:error];
        
        items = [results mutableCopy];
        
        // Let the caller know that we finished
        completion();
    }];
    
}

-(void)addItem:(NSDictionary *)item completion:(AZCCompletionWithIndexBlock)completion
{
    // Insert the item into the ChatItem table and add to the items array on completion
    [self.table insert:item completion:^(NSDictionary *result, NSError *error)
    {
        [self logErrorIfNotNil:error];
        
        NSUInteger index = [items count];
        //[(NSMutableArray *)items insertObject:result atIndex:index];
        
        // Let the caller know that we finished
        completion(index);
    }];
}

- (void)busy:(BOOL)busy
{
    // assumes always executes on UI thread
    if (busy)
    {
        if (self.busyCount == 0 && self.busyUpdate != nil)
        {
            self.busyUpdate(YES);
        }
        self.busyCount ++;
    }
    else
    {
        if (self.busyCount == 1 && self.busyUpdate != nil)
        {
            self.busyUpdate(FALSE);
        }
        self.busyCount--;
    }
}

- (void)logErrorIfNotNil:(NSError *) error
{
    if (error)
    {
        NSLog(@"ERROR %@", error);
    }
}


#pragma mark * MSFilter methods


- (void)handleRequest:(NSURLRequest *)request
                 next:(MSFilterNextBlock)next
             response:(MSFilterResponseBlock)response
{
    // A wrapped response block that decrements the busy counter
    MSFilterResponseBlock wrappedResponse = ^(NSHTTPURLResponse *innerResponse, NSData *data, NSError *error)
    {
        [self busy:NO];
        response(innerResponse, data, error);
    };
    
    // Increment the busy counter before sending the request
    [self busy:YES];
    next(request, wrappedResponse);
}

@end
