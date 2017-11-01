//
//  CCUploadFromOtherUpp.m
//  Nextcloud iOS
//
//  Created by Marino Faggiana on 01/12/14.
//  Copyright (c) 2017 TWS. All rights reserved.
//
//  Author Marino Faggiana <m.faggiana@twsweb.it>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "CCUploadFromOtherUpp.h"
#import "AppDelegate.h"
#import "NCBridgeSwift.h"

@interface CCUploadFromOtherUpp()
{
    NSString *serverUrlLocal;
    NSString *destinationTitle;
}
@end

@implementation CCUploadFromOtherUpp

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"_cancel_", nil);
    self.title = NSLocalizedString(@"_upload_", nil);
    
    serverUrlLocal= [CCUtility getHomeServerUrlActiveUrl:app.activeUrl];
    destinationTitle = NSLocalizedString(@"_home_", nil);
    
    // Color
    [app aspectNavigationControllerBar:self.navigationController.navigationBar online:[app.reachability isReachable] hidden:NO];
    [app aspectTabBar:self.tabBarController.tabBar hidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// E' apparsa
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark == tableView ==
#pragma --------------------------------------------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return NSLocalizedString(@"_file_to_upload_", nil);
    else if (section == 2) return NSLocalizedString(@"_destination_", nil);
    else if (section == 4) return NSLocalizedString(@"_upload_file_", nil);
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UILabel *nameLabel;
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    switch (section)
    {
        case 0:
            if (row == 0) {
                                
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", app.directoryUser, app.fileNameUpload] error:nil];
                NSString *fileSize = [CCUtility transformedSize:[[fileAttributes objectForKey:NSFileSize] longValue]];
                nameLabel = (UILabel *)[cell viewWithTag:100]; nameLabel.text = [NSString stringWithFormat:@"%@ - %@", app.fileNameUpload, fileSize];
            }
            break;
        case 2:
            if (row == 0) {
    
                nameLabel = (UILabel *)[cell viewWithTag:101]; nameLabel.text = destinationTitle;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                UIImageView *img = (UIImageView *)[cell viewWithTag:201];
                img.image = [UIImage imageNamed:@"folder"];
            }
            break;
        case 4:
            
            if (row == 0) {
                nameLabel = (UILabel *)[cell viewWithTag:102]; nameLabel.text = NSLocalizedString(@"_upload_file_", nil);
            }
            
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (section) {
        case 2:
            if (row == 0) {
                [self changeFolder];
            }
            break;
        case 4:
            if (row == 0) {
                [self upload];
            }
            break;
    }
}

#pragma --------------------------------------------------------------------------------------------
#pragma mark == IBAction ==
#pragma --------------------------------------------------------------------------------------------

- (void)moveServerUrlTo:(NSString *)serverUrlTo title:(NSString *)title
{
    if (serverUrlTo) {
        serverUrlLocal = serverUrlTo;
        if (title) destinationTitle = title;
        else destinationTitle = NSLocalizedString(@"_home_", nil);
    }
}

- (void)changeFolder
{
    UINavigationController *navigationController = [[UIStoryboard storyboardWithName:@"CCMove" bundle:nil] instantiateViewControllerWithIdentifier:@"CCMove"];
    
    CCMove *viewController = (CCMove *)navigationController.topViewController;
    viewController.delegate = self;
    viewController.move.title = NSLocalizedString(@"_select_", nil);
    viewController.tintColor = [NCBrandColor sharedInstance].navigationBarText;
    viewController.barTintColor = [NCBrandColor sharedInstance].brand;
    viewController.tintColorTitle = [NCBrandColor sharedInstance].navigationBarText;
    viewController.networkingOperationQueue = app.netQueue;

    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)upload
{
    [[CCNetworking sharedNetworking] uploadFile:app.fileNameUpload serverUrl:serverUrlLocal session:k_upload_session taskStatus: k_taskStatusResume selector:@"" selectorPost:@"" errorCode:0 delegate:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)Annula:(UIBarButtonItem *)sender
{    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
