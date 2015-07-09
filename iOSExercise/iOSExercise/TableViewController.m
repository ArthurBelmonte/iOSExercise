//
//  ViewController.m
//  iOSExercise
//
//  Created by Art on 7/9/15.
//  Copyright (c) 2015 ArtieStudios. All rights reserved.
//

#import "TableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "Fact.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "MBProgressHUD.h"

static NSString *baseURL = @"http://guarded-basin-2383.herokuapp.com/";
static NSString *path = @"/facts.json";
static NSString *cellIdentifier = @"FactsCell";
static NSString *defaultImage = @"http://www.imf.org/external/am/2014/img/icon_apple.png";

@interface TableViewController ()

@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation TableViewController

#pragma mark - ViewController lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AFHTTPRequestOperationManager *apiManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    [apiManager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *factsArray = responseObject[@"rows"];
        self.dataSource = [[NSMutableArray alloc] init];
        
        [factsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *data = (NSDictionary *)obj;
            Fact *fact = [[Fact alloc] init];
            fact.title = data[@"title"];
            fact.desc = [self parseString:data[@"description"]];
            fact.imageURL = [self parseString:data[@"imageHref"]];
            [self.dataSource addObject:fact];
        }];
        
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
    // For self-sizing cells
    self.tableView.estimatedRowHeight = 90.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Fact *fact = (Fact *)self.dataSource[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UIImageView *cellImageView = (UIImageView *)[cell viewWithTag:100];
    [cellImageView setImageWithURL:[NSURL URLWithString:fact.imageURL] placeholderImage:[UIImage imageNamed:@"default-placeholder"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    UILabel *cellTitleLabel = (UILabel *)[cell viewWithTag:101];
    cellTitleLabel.text = fact.title;
    
    UILabel *cellDescLabel = (UILabel *)[cell viewWithTag:102];
    cellDescLabel.text = fact.desc;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - My methods

- (NSString *)parseString:(NSString *)string {
    if (string == nil || string == (id)[NSNull null]) {
        return @"";
    }
    else {
        return string;
    }
}

@end
