//
//  EDNMapViewLite+Basemaps.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/9/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSMapView+Basemaps.h"

@interface AGSMapView()
//@property (nonatomic, retain) AGSPortal *portal;
//@property (nonatomic, retain) NSMutableArray *basemaps;
//@property (nonatomic, retain) NSMutableDictionary *webMaps;
//@property (nonatomic, retain) NSMutableDictionary *mapViews;
//@property (nonatomic, retain) AGSMapView *tempMapView;
@end

@implementation AGSMapView (Basemaps)
//@synthesize portal = _portal;
//@synthesize basemaps = _basemaps;
//@synthesize mapViews = _mapViews;
//@synthesize webMaps = _webMaps;
//@synthesize tempMapView = _tempMapView;

//- (void) portalDidLoad:(AGSPortal *)portal
//{
//    // Let's load the basemaps...
//    AGSPortalQueryParams *params = [AGSPortalQueryParams queryParamsWithQuery:self.portal.portalInfo.basemapGalleryGroupQuery];
//    [self.portal findGroupsWithQueryParams:params];
//}
//
//- (void) portal:(AGSPortal *)portal didFailToLoadWithError:(NSError *)error
//{
//    NSLog(@"Failed to load portal: %@", error);
//}
//
//- (void) portal:(AGSPortal *)portal operation:(NSOperation *)op didFindGroups:(AGSPortalQueryResultSet *)resultSet
//{
//    AGSPortalGroup *basemapsGroup = [resultSet.results objectAtIndex:0];
//    AGSPortalQueryParams *params = [AGSPortalQueryParams queryParamsForItemsOfType:AGSPortalItemTypeWebMap inGroup:basemapsGroup.groupId];
//    [self.portal findItemsWithQueryParams:params];
//}
//
//- (void) portal:(AGSPortal *)portal operation:(NSOperation *)op didFindItems:(AGSPortalQueryResultSet *)resultSet
//{
//    NSLog(@"Query Results for '%@'", resultSet.queryParams.query);
//    
////    if (self.mapViews == nil)
////    {
////        self.mapViews = [NSMutableDictionary dictionary];
////    }
////
////    if (self.webMaps == nil)
////    {
////        self.webMaps = [NSMutableDictionary dictionary];
////    }
////
////    if (self.basemaps == nil)
////    {
////        self.basemaps = [NSMutableArray array];
////    }
//    
////    for (AGSPortalItem *basemap in resultSet.results)
////    {
////        NSLog(@"Found a basemap: %@ (%@)", basemap.title, basemap.thumbnailFileName);
////        [self.basemaps addObject:basemap];
////        
////        AGSMapView *tempMapView = [[AGSMapView alloc] init];
////        [self.mapViews setValue:tempMapView forKey:basemap.title];
////
////        AGSWebMap *webMap = [AGSWebMap webMapWithPortalItem:basemap];
////        AGSWebMapBaseMap *bm = webMap.baseMap;
////
////        for (AGSWebMapLayerInfo *wmli in bm.baseMapLayers)
////        {
////            NSLog(@"Layer %@ %@]", webMap.portalItem.title, wmli.URL);
////        }
////
////        [webMap openIntoMapView:tempMapView];
////        webMap.delegate = self;
////        [self.webMaps setValue:webMap forKey:basemap.title];
////    }
//}
//
//- (void) webMapDidLoad:(AGSWebMap *)webMap
//{
//    NSLog(@"Portal WebMap Loaded: %@", webMap.portalItem.title);
//    AGSWebMapBaseMap *bm = webMap.baseMap;
//    for (AGSWebMapLayerInfo *wmli in bm.baseMapLayers)
//    {
//        NSLog(@"Layer %@ %@]", webMap.portalItem.title, wmli.URL);
//    }
//    
////    [self.mapViews removeObjectForKey:webMap.portalItem.title];
////    [self.webMaps removeObjectForKey:webMap.portalItem.title];
//}
//
//- (void) webMap:(AGSWebMap *)webMap didFailToLoadWithError:(NSError *)error
//{
//    NSLog(@"Failed to load: %@", webMap.portalItem.title);
//}
//
//- (void) portal:(AGSPortal *)portal operation:(NSOperation *)op didFailToFindItemsForQueryParams:(AGSPortalQueryParams *)queryParams withError:(NSError *)error
//{
//    NSLog(@"Failed to load portal items for query: %@\nWith Error: %@", queryParams.query, error);
//}


@end
