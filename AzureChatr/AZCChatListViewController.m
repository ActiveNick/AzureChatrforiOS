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

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "AZCChatListViewController.h"
#import "AZCChatService.h"


#pragma mark * Private Interface


@interface AZCChatListViewController ()

// Private properties
@property (strong, nonatomic)   AZCChatService   *chatService;
@property (nonatomic)           BOOL            useRefreshControl;

@end


#pragma mark * Implementation


@implementation AZCChatListViewController

@synthesize chatService;
@synthesize itemText;
@synthesize activityIndicator;


#pragma mark * UIView methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the chatService - this creates the Mobile Service client inside the wrapped service
    self.chatService = [AZCChatService defaultService];
    
    // Set the busy method
    UIActivityIndicatorView *indicator = self.activityIndicator;
    self.chatService.busyUpdate = ^(BOOL busy)
    {
        if (busy)
        {
            [indicator startAnimating];
        } else
        {
            [indicator stopAnimating];
        }
    };
    
    // add the refresh control to the table (iOS6+ only)
    [self addRefreshControl];
    
    // load the data
    [self refresh];
}

- (void) refresh
{
    // only activate the refresh control if the feature is available
    if (self.useRefreshControl == YES) {
        [self.refreshControl beginRefreshing];
    }
    [self.chatService refreshDataOnSuccess:^
    {
        if (self.useRefreshControl == YES) {
            [self.refreshControl endRefreshing];
        }
        [self.tableView reloadData];
    }];
}


#pragma mark * UITableView methods


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Set the label on the cell and make sure the label color is black (in case this cell
    // has been reused and was previously greyed out
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.textColor = [UIColor blackColor];
    NSDictionary *item = [self.chatService.items objectAtIndex:indexPath.row];
    
    NSString *chatline = [NSString stringWithFormat: @"%@ - %@", [item objectForKey:@"username"], [item objectForKey:@"text"]];
    label.text = chatline;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Always a single section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of items in the chatService items array
    return [self.chatService.items count];
}


#pragma mark * UITextFieldDelegate methods


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark * UI Actions


- (IBAction)onAdd:(id)sender
{
    if (itemText.text.length  == 0)
    {
        return;
    }
    
    NSDictionary *item = @{ @"text" : itemText.text, @"username" : @"iOS User" };
    //UITableView *view = self.tableView;
    [self.chatService addItem:item completion:^(NSUInteger index)
    {
        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        //[view insertRowsAtIndexPaths:@[ indexPath ]
        //            withRowAnimation:UITableViewRowAnimationBottom];
    }];
    
    itemText.text = @"";
}

- (void)addChatItemInView:(NSDictionary *)textChatItem
{
    NSUInteger index = [[self.chatService items] count];
    [(NSMutableArray *)[self.chatService items] insertObject:textChatItem atIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    UITableView *view = self.tableView;
    [view insertRowsAtIndexPaths:@[ indexPath ]
                withRowAnimation:UITableViewRowAnimationBottom];
}

#pragma mark * iOS Specific Code

// This method will add the UIRefreshControl to the table view if
// it is available, ie, we are running on iOS 6+

- (void)addRefreshControl
{
    Class refreshControlClass = NSClassFromString(@"UIRefreshControl");
    if (refreshControlClass != nil)
    {
        // the refresh control is available, let's add it
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self
                                action:@selector(onRefresh:)
                      forControlEvents:UIControlEventValueChanged];
        self.useRefreshControl = YES;
    }
}

- (void)onRefresh:(id) sender
{
    [self refresh];
}


@end
