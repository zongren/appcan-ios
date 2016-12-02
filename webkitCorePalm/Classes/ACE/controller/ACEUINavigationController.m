/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
#import "ACEUINavigationController.h"
#import "BUtility.h"
#import "ACEConfigXML.h"
#import "ACEBaseViewController.h"
#import "EBrowserController.h"
#import "WWidget.h"
#import "ACEViewControllerAnimator.h"
#import "ACEWebViewController.h"
#import "EBrowserWindow.h"
@interface ACEUINavigationController ()<UINavigationControllerDelegate>

@end

@implementation ACEUINavigationController


- (void)closeChildViewController:(UIViewController *)childController animated:(BOOL)animated{
    NSArray *controllers = self.childViewControllers;
    for (NSInteger i = controllers.count - 2; i >= 0 ; i--) {
        if (controllers[i + 1] == childController) {
            [self popToViewController:controllers[i] animated:animated];
            return;
        }
    }
}



- (instancetype)initWithEBrowserController:(EBrowserController *)rootController{
    self = [super initWithRootViewController:rootController];
    if (self) {
        
        [self setNavigationBarHidden:YES];
        _supportedOrientation = rootController.widget.orientation;
        _rootController = rootController;
        self.delegate = self;
        
    }
    return self;
}



- (BOOL)prefersStatusBarHidden{
    for (ACEBaseViewController *controller in self.viewControllers.reverseObjectEnumerator) {
        if (![controller isKindOfClass:[ACEBaseViewController class]]) {
            continue;
        }
        if (controller.shouldHideStatusBarNumber) {
            return controller.shouldHideStatusBarNumber.boolValue;
        }
    }
    return [super preferredStatusBarStyle];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    for (ACEBaseViewController *controller in self.viewControllers.reverseObjectEnumerator) {
        if (![controller isKindOfClass:[ACEBaseViewController class]]) {
            continue;
        }
        if (controller.statusBarStyleNumber) {
            return controller.statusBarStyleNumber.integerValue;
        }
    }
    return [super preferredStatusBarStyle];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return ace_interfaceOrientationMaskFromACEInterfaceOrientation(self.supportedOrientation);
}

- (BOOL)shouldAutorotate{
    if (self.rotateOnce) {
        self.rotateOnce = NO;
        return YES;
    }
    return self.canAutoRotate;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if (self.presentOrientationNumber) {
        return self.presentOrientationNumber.integerValue;
    }
    UIInterfaceOrientationMask mask = self.supportedInterfaceOrientations;
    if (mask & UIInterfaceOrientationMaskPortrait) {
        return UIInterfaceOrientationPortrait;
    }
    if (mask & UIInterfaceOrientationMaskLandscapeRight) {
        return UIInterfaceOrientationLandscapeRight;
    }
    if (mask & UIInterfaceOrientationMaskLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    return UIInterfaceOrientationPortraitUpsideDown;

}

#pragma mark - UINavigationControllerDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC{
    
    
    switch (operation) {
        case UINavigationControllerOperationPush:{
            if (![toVC isKindOfClass:[ACEWebViewController class]]) {
                return nil;
            }

            EBrowserWindow *window = [(ACEWebViewController *)toVC browserWindow];
            return [ACEViewControllerAnimator openingAnimatorWithAnimationID:window.openAnimationID duration:window.openAnimationDuration config:window.openAnimationConfig];
        }
        case UINavigationControllerOperationPop:{
            if (![fromVC isKindOfClass:[ACEWebViewController class]]) {
                return nil;
            }
            
            EBrowserWindow *window = [(ACEWebViewController *)fromVC browserWindow];
            return [ACEViewControllerAnimator closingAnimatorWithAnimationID:window.openAnimationID duration:window.openAnimationDuration config:window.openAnimationConfig];
            
        }
        default:
            return nil;
    }
}


                    
                    
@end
