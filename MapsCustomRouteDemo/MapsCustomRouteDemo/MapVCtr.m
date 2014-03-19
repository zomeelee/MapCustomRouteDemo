//
//  MapVCtr.m
//  MapsCustomRouteDemo
//
//  Created by SagarRK on 19/03/14.
//  Copyright (c) 2014 atonapps. All rights reserved.
//

#import "MapVCtr.h"
#import "MKPolylineEncodedString.h"
#import "Place.h"
#import "PlaceMark.h"
#import "NSString+HTML.h"

@interface MapVCtr () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *viewOnTheTop;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnLeft;
@property (strong, nonatomic) IBOutlet UIButton *btnRight;
@property (nonatomic, readwrite) NSInteger indexForSteps;
- (IBAction)btnLeftTapped:(id)sender;
- (IBAction)btnRightTapped:(id)sender;
@end

@implementation MapVCtr

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.title = [self.dOfData valueForKey:@"Title"];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView removeOverlays:[self.mapView overlays]];
    [self API_GoogleDirection_DidSuccess:[self.dOfData valueForKeyPath:@"data"]];
}

- (void) API_GoogleDirection_DidSuccess:(NSDictionary *)dictPlaceDetail{
    NSMutableArray *arOfPolylines = [NSMutableArray array];
    if([[dictPlaceDetail valueForKey:@"status"] isEqualToString:@"OK"]) {
        NSArray *arOfRoutes = [dictPlaceDetail valueForKey:@"routes"];
        if(arOfRoutes.count) {
            NSDictionary *dOfRoute = [arOfRoutes objectAtIndex:0];
            NSDictionary *dOfLeg1 = [[dOfRoute valueForKey:@"legs"] objectAtIndex:0];
            NSArray *arOfSteps = [dOfLeg1 valueForKey:@"steps"];
            NSUInteger index = 0;
            for (NSDictionary *dOfStep in arOfSteps) {
                
                // add polyline
                NSDictionary *dOfPolyline = [dOfStep valueForKey:@"polyline"];
                NSString *strPoint = [dOfPolyline valueForKey:@"points"];
                [arOfPolylines addObject:[MKPolyline polylineWithEncodedString:strPoint]];
                
                // add a step on start point of specific step-path
                NSDictionary *dOfCoOrd = [dOfStep valueForKey:@"start_location"];
                CLLocationCoordinate2D coOrd = CLLocationCoordinate2DMake([[dOfCoOrd valueForKey:@"lat"] doubleValue], [[dOfCoOrd valueForKey:@"lng"] doubleValue]);
                NSString *htmlString = [dOfStep valueForKey:@"html_instructions"];
                NSString *summary = [[[htmlString stringByStrippingTags] stringByRemovingNewLinesAndWhitespace] stringByDecodingHTMLEntities];
                
                NSString *strDistance = [NSString stringWithFormat:@"%@ distance", [[dOfStep valueForKey:@"distance"] valueForKey:@"text"]];
                NSString *strDuration = [NSString stringWithFormat:@"%@ duration", [[dOfStep valueForKey:@"duration"] valueForKey:@"text"]];
                
                Place *place = [[Place alloc] init];
                place.latitude = coOrd.latitude;
                place.longitude = coOrd.longitude;
                place.name = summary;
                place.description = [NSString stringWithFormat:@"%@, %@",strDuration, strDistance];
                PlaceMark *placeMark = [[PlaceMark alloc] initWithPlace:place];
                placeMark.index = index++;
                [self.mapView addAnnotation:placeMark];
            }
            
            for (MKPolyline *line in arOfPolylines) {
                [self.mapView addOverlay:line];
            }
            
            [self zoomToFitMapAnnotations:self.mapView];
            self.indexForSteps = -1;
            [self indexHasBeenUpdated];
            
        } else {
            NSLog(@"No route found");
        }
    } else {
        NSLog(@"No route found");
    }
}

# pragma mark - MKMapview delegate methods

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *mapOverlayView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        mapOverlayView.strokeColor = [UIColor redColor];
        mapOverlayView.lineWidth = 3;
        return mapOverlayView;
    }
    return nil;
}

#define mk_imgV         1

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *annotationID = @"annotationID";
    MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationID];
    UIImageView *imgV = nil;
    if (!pinView) {
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationID];
        imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
        imgV.tag = mk_imgV;
        imgV.image = [UIImage imageNamed:@"MapPin"];
        [imgV setContentMode:UIViewContentModeScaleAspectFit];
        [pinView addSubview:imgV];
        pinView.canShowCallout = YES;
    }
    imgV = (UIImageView *)[pinView viewWithTag:mk_imgV];
    imgV.center = CGPointMake(pinView.frame.size.width/2, pinView.frame.size.height/2);
    return pinView;
}

- (void)zoomToFitMapAnnotations:(MKMapView*)aMapView {
    if([aMapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(PlaceMark *annotation in aMapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [aMapView regionThatFits:region];
    [aMapView setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnLeftTapped:(id)sender {
    self.indexForSteps--;
    [self indexHasBeenUpdated];
}

- (IBAction)btnRightTapped:(id)sender {
    self.indexForSteps++;
    [self indexHasBeenUpdated];
}

- (void)indexHasBeenUpdated {
    NSDictionary *dictPlaceDetail = [self.dOfData valueForKeyPath:@"data"];
    NSArray *arOfRoutes = [dictPlaceDetail valueForKey:@"routes"];
    NSDictionary *dOfRoute = [arOfRoutes objectAtIndex:0];
    NSDictionary *dOfLeg1 = [[dOfRoute valueForKey:@"legs"] objectAtIndex:0];
    
    if(self.indexForSteps == -1) {
        NSString *strTitle = [NSString stringWithFormat:@"From: %@",[dOfLeg1 valueForKey:@"start_address"]];
        NSString *strDistance = [NSString stringWithFormat:@"%@ distance", [[dOfLeg1 valueForKey:@"distance"] valueForKey:@"text"]];
        NSString *strDuration = [NSString stringWithFormat:@"%@ duration", [[dOfLeg1 valueForKey:@"duration"] valueForKey:@"text"]];
        NSString *strData = [NSString stringWithFormat:@"%@\n%@, %@",strTitle,strDistance,strDuration];
        
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:strData];
        [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0,strTitle.length)];
        [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(strTitle.length,string.length-strTitle.length)];
        
        self.lblTitle.attributedText = string;
        
        [self zoomToFitMapAnnotations:self.mapView];
        [self.mapView deselectAnnotation:[self.mapView.selectedAnnotations objectAtIndex:0] animated:YES];
        self.btnLeft.enabled = NO;
        self.btnRight.enabled = YES;
    } else if(self.indexForSteps < [self.mapView annotations].count){
        self.btnLeft.enabled = YES;
        self.btnRight.enabled = YES;
        for(PlaceMark *annotation in self.mapView.annotations) {
            if(annotation.index==self.indexForSteps) {
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([annotation coordinate], 1000, 1000);
                [self.mapView setRegion:region animated:YES];
                [self.mapView selectAnnotation:annotation animated:YES];
                NSString *strData = [NSString stringWithFormat:@"%@\n%@",annotation.place.name,annotation.place.description];
                
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:strData];
                [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0,annotation.place.name.length)];
                [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(annotation.place.name.length,string.length-annotation.place.name.length)];
                
                self.lblTitle.attributedText = string;
                
                break;
            }
        }
    } else {
        NSString *strTitle = [NSString stringWithFormat:@"To: %@",[dOfLeg1 valueForKey:@"end_address"]];
        NSString *strDistance = [NSString stringWithFormat:@"%@ distance", [[dOfLeg1 valueForKey:@"distance"] valueForKey:@"text"]];
        NSString *strDuration = [NSString stringWithFormat:@"%@ duration", [[dOfLeg1 valueForKey:@"duration"] valueForKey:@"text"]];
        NSString *strData = [NSString stringWithFormat:@"%@\n%@, %@",strTitle,strDistance,strDuration];
        
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:strData];
        [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:NSMakeRange(0,strTitle.length)];
        [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(strTitle.length,string.length-strTitle.length)];
        
        self.lblTitle.attributedText = string;
        [self zoomToFitMapAnnotations:self.mapView];
        [self.mapView deselectAnnotation:[self.mapView.selectedAnnotations objectAtIndex:0] animated:YES];
        self.btnLeft.enabled = YES;
        self.btnRight.enabled = NO;
    }
}

@end
