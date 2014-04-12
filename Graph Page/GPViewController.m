//
//  GPViewController.m
//  Graph Page
//
//  Created by Kyle Krynski on 2/20/14.
//  Copyright (c) 2014 SGSC. All rights reserved.
//

#import "GPViewController.h"

@interface GPViewController ()

@end

@implementation GPViewController

@synthesize options;
@synthesize graph;
@synthesize data;
@synthesize headings;
@synthesize hostView = hostView_;
@synthesize selectedTheme = selectedTheme_;
@synthesize collectionView;
@synthesize xVals;
@synthesize yVals;
@synthesize xIn;
@synthesize yIn;
@synthesize addButton;
@synthesize delButton;
@synthesize xSort;
@synthesize ySort;
@synthesize sortButton;
@synthesize buttonState;
@synthesize timeState;

int setX;
int setY;

#pragma mark - Basic Controller Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
  //xVals = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", nil];
  //yVals = [[NSMutableArray alloc] initWithObjects:@"5", @"10", @"15", nil];
  xVals = [[NSMutableArray alloc] init];
  yVals = [[NSMutableArray alloc] init];
  xSort = [[NSMutableArray alloc] init];
  ySort = [[NSMutableArray alloc] init];
  buttonState = [NSNumber numberWithBool:false];
  timeState = [NSNumber numberWithInt:0];
  // Double check to make sure orientation is correct.
  // iOS 7 introduced a bug where sometimes the VC
  // doesn't know which orientation it's supposed to be.
  // Thus, in landscape, it creates a landscape VC but
  // any reference to its frame will result in portrait
  // values.
  CGRect r = self.view.bounds;
  
  if (r.size.height > r.size.width)
  {
    float w = r.size.width;
    r.size.width = r.size.height;
    r.size.height = w;
  }
  
  self.view.bounds = r;
  
  //Finding bounds of view
  float height = self.view.bounds.size.height;
  float width = self.view.bounds.size.width;
  NSLog(@"Total height: %lf", height);
  NSLog(@"Total width: %lf", width);
  
  //Figuring out where to position tab bar
  height = height - 50;
  NSLog(@"Tabbar y: %lf", height);
  
  //Allocing the tab bar and initializing its frame
  options = [[UITabBar alloc] initWithFrame:CGRectMake(0.0, height, width, 50.0)];
  options.delegate = self;
  [self.view addSubview: options];
  
  //Allocing the items for tab bar
  headings = [[NSMutableArray alloc] init];
  graph = [[UITabBarItem alloc] initWithTitle:@"Graph" image:nil tag: 0];
  data = [[UITabBarItem alloc] initWithTitle:@"Data" image:nil tag: 1];
  
  //Adding items to array
  [headings addObject: graph];
  [headings addObject:data];
  
  //Setting tab bar items to array
  options.items = headings;
  options.selectedItem = [headings objectAtIndex: 0];
  
  //Fixing item positions and colors
  options.itemSpacing = 400;
  options.itemWidth = 200;
  
  //Initializing plot area
  [self initPlot];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tab Bar Delegate Methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
  int selectedTag = tabBar.selectedItem.tag;
  
  if (selectedTag == 0) {
    //Unload Data rectangle
    [self unloadLabels];
    
    NSLog(@"SWITCH");
    
    //Load Graph rectangle
    [self initPlot];
    
  } else if (selectedTag == 1) {
    //Unload Graph hostview
    [self.hostView removeFromSuperview];
    
    NSLog(@"SWITCH");
    
    //Load Data rectangle
    if (timeState.intValue == 0) {
      [self initData];
      NSLog(@"***started***");
    } else {
      [self reloadLabels];
      NSLog(@"***reloaded***");
    }
    
    //Update time state
    timeState = [NSNumber numberWithInt:1];
    
  } else {
    NSLog(@"Tab bar failure.");
  }
  
}


#pragma mark - CPTPlotDataSource methods
-(NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
  // 1 - Returning size of data array
  return [xVals count];
}

-(NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
  // 1 - Getting doubles of object at index in arrays
    double currentX = [[xSort objectAtIndex:index] doubleValue];
    double currentY = [[ySort objectAtIndex:index] doubleValue];
  
  // 1.5 - Check if no data
  if (xVals.count == 0) {
    return 0;
  }
  
  // 2 - Checking which plot field to use
  switch (fieldEnum) {
    case CPTScatterPlotFieldX:
        return [NSNumber numberWithDouble:currentX];
      
    case CPTScatterPlotFieldY:
      return [NSNumber numberWithDouble:currentY];
  }
  return [NSDecimalNumber zero];
}


#pragma mark - UIActionSheetDelegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
}


#pragma mark - Chart behavior
-(void) initPlot {
  [self configureHost];
  [self configureGraph];
  [self configurePlots];
  [self configureAxes];
}

-(void) configureHost {
  //Setting up rectangle
  CGRect parentRect = self.view.bounds;
  NSLog(@"Total height: %f", parentRect.size.height);
  NSLog(@"Total width: %f", parentRect.size.width);
  
  //Getting status bar height
  CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
  CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
  NSLog(@"Status height: %f", statusBarHeight);
  
  //Getting tab bar height
  CGFloat tabBarHeight = self.options.bounds.size.height;
  NSLog(@"Tab height: %f", tabBarHeight);
  
  //Changing parent rectangle  -- Switching to hard coded height
  parentRect = CGRectMake(parentRect.origin.x, parentRect.origin.y + statusBarHeight, parentRect.size.width, parentRect.size.height - 50.0 - statusBarHeight);
  
  //Initializing host view for chart
  self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
  self.hostView.allowPinchScaling = YES;
  
  //Putting host view into current view
  [self.view addSubview: self.hostView];
  
}

-(void) configureGraph {
  // 1 - Create and initialize graph
  CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame: self.hostView.bounds];
  self.hostView.hostedGraph = graph;
  //[graph.plotAreaFrame setPaddingLeft:30.0f];
  //[graph.plotAreaFrame setPaddingBottom:30.0f];
  
  // 2 - Set up text style
  CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
  textStyle.color = [CPTColor grayColor];
  textStyle.fontName = @"Helvetica-Bold";
  textStyle.fontSize = 16.0f;
  
  // 3 - Configure title
  NSString *title = @"THIS IS A GRAPH";
  graph.title = title;
  graph.titleTextStyle = textStyle;
  graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
  graph.titleDisplacement = CGPointMake(0.0f, 20.0f);
  
  // 4 - Set theme
  self.selectedTheme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
  [graph applyTheme: self.selectedTheme];
  
  // 5 - Enable user interactions for plot space
  CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
  plotSpace.allowsUserInteraction = YES;
  
}

-(void) configurePlots {
  // 1 - Get graph and plot space
  CPTGraph *graph = self.hostView.hostedGraph;
  CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
  
  //Setup for plot
  CPTScatterPlot *newplot = [[CPTScatterPlot alloc] init];
  newplot.dataSource = self;
  newplot.identifier = @"NEW";
  CPTColor *newplotColor = [CPTColor redColor];
  
  //Adding plot
  [graph addPlot:newplot toPlotSpace:plotSpace];
  
  //Setting up plotspace
  [plotSpace scaleToFitPlots:[NSArray arrayWithObjects: newplot, nil]];
  CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
  [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
  plotSpace.xRange = xRange;
  CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
  [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
  plotSpace.yRange = yRange;
  
  //Creating styles and symbols
  CPTMutableLineStyle *newplotLineStyle = [newplot.dataLineStyle mutableCopy];
  newplotLineStyle.lineWidth = 2.5;
  newplotLineStyle.lineColor = newplotColor;
  newplot.dataLineStyle = newplotLineStyle;
  
  CPTMutableLineStyle *newplotSymbolLineStyle = [CPTMutableLineStyle lineStyle];
  newplotSymbolLineStyle.lineColor = newplotColor;
  
  CPTPlotSymbol *newplotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
  newplotSymbol.fill = [CPTFill fillWithColor: newplotColor];
  newplotSymbol.lineStyle = newplotLineStyle;
  newplotSymbol.size = CGSizeMake(6.0f, 6.0f);
  newplot.plotSymbol =  newplotSymbol;
  
}

-(void) configureAxes {
  // 1 - Create styles
  CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
  axisTitleStyle.color = [CPTColor grayColor];
  axisTitleStyle.fontName = @"Helvetica-Bold";
  axisTitleStyle.fontSize = 12.0f;
  CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
  axisLineStyle.lineWidth = 2.0f;
  axisLineStyle.lineColor = [CPTColor grayColor];
  CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
  axisTextStyle.color = [CPTColor grayColor];
  axisTextStyle.fontName = @"Helvetica-Bold";
  axisTextStyle.fontSize = 11.0f;
  CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
  tickLineStyle.lineColor = [CPTColor grayColor];
  tickLineStyle.lineWidth = 2.0f;
  CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
  tickLineStyle.lineColor = [CPTColor blackColor];
  tickLineStyle.lineWidth = 1.0f;
  
  // 2 - Get axis set
  CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
  
  // 3 - Configure x axis
  CPTAxis *x = axisSet.xAxis;
  x.axisLineStyle = axisLineStyle;
  x.labelingPolicy = CPTAxisLabelingPolicyNone;
  x.labelTextStyle = axisTextStyle;
  x.majorTickLineStyle = axisLineStyle;
  x.majorTickLength = 4.0f;
  x.tickDirection = CPTSignNegative;
  
  NSUInteger count = xSort.count;
  if (count == 0) {
    return;
  }
  
  CGFloat max = [[xSort objectAtIndex:count-1] floatValue];
  CGFloat min = [[xSort objectAtIndex:0] floatValue];
  CGFloat maxInt = ceil(max);
  CGFloat minInt = ceil(min);
  CGFloat diff = ceil((maxInt - minInt) / count);
  if (maxInt == minInt) {
    diff = 1;
  }
  CGFloat curr = 0;
  
  NSMutableSet *xLabels = [NSMutableSet setWithCapacity:fabs(maxInt+10)];
  NSMutableSet *xLocations = [NSMutableSet setWithCapacity:fabs(maxInt+10)];
  while (fabsf(curr) < fabsf(maxInt + 10)) {
    CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%.1f", curr]  textStyle:x.labelTextStyle];
    CGFloat location = curr;
    label.tickLocation = CPTDecimalFromCGFloat(location);
    label.offset = x.majorTickLength;
    if (label) {
      [xLabels addObject:label];
      [xLocations addObject:[NSNumber numberWithFloat:location]];
    }
    NSLog(@"Computing x axis");
    curr = curr + diff;
  }
  x.axisLabels = xLabels;
  x.majorTickLocations = xLocations;
  
  // 4 - Configure y axis
  CPTAxis *y = axisSet.yAxis;
  y.axisLineStyle = axisLineStyle;
  //y.majorGridLineStyle = gridLineStyle;
  y.labelingPolicy = CPTAxisLabelingPolicyNone;
  y.labelTextStyle = axisTextStyle;
  y.labelOffset = 16.0f;
  y.majorTickLineStyle = axisLineStyle;
  y.majorTickLength = 4.0f;
  y.minorTickLength = 2.0f;
  y.tickDirection = CPTSignPositive;

  count = ySort.count;
  if (count == 0) {
    return;
  }
  
  max = [[ySort objectAtIndex:count-1] floatValue];
  min = [[ySort objectAtIndex:0] floatValue];
  maxInt = ceil(max);
  minInt = ceil(min);
  diff = ceil((maxInt - minInt) / count);
  if (maxInt == minInt) {
    diff = 1;
  }
  curr = 0;
  
  NSMutableSet *yLabels = [NSMutableSet setWithCapacity:fabs(maxInt+10)];
  NSMutableSet *yLocations = [NSMutableSet setWithCapacity:fabs(maxInt+10)];
  while (fabsf(curr) < fabsf(maxInt + 10)) {
    CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%.1f", curr]  textStyle:y.labelTextStyle];
    CGFloat location = curr;
    label.tickLocation = CPTDecimalFromCGFloat(location);
    label.offset = y.majorTickLength;
    if (label) {
      [yLabels addObject:label];
      [yLocations addObject:[NSNumber numberWithFloat:location]];
    }
    NSLog(@"Computing y axis");
    curr = curr + diff;
  }
  y.axisLabels = yLabels;
  y.majorTickLocations = yLocations;
  
}

#pragma mark - Data Table Methods

-(void) initData {
  [self configureDataTable];
  [self configureDataLabels];
  [self configureInput];
  [self configureInputButtons];
}

-(void) configureDataTable {
  // 1 - Create layout for collection view
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
  
  // 2 - Create rect for data space
  CGRect parentRect = self.view.bounds;
  
  //Getting status bar height
  CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
  CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
  
  //Getting tab bar height
  CGFloat tabBarHeight = self.options.bounds.size.height;
  NSLog(@"Tab height: %f", tabBarHeight);
  
  //Changing parent rectangle  -- Switching to hard coded heigh2
  parentRect = CGRectMake(parentRect.origin.x + 50.0, parentRect.origin.y + statusBarHeight + 175.0, parentRect.size.width, 150.0);
  
  // 3 - Allocing collection view
  collectionView = [[UICollectionView alloc] initWithFrame:parentRect collectionViewLayout:flowLayout];
  [collectionView setDataSource:self];
  [collectionView setDataSource:self];
  
  // 4 - Registering classes for reusable cells
  [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
  [collectionView setBackgroundColor:[UIColor grayColor]];
  
  // 5 - Adding subview
  [self.view addSubview:collectionView];

}

-(void) configureDataLabels {
  // 1 - Creating frame for data table label
  CGRect parentRect = self.view.bounds;
  parentRect = CGRectMake(parentRect.origin.x, parentRect.origin.y + 20.0 + 100.0, parentRect.size.width, 75.0);
  UITextView *tableName = [[UITextView alloc] initWithFrame:parentRect];
  
  // 2 - Text manipulation for data label
  tableName.text = @"Data Table";
  tableName.textAlignment = 1;
  tableName.textColor = [UIColor blackColor];
  [tableName setFont:[UIFont systemFontOfSize:35]];
  
  // 3 - Adding subview
  [self.view addSubview:tableName];
  
  // 4 - Creating frame for x label
  parentRect = self.view.bounds;
  parentRect = CGRectMake(parentRect.origin.x, parentRect.origin.y + 20.0 + 175.0, 50.0, 75.0);
  UITextView *xlabel = [[UITextView alloc] initWithFrame:parentRect];
  
  // 5 - Text manipulation for x label
  xlabel.text = @"X";
  xlabel.textAlignment = 1;
  xlabel.textColor = [UIColor blackColor];
  [xlabel setFont:[UIFont systemFontOfSize:35.0]];
  
  // 6 - Creating frame for y label
  parentRect = self.view.bounds;
  parentRect = CGRectMake(parentRect.origin.x, parentRect.origin.y + 20.0 + 175.0 + 100.0, 50.0, 75.0);
  UITextView *ylabel = [[UITextView alloc] initWithFrame:parentRect];
  
  // 7 - Text manipulation for y label
  ylabel.text = @"Y";
  ylabel.textAlignment = 1;
  ylabel.textColor = [UIColor blackColor];
  [ylabel setFont:[UIFont systemFontOfSize:35.0]];
  
  // 8 - Adding subviews
  [self.view addSubview:xlabel];
  [self.view addSubview:ylabel];
}

-(void) configureInput {
  // 1 - Setting up frame for input boxes
  CGRect parentRect = self.view.bounds;
  CGRect xInRect = CGRectMake(parentRect.origin.x + 275.0, parentRect.origin.y + 500.0, 200.0, 75.0);
  CGRect yInRect = CGRectMake(parentRect.origin.x + 525.0, parentRect.origin.y + 500.0, 200.0, 75.0);
  CGRect xInLabelRect = CGRectMake(parentRect.origin.x + 275.0, parentRect.origin.y + 425.0, 200.0, 75.0);
  CGRect yInLabelRect = CGRectMake(parentRect.origin.x + 525.0, parentRect.origin.y + 425.0, 200.0, 75.0);
  xIn = [[UITextField alloc] initWithFrame:xInRect];
  yIn = [[UITextField alloc] initWithFrame:yInRect];
  xIn.delegate = self;
  yIn.delegate = self;
  xIn.keyboardType = UIKeyboardTypeDecimalPad;
  yIn.keyboardType = UIKeyboardTypeDecimalPad;
  UITextView *xInLabel = [[UITextView alloc] initWithFrame:xInLabelRect];
  UITextView *yInLabel = [[UITextView alloc] initWithFrame:yInLabelRect];
  
  // 2 - Text manipulation
  xIn.tag = 0;
  yIn.tag = 1;
  xIn.textAlignment = 1;
  yIn.textAlignment = 1;
  xIn.textColor = [UIColor blackColor];
  yIn.textColor = [UIColor blackColor];
  [xIn setFont:[UIFont systemFontOfSize:35.0]];
  [yIn setFont:[UIFont systemFontOfSize:35.0]];
  xIn.borderStyle = UITextBorderStyleRoundedRect;
  yIn.borderStyle = UITextBorderStyleRoundedRect;
  xInLabel.text = @"Input X";
  yInLabel.text = @"Input Y";
  xInLabel.textAlignment = 1;
  yInLabel.textAlignment = 1;
  xInLabel.textColor = [UIColor blackColor];
  yInLabel.textColor = [UIColor blackColor];
  [xInLabel setFont:[UIFont systemFontOfSize:35.0]];
  [yInLabel setFont:[UIFont systemFontOfSize:35.0]];
  
  // 3 - Adding subviews
  [self.view addSubview:xIn];
  [self.view addSubview:yIn];
  [self.view addSubview:xInLabel];
  [self.view addSubview:yInLabel];
  
  // 4 - Setting check variables to zero
  setX = 0;
  setY = 0;
  
}

-(void) configureInputButtons {
  // 1 - Setting up frame for buttons
  CGRect parentRect = self.view.bounds;
  CGRect addRect = CGRectMake(parentRect.origin.x + 750.0, parentRect.origin.y + 512.5, 75.0, 50.0);
  CGRect delRect = CGRectMake(parentRect.origin.x + 150.0, parentRect.origin.y + 512.5, 75.0, 50.0);
  CGRect sortRect = CGRectMake(parentRect.origin.x + 475.0, parentRect.origin.y + 600.0, 75.0, 50.0);
  addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  delButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  sortButton = [[UISwitch alloc] initWithFrame:sortRect];
  sortButton.on = buttonState.boolValue;
  [addButton setFrame:addRect];
  [delButton setFrame:delRect];
  
  // 2 - Manipluating buttons
  addButton.tag = 0;
  delButton.tag = 1;
  addButton.backgroundColor = [UIColor greenColor];
  delButton.backgroundColor = [UIColor redColor];
  
  // 3 - Setting button call methods
  [self.addButton addTarget:self action:@selector(addButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.delButton addTarget:self action:@selector(delButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.sortButton addTarget:self action:@selector(sortButtonTapped) forControlEvents:UIControlEventValueChanged];
  
  // 4 - Adding Subviews
  [self.view addSubview:addButton];
  [self.view addSubview:delButton];
  [self.view addSubview:sortButton];
  
  
}

#pragma mark - Notificaton methods

//Method to make sure that text was inputted into the text field
- (void)textFieldDidEndEditing:(UITextField *)textField {
  NSLog(@"End editing");
  CGRect parentRect = self.view.bounds;
  if (textField.tag == 0) {
    setX = 1;
    parentRect = CGRectMake(parentRect.origin.x + 275, parentRect.origin.y + 500, self.xIn.bounds.size.width, self.xIn.bounds.size.height);
    [self.xIn setFrame:parentRect];
    
  } else if (textField.tag == 1) {
    setY = 1;
    parentRect = CGRectMake(parentRect.origin.x + 525, parentRect.origin.y + 500, self.yIn.bounds.size.width, self.yIn.bounds.size.height);
    [self.yIn setFrame:parentRect];
  }
}

//Method to move input box higher
-(void) textFieldDidBeginEditing:(UITextField *)textField {
  NSLog(@"Begin edition");
  CGRect parentRect = self.view.bounds;
  if (textField.tag == 0) {
    self.xIn.text = @"";
    parentRect = CGRectMake(parentRect.origin.x + 275, parentRect.origin.y + 345, self.xIn.bounds.size.width, self.xIn.bounds.size.height);
    [self.xIn setFrame:parentRect];
    
  } else if (textField.tag == 1) {
    self.yIn.text = @"";
    parentRect = CGRectMake(parentRect.origin.x + 525, parentRect.origin.y + 345, self.yIn.bounds.size.width, self.yIn.bounds.size.height);
    [self.yIn setFrame:parentRect];
  }
}

#pragma mark - Collection view cell methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return [xVals count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 2;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  // 1 - Ensure that a new cell is gotten
  UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
  
  // 3 - Set up UI View
  CGRect cellRect = cell.frame;
  UITextView *cView = [[UITextView alloc] initWithFrame:cellRect];
  
  // 4 - Get correct content in cell
  id val;
  if (indexPath.section == 0) {    //x section cell
    if (!sortButton.on) {
      val = [xVals objectAtIndex:indexPath.row];
    } else {
      val = [xSort objectAtIndex:indexPath.row];
    }
  } else if (indexPath.section == 1) {    //y section cell
    if (!sortButton.on) {
      val = [yVals objectAtIndex:indexPath.row];
    } else {
      val = [ySort objectAtIndex:indexPath.row];
    }
  } else {
    NSLog(@"Incorrect section occurrance");
    return nil;
  }
  
  // 5 - Put text into UI View
  cView.textAlignment = 1;
  cView.text = (NSString *) val;
  NSUInteger length = [val length];
  if (length == 1) {
      [cView setFont:[UIFont systemFontOfSize: 35]];
  } else if (length == 2) {
      [cView setFont:[UIFont systemFontOfSize: 33]];
  } else if (length == 3) {
      [cView setFont:[UIFont systemFontOfSize: 21]];
  } else {
      [cView setFont:[UIFont systemFontOfSize: 15]];
  }
  
  // 6 - Put UI View into cell
  [cell addSubview:cView];
  
  //NSIndexPath *n = [[NSIndexPath indexPathForRow:<#(NSInteger)#> inSection:<#(NSInteger)#>] init] //
  
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return CGSizeMake(5, 5);
}

#pragma mark - Button Methods

- (void) addButtonTapped: (id) button {
  // 1 - Typecasting to button
  button = (UIButton *) button;
  
  // 2 - Getting content
  NSLog(@"--Add button pressed--");
  NSString *newX = xIn.text;
  NSString *newY = yIn.text;
  NSLog(@"Got %@ , %@", newX, newY);
  
  // 3 - Error checking the input
  NSUInteger xLength = newX.length;
  NSUInteger yLength = newY.length;
  
  if (newX.length == 0|| newY.length == 0) {
    return;
  }
  
  if (xLength == 1 && [newX characterAtIndex:0] == 46) {
    NSLog(@"Invalid input x, not responding");
    return;
  }
  if (yLength == 1 && [newY characterAtIndex:0] == 46) {
    NSLog(@"Invalid input x, not responding");
    return;
  }
  
  for (NSUInteger i = 0; i < xLength; i++) {
    if (([newX characterAtIndex:i] < 48 && [newX characterAtIndex:i] != 46) || [newX characterAtIndex:i] > 57) {
      NSLog(@"Invalid input x, not responding");
      return;
    }
  }
  for (NSUInteger i = 0; i < yLength; i++) {
    if (([newY characterAtIndex:i] < 48 && [newY characterAtIndex:i] != 46) || [newY characterAtIndex:i] > 57) {
      NSLog(@"Invalid input y, not responding");
      return;
    }
  }
  
  // 4 - Adding content to arrays
  [xVals addObject: newX];
  [yVals addObject: newY];
  [xSort addObject: newX];
  [ySort addObject: newY];
  [self sortArrays];
  
  // 5 - Reloading collection view
  [self.collectionView removeFromSuperview];
  [collectionView reloadData];
  [self configureDataTable];
  
}

- (void) delButtonTapped: (id) button {
  // 1 - Typecasting to button
  button = (UIButton *) button;
  
  // 2 - Getting content
  NSLog(@"--Del button pressed--");
  NSString *newX = xIn.text;
  NSString *newY = yIn.text;
  NSLog(@"Got %@ , %@", newX, newY);
  
  // 3 - Error checking the input
  NSUInteger xLength = newX.length;
  NSUInteger yLength = newY.length;
  
  if (xLength == 1 && [newX characterAtIndex:0] == 46) {
    NSLog(@"Invalid input x, not responding");
    return;
  }
  if (yLength == 1 && [newY characterAtIndex:0] == 46) {
    NSLog(@"Invalid input x, not responding");
    return;
  }
  
  for (NSUInteger i = 0; i < xLength; i++) {
    if (([newX characterAtIndex:i] < 48 && [newX characterAtIndex:i] != 46) || [newX characterAtIndex:i] > 57) {
      NSLog(@"Invalid input x, not responding");
      return;
    }
  }
  for (NSUInteger i = 0; i < yLength; i++) {
    if (([newY characterAtIndex:i] < 48 && [newY characterAtIndex:i] != 46) || [newY characterAtIndex:i] > 57) {
      NSLog(@"Invalid input y, not responding");
      return;
    }
  }
  
  // 4 - Deleting content from arrays
  for (NSUInteger i = 0; i < xVals.count; i++) {
    if ([newX isEqualToString:[xVals objectAtIndex:i]] == true && [newY isEqualToString:[yVals objectAtIndex:i]] == true) {
      [xVals removeObjectAtIndex:i];
      [yVals removeObjectAtIndex:i];
      break;
    }
  }
  for (NSUInteger i = 0; i < xSort.count; i++) {
    if ([newX isEqualToString:[xSort objectAtIndex:i]] == true && [newY isEqualToString:[ySort objectAtIndex:i]] == true) {
      [xSort removeObjectAtIndex:i];
      [ySort removeObjectAtIndex:i];
      break;
    }
  }
  
  // 5 - Reloading collection view
  [self.collectionView removeFromSuperview];
  [collectionView reloadData];
  [self configureDataTable];
  
}

- (void) sortButtonTapped {
  // Update internal state
  buttonState = [NSNumber numberWithBool:!buttonState.boolValue];
  
  // Need to reload data table view
  [self.collectionView removeFromSuperview];
  [collectionView reloadData];
  [self configureDataTable];
  
}

#pragma mark - Sorting Methods

- (void) sortArrays {
  // 1 - Getting size of array
  NSUInteger n = [xSort count];
  
  // 2 - Iterating from left to right
  for (NSUInteger i = 0; i < n; i++) {
    // Iterating down the array to bubble sort
    for (NSUInteger j = i; j > 0; j--) {
      if ([[xSort objectAtIndex:j] doubleValue] < [[xSort objectAtIndex: j-1] doubleValue]) {
        // 2.1 - Moving x values
        id temp = [xSort objectAtIndex: j];    //saving j element
        [xSort removeObjectAtIndex: j];    //removing j
        [xSort insertObject:[xSort objectAtIndex: j-1] atIndex: j];    //setting j-1 to j
        [xSort removeObjectAtIndex: j-1];    //removing j-1
        [xSort insertObject:temp atIndex: j-1];    //setting j to j-1
        
        // 2.2 - Moving y values
        temp = [ySort objectAtIndex: j];    //saving j element
        [ySort removeObjectAtIndex: j];    //removing j
        [ySort insertObject:[ySort objectAtIndex: j-1] atIndex: j];    //setting j-1 to j
        [ySort removeObjectAtIndex: j-1];    //removing j-1
        [ySort insertObject:temp atIndex: j-1];    //setting j to j-1
        
      }
      else if ([[xSort objectAtIndex: j] doubleValue] == [[xSort objectAtIndex: j-1] doubleValue]) {
        if ([[ySort objectAtIndex:j] doubleValue] < [[ySort objectAtIndex: j] doubleValue]) {
          // 2.1 - Moving x values
          id temp = [xSort objectAtIndex: j];    //saving j element
          [xSort removeObjectAtIndex: j];    //removing j
          [xSort insertObject:[xSort objectAtIndex: j-1] atIndex: j];    //setting j-1 to j
          [xSort removeObjectAtIndex: j-1];    //removing j-1
          [xSort insertObject:temp atIndex: j-1];    //setting j to j-1
          
          // 2.2 - Moving y values
          temp = [ySort objectAtIndex: j];    //saving j element
          [ySort removeObjectAtIndex: j];    //removing j
          [ySort insertObject:[ySort objectAtIndex: j-1] atIndex: j];    //setting j-1 to j
          [ySort removeObjectAtIndex: j-1];    //removing j-1
          [ySort insertObject:temp atIndex: j-1];    //setting j to j-1
          
        } else {
          break;
        }
      }
      else {
        break;
      }
    }
  }
  
}


#pragma mark - Undraw and redraw methods for labels and input

-(void) unloadLabels {
  // 1 - Removing from view
  [self.addButton removeFromSuperview];
  [self.delButton removeFromSuperview];
  [self.sortButton removeFromSuperview];
  [self.xIn removeFromSuperview];
  [self.yIn removeFromSuperview];
  [self.collectionView removeFromSuperview];
  
}

-(void) reloadLabels {
  // 1 - Putting into view
  [self.view addSubview:collectionView];
  [self.view addSubview:addButton];
  [self.view addSubview:delButton];
  [self.view addSubview:sortButton];
  [self.view addSubview:xIn];
  [self.view addSubview:yIn];
  
}


@end
