//
//  MKPolylineEncodedString.h
//  DriverApp
//
//  Created by Helios on 12/11/13.
//  Copyright (c) 2013 Helios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MKPolyline (MKPolyline_EncodedString)
+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString;
@end
