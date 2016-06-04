//
//  ViewController.m
//  gaodeTest
//
//  Created by 李金 on 16/6/3.
//  Copyright © 2016年 kingandyoga. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapServices.h>
#import <AMapSearchKit/AMapSearchAPI.h>

#define APIKey @"2e2009dcb1b3d08b60b011b075bc7ebe"

@interface ViewController ()<MAMapViewDelegate,AMapSearchDelegate>{
    MAMapView *_mapView;
    UIButton *_locationButton;
    
    AMapSearchAPI *_search;
    CLLocation *_currentLocation;
    
    //NSMutableArray *_coordinateArray;
}
@property (nonatomic,strong)  NSMutableArray *coordinateArray;

@end

@implementation ViewController

- (void)initButton {
    _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _locationButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - 60 , 150, 50);
    _locationButton.backgroundColor = [UIColor whiteColor];
    _locationButton.layer.cornerRadius = 5;
    [_locationButton setTitle:@"定位" forState:UIControlStateNormal];
    [_locationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_locationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_mapView addSubview:_locationButton];
}

- (void)locationAction{
    NSLog(@"locateAction");
    if (_mapView.userTrackingMode != MAUserTrackingModeFollowWithHeading) {
        [_mapView setUserTrackingMode:MAUserTrackingModeFollowWithHeading animated:YES];
        _mapView.zoomLevel = 250;
       // [_mapView setZoomEnabled:NO];
        //_mapView.distanceFilter = 3;
        
        //_mapView.pausesLocationUpdatesAutomatically = false;
       // _mapView.allowsBackgroundLocationUpdates = true;

    }
}

- (void)initMapView {
    [AMapServices sharedServices].apiKey = APIKey;
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)  )];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    [_mapView setUserInteractionEnabled:YES];
    
    
    [self.view addSubview:_mapView];
    
}

- (void)initSearch{
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.coordinateArray = [[NSMutableArray alloc]init];
  
    [self initMapView];
    [self initButton];
    [self initSearch];
   
}


- (void)reGeoAction{
    if (_currentLocation) {
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc]init];
        
        request.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
        [_search AMapReGoecodeSearch:request];
    }
}

#pragma mark -AMapSearchDelegate

-(void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSLog(@"request :%@ ,error:%@",request,error);
}

-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    
    NSLog(@"response :%@ ",response);
    
    NSString *title = response.regeocode.addressComponent.city;
    if (title.length == 0) {
        title = response.regeocode.addressComponent.province;
    }
    
    NSLog(@"%@",title);
    _mapView.userLocation.title = title;
    _mapView.userLocation.subtitle = response.regeocode.formattedAddress;
    //_mapView.userLocation.title = @"SBBSBSBSBBSSBS";
}




#pragma mark -delegate

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
    NSLog(@"userlocation: %@",userLocation.location);
    _currentLocation = [userLocation.location copy];
    if (updatingLocation) {
        CLLocation *newLocation = userLocation.location;
        [_coordinateArray addObject:newLocation];
        [self updatePath];
    }
    
}

-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    if ([view.annotation isKindOfClass:[MAUserLocation class]]) {
        [self reGeoAction];
    }
}


-(void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated{
    
}


-(MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay{
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAOverlayPathView *polylineView = [[MAPolylineView alloc]initWithPolyline:overlay];
        
        polylineView.lineWidth = 6;
        polylineView.strokeColor = [UIColor redColor];
        return polylineView;
        
    }
    return nil;
}


#pragma mark -draw
-(void)updatePath{
    NSArray *overlays = [_mapView.overlays copy];
    [_mapView removeOverlays:overlays];
    
    if (_coordinateArray.count < 2) {
        CLLocation *location = [_coordinateArray lastObject];
        [_mapView setCenterCoordinate:location.coordinate];
        return;
    }
    
    for (NSInteger i = 0; i<_coordinateArray.count - 1; i++) {
        CLLocation *last = [_coordinateArray objectAtIndex:i];
        CLLocation *next = [_coordinateArray objectAtIndex:i+1];
        CLLocationCoordinate2D coords[2];
        CLLocationCoordinate2D tranformValue0  = last.coordinate;
        CLLocationCoordinate2D tranformValue1 = next.coordinate;
        
        coords[0] = tranformValue0;
        coords[1] = tranformValue1;
    
        
        [_mapView addOverlay:[MAPolyline polylineWithCoordinates:coords count:2]];

    }
    CLLocation *location = [_coordinateArray lastObject];
    [_mapView setCenterCoordinate:location.coordinate];
    
}

@end
