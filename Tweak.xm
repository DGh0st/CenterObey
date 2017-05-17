@interface CCUIControlCenterPageControl : UIPageControl
@end

@interface CCUIControlCenterViewController
-(id)sortedVisibleViewControllers;
-(void)scrollToPage:(NSInteger)arg1 animated:(BOOL)arg2 withCompletion:(id)arg3;
@end

@interface SBControlCenterController
-(void)updatePage:(CGPoint)arg1;
@end

@interface SBNotificationCenterViewController
-(void)updatePage:(CGPoint)arg1;
-(BOOL)isGrabberLocked;
@end

@interface SBModeViewController
-(NSArray *)viewControllers;
@end

@interface SBNotificationCenterLayoutViewController
-(SBModeViewController *)modeViewController;
@end

@interface SBPagedScrollView : UIScrollView
-(NSInteger)currentPageIndex;
-(void)setCurrentPageIndex:(NSInteger)arg1;
-(BOOL)scrollToPageAtIndex:(NSInteger)arg1 animated:(BOOL)arg2;
-(NSArray *)pageViews;
@end

SBPagedScrollView *pageScrollView = nil;

%hook SBControlCenterController
-(CGFloat)_controlCenterHeightForTouchLocation:(CGPoint)arg1 initialTouchLocation:(CGPoint)arg2 {
	if (arg2.y > [[%c(UIScreen) mainScreen] bounds].size.height * 9 / 10)
		[self updatePage:arg1];
	return %orig(arg1, arg2);
}

%new
-(void)updatePage:(CGPoint)arg1 {
	CCUIControlCenterViewController *_viewController = MSHookIvar<CCUIControlCenterViewController *>(self, "_viewController");
	CCUIControlCenterPageControl *_pageControl = MSHookIvar<CCUIControlCenterPageControl *>(_viewController, "_pageControl");

	CGFloat sizes = [[%c(UIScreen) mainScreen] bounds].size.width / [[_viewController sortedVisibleViewControllers] count];
	NSInteger pageIndex = arg1.x / sizes;

	if (_pageControl.currentPage != pageIndex) {
		[_viewController scrollToPage:pageIndex animated:NO withCompletion:nil];
	}
}
%end

// The NC portion is mostly copied from Lace (https://github.com/Nosskirneh/Lace)
%hook SBNotificationCenterViewController
-(BOOL)shouldPlayFeedbackForNewTouchLocation:(CGPoint)arg1 velocity:(CGPoint)arg2 {
	[self updatePage:arg1];
	return %orig(arg1, arg2);
}

%new
-(void)updatePage:(CGPoint)arg1 {
	CGFloat sizes = [[%c(UIScreen) mainScreen] bounds].size.width / [[pageScrollView pageViews] count];
	NSInteger pageIndex = arg1.x / sizes;

	if ([pageScrollView currentPageIndex] != pageIndex) {
		[pageScrollView scrollToPageAtIndex:pageIndex animated:NO];
		[pageScrollView setCurrentPageIndex:pageIndex];
	}
}
%end

%hook SBPagedScrollView
-(id)initWithFrame:(CGRect)arg1 {
	if (!pageScrollView && CGRectIsEmpty(arg1)) {
		return pageScrollView = %orig(arg1);
	}
	return %orig(arg1);
}
%end