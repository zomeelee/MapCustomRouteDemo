//
//  ViewController.m
//  KMLDemo
//
//  Created by SagarRK on 19/03/14.
//  Copyright (c) 2014 atonapps. All rights reserved.
//

#import "ViewController.h"
#import "MapVCtr.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayOfData;
@property (nonatomic, strong) IBOutlet MapVCtr *obj_MapVCtr;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDictionary *d1 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sample1" ofType:@"txt"]]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
    
    NSDictionary *d2 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sample2" ofType:@"txt"]]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
    
    NSDictionary *d3 = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sample3" ofType:@"txt"]]
                                                       options:NSJSONReadingAllowFragments
                                                         error:nil];
    
    NSDictionary *dOfData1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"Signposted cycle route Texel", @"Title",
                                d1,@"data",
                              nil];
    NSDictionary *dOfData2 = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Lamb cycle route", @"Title",
                              d2,@"data",
                              nil];
    NSDictionary *dOfData3 = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Eierland-Thijsseroute", @"Title",
                              d3,@"data",
                              nil];
    
    self.arrayOfData = [NSArray arrayWithObjects:dOfData1, dOfData2, dOfData3, nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Bicycle Routes";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @" ";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = [[self.arrayOfData objectAtIndex:indexPath.row] valueForKey:@"Title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.obj_MapVCtr.dOfData = [self.arrayOfData objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:self.obj_MapVCtr animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
