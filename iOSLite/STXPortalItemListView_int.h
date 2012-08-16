//
//  STXPortalItemListView_int.h
//  iOSLite
//
//  Created by Nicholas Furness on 8/15/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#include "STXPortalItemListView.h"

#ifndef iOSLite_STXPortalItemListView_int_h
#define iOSLite_STXPortalItemListView_int_h

@interface STXPortalItemListView ()
// Internal - for use by the PortalItemListViewController only
- (void) ensureItemVisible:(NSString *)portalItemID Highlighted:(BOOL)highlight;
- (NSArray *)portalItems;
@end

#endif
