//
//  ViewController.m
//  06-字典跳转和路线规划
//
//  Created by panxubin on 16/8/20.
//  Copyright © 2016年 panxubin. All rights reserved.
//  地图跳转是跳转到系统的应用中去。

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "YYAnnotation.h"

@interface ViewController ()<MKMapViewDelegate>

@property(strong,nonatomic)MKMapItem *mapItem;

//编码工具
@property(strong,nonatomic)CLGeocoder *geocoder;

@property(weak,nonatomic)MKMapView *mapView;

//用于发送请求给服务器
@property(strong,nonatomic)MKDirections *direct;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    添加一个地图到界面上
    MKMapView *mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:mapView];
    mapView.delegate = self;
    self.mapView = mapView;
    
//    添加一个视图
    
    //   提供两个点，自动规划线路
    _geocoder = [[CLGeocoder alloc]init];
    
    [_geocoder geocodeAddressString:@"白石洲" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        
        MKPlacemark *placemark = [[MKPlacemark alloc]initWithPlacemark:placemarks.lastObject];
        //intrItem可以理解为地图上的一个点
        MKMapItem *intrItem = [[MKMapItem alloc]initWithPlacemark:placemark];
        
//        添加一个小别针到地图上
        YYAnnotation *anno = [[YYAnnotation alloc]init];
        anno.coordinate = intrItem.placemark.location.coordinate;
        [self.mapView addAnnotation:anno];
        
        // 让地图跳转到起点所在的区域
        MKCoordinateRegion region = MKCoordinateRegionMake(intrItem.placemark.location.coordinate, MKCoordinateSpanMake(0.1, 0.1));
        [self.mapView setRegion:region];
        
        //创建终点
        [_geocoder geocodeAddressString:@"深圳北站" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
            //destItem可以理解为地图上的一个点
            MKMapItem *destItem = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithPlacemark:[placemarks lastObject]]];
            
            
            //        添加一个小别针到地图上
            YYAnnotation *anno = [[YYAnnotation alloc]init];
            anno.coordinate = destItem.placemark.location.coordinate;
            [self.mapView addAnnotation:anno];
            
            //调用下面方法发送请求
            [self moveWith:intrItem toDestination:destItem];
        }];
    }];
}


//提供两个点，在地图上进行规划的方法
-(void)moveWith:(MKMapItem *)formPlce toDestination:(MKMapItem *)endPlace{

//    创建请求体
    // 创建请求体 (起点与终点)
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = formPlce;
    request.destination = endPlace;
    
    self.direct = [[MKDirections alloc]initWithRequest:request];

    // 计算路线规划信息 (向服务器发请求)
    [self.direct calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        
        //获取到所有路线
        NSArray <MKRoute *> *routesArray = response.routes;
        //取出最后一条路线
        MKRoute *rute = routesArray.lastObject;
        
        //路线中的每一步
        NSArray <MKRouteStep *>*stepsArray = rute.steps;
        
        //遍历
        for (MKRouteStep *step in stepsArray) {
            
            [self.mapView addOverlay:step.polyline];
        }
        // 收响应结果 MKDirectionsResponse
        // MKRoute 表示的一条完整的路线信息 (从起点到终点) (包含多个步骤)
    }];

}

// 返回指定的遮盖模型所对应的遮盖视图, renderer-渲染
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    // 判断类型
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        // 针对线段, 系统有提供好的遮盖视图
        MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        
        // 配置，遮盖线的颜色
        render.lineWidth = 5;
        render.strokeColor =  [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1.0];
        
        return render;
    }
    // 返回nil, 是没有默认效果
    return nil;
}




@end
