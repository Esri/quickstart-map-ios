//
//  UILabel+EQSAutoSizeMultiline.m
//  iOSLite
//
//  Created by Nicholas Furness on 5/23/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "UILabel+EQSAutoSizeMultiline.h"

@implementation UILabel (EQSAutoSizeMultiline)
CGFloat __eqsAutoSizeMaxFontSize = -1;

- (void) setFontSizeToFit
{
	/* This is where we define the ideal font that the Label wants to use.
	 Use the font you want to use and the largest font size you want to use. */
	UIFont *baseFont = self.font;
	UIFont *workingFont = nil;
	
	if (__eqsAutoSizeMaxFontSize == -1)
	{
		__eqsAutoSizeMaxFontSize = baseFont.pointSize;
	}
	
	/* Time to calculate the needed font size.
	 This for loop starts at the largest font size, and decreases by two point sizes (i=i-2)
	 Until it either hits a size that will fit or hits the minimum size we want to allow (i > 10) */
	for(int i = __eqsAutoSizeMaxFontSize; i > self.minimumFontSize; i=i-2)
	{
		// Set the new font size.
		workingFont = [baseFont fontWithSize:i];
		// You can log the size you're trying: NSLog(@"Trying size: %u", i);
		
		/* This step is important: We make a constraint box 
		 using only the fixed WIDTH of the UILabel. The height will
		 be checked later. */ 
		CGSize constraintSize = CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT);
		
		// This step checks how tall the label would be with the desired font.
		CGSize labelSize = [self.text sizeWithFont:workingFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		
		/* Here is where you use the height requirement!
		 Set the value in the if statement to the height of your UILabel
		 If the label fits into your required height, it will break the loop
		 and use that font size. */
		if(labelSize.height <= CGRectGetHeight(self.frame))
			break;
	}
	// You can see what size the function is using by outputting: NSLog(@"Best size is: %u", i);
	
	// Set the UILabel's font to the newly adjusted font.
	if (workingFont != nil)
	{
		self.font = workingFont;
	}
}
@end