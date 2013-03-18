//
//  BIDMapPoint.m
//  Control Fun
//
//  Created by Zakaria on 3/6/13.
//  Copyright (c) 2013 Apress. All rights reserved.
//

#import "BIDMapPoint.h"

@implementation BIDMapPoint
@synthesize title,subTitle,coordinate;


-(id) initWithCoordinate:(CLLocationCoordinate2D) c title:(NSString *) t subTitle:(NSString *) st{
    title = t;
    coordinate = c;
    subTitle = st;
    return self;
}



@end
