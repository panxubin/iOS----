//
//  HMAnnotation.h
//  06-字典跳转和路线规划
//
//  Created by panxubin on 16/8/21.
//  Copyright © 2016年 panxubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface YYAnnotation : NSObject<MKAnnotation>

@property(assign,nonatomic)CLLocationCoordinate2D coordinate;
@end
