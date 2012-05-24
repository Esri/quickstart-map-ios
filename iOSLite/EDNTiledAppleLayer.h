//
//  EDNTiledAppleLayer.h
//  MapTest1
//
//  Created by Nicholas Furness on 3/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface EDNTiledAppleLayer : AGSTiledLayer
-(id)init;
-(NSArray *) LODS;
@end
