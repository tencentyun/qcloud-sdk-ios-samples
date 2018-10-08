//
//  QCloudSelectRegionTableViewController.m
//  QCloudCOSXMLDemo
//
//  Created by erichmzhang(张恒铭) on 26/04/2018.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "QCloudSelectRegionTableViewController.h"
#import "QCloudCOSXMLConfiguration.h"
#import "QCloudTabBarViewController.h"
#import <QCloudCOSXML/QCloudCOSXML.h>
#import "QCloudSelectBUcketTableViewController.h"
@interface QCloudSelectRegionTableViewController ()
@property (nonatomic, strong) NSArray* regionArray;
@end

@implementation QCloudSelectRegionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"选择 Region"];
    self.regionArray = [QCloudCOSXMLConfiguration sharedInstance].availableRegions;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.regionArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    [cell.textLabel setText:self.regionArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* regionName = self.regionArray[indexPath.row];
    [QCloudCOSXMLConfiguration sharedInstance].currentRegion = regionName;
    QCloudServiceConfiguration* configuration = [[QCloudCOSXMLService defaultCOSXML].configuration copy];
    configuration.endpoint.regionName = regionName;
    [QCloudCOSTransferMangerService registerCOSTransferMangerWithConfiguration:configuration withKey:regionName];
    [QCloudCOSXMLService registerCOSXMLWithConfiguration:configuration withKey:regionName];
    
    QCloudSelectBUcketTableViewController *selectBucketViewController = [[QCloudSelectBUcketTableViewController alloc] init];
    [self.navigationController pushViewController:selectBucketViewController animated:YES];
//    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"QCloudTabBarViewController"] animated:YES];

}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
