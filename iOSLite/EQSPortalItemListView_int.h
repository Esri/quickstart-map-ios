//
//  EQSPortalItemListView_int.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/15/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#include "EQSPortalItemListView.h"

#ifndef iOSLite_EQSPortalItemListView_int_h
#define iOSLite_EQSPortalItemListView_int_h

@interface EQSPortalItemListView ()
// Internal - for use by the PortalItemListViewController only
- (void) ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight;
- (NSArray *)portalItems;
- (NSArray *)portalItemViews;
@end

#endif
