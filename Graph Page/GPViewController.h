//
//  GPViewController.h
//  Graph Page
//
//  Created by Kyle Krynski on 2/20/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPViewController : UIViewController <UITabBarDelegate, CPTPlotDataSource, UIActionSheetDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

//tab bar at bottom
@property (nonatomic, strong) IBOutlet UITabBar *options;
@property (nonatomic, strong) IBOutlet UITabBarItem *graph;
@property (nonatomic, strong) IBOutlet UITabBarItem *data;

//array for tab bar
@property (nonatomic, retain) NSMutableArray *headings;

//graph area
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;

//collection view for data table
@property (nonatomic, strong) UICollectionView *collectionView;

//arrays for data points
@property (nonatomic, strong) NSMutableArray *xVals;
@property (nonatomic, strong) NSMutableArray *yVals;
@property (nonatomic, strong) NSMutableArray *xSort;
@property (nonatomic, strong) NSMutableArray *ySort;

//input for data table
@property (nonatomic, strong) UITextField *xIn;
@property (nonatomic, strong) UITextField *yIn;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIButton *delButton;
@property (nonatomic, strong) UISwitch *sortButton;
@property (nonatomic, strong) NSNumber *buttonState;
@property (nonatomic, strong) NSNumber *timeState;


@end
