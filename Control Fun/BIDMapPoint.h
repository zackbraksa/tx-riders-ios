//
//  BIDMapPoint.h
//  Control Fun
//
//  Created by Zakaria on 3/6/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface BIDMapPoint : NSObject<MKAnnotation> {

    NSString *title;
    NSString *subTitle;
    CLLocationCoordinate2D coordinate;

}

@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subTitle;

-(id) initWithCoordinate:(CLLocationCoordinate2D) c title:(NSString *) t subTitle:(NSString *) st;


@end
