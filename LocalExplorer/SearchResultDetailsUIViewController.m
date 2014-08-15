//
//  SearchResultDetailsUIViewController.m
//  LocalExplorer
//
//  Created by Wang, Jinlian on 6/13/14.
//  Copyright (c) 2014 capitalone. All rights reserved.
//

#import "SearchResultDetailsUIViewController.h"

@interface SearchResultDetailsUIViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameContent;
@property (weak, nonatomic) IBOutlet UILabel *addressContent;
@property (weak, nonatomic) IBOutlet UILabel *interestsContent;

@end

@implementation SearchResultDetailsUIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.nameContent.text = self.annotation.name;
    self.addressContent.text = self.annotation.thoroughfare;
    self.interestsContent.text = [[self.annotation.areasOfInterest valueForKey:@"description"] componentsJoinedByString:@""];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
