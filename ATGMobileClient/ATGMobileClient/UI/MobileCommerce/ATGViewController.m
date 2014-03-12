/*<ORACLECOPYRIGHT>
 * Copyright (C) 1994-2013 Oracle and/or its affiliates. All rights reserved.
 * Oracle and Java are registered trademarks of Oracle and/or its affiliates.
 * Other names may be trademarks of their respective owners.
 * UNIX is a registered trademark of The Open Group.
 *
 * This software and related documentation are provided under a license agreement
 * containing restrictions on use and disclosure and are protected by intellectual property laws.
 * Except as expressly permitted in your license agreement or allowed by law, you may not use, copy,
 * reproduce, translate, broadcast, modify, license, transmit, distribute, exhibit, perform, publish,
 * or display any part, in any form, or by any means. Reverse engineering, disassembly,
 * or decompilation of this software, unless required by law for interoperability, is prohibited.
 *
 * The information contained herein is subject to change without notice and is not warranted to be error-free.
 * If you find any errors, please report them to us in writing.
 *
 * U.S. GOVERNMENT RIGHTS Programs, software, databases, and related documentation and technical data delivered to U.S.
 * Government customers are "commercial computer software" or "commercial technical data" pursuant to the applicable
 * Federal Acquisition Regulation and agency-specific supplemental regulations.
 * As such, the use, duplication, disclosure, modification, and adaptation shall be subject to the restrictions and
 * license terms set forth in the applicable Government contract, and, to the extent applicable by the terms of the
 * Government contract, the additional rights set forth in FAR 52.227-19, Commercial Computer Software License
 * (December 2007). Oracle America, Inc., 500 Oracle Parkway, Redwood City, CA 94065.
 *
 * This software or hardware is developed for general use in a variety of information management applications.
 * It is not developed or intended for use in any inherently dangerous applications, including applications that
 * may create a risk of personal injury. If you use this software or hardware in dangerous applications,
 * then you shall be responsible to take all appropriate fail-safe, backup, redundancy,
 * and other measures to ensure its safe use. Oracle Corporation and its affiliates disclaim any liability for any
 * damages caused by use of this software or hardware in dangerous applications.
 *
 * This software or hardware and documentation may provide access to or information on content,
 * products, and services from third parties. Oracle Corporation and its affiliates are not responsible for and
 * expressly disclaim all warranties of any kind with respect to third-party content, products, and services.
 * Oracle Corporation and its affiliates will not be responsible for any loss, costs,
 * or damages incurred due to your access to or use of third-party content, products, or services.
   </ORACLECOPYRIGHT>*/

#import "ATGViewController.h"

#pragma mark - ATGViewController private protocol declaration
#pragma mark -

@interface ATGViewController ()

#pragma mark - Custom properties
@property (nonatomic, strong)  NSMutableDictionary *errors;

@end

#pragma mark - ATGViewController implementation
#pragma mark -

@implementation ATGViewController
#pragma mark - Synthesized properties
@synthesize activityIndicator, errors;

+ (void) _startActivityIndication:(BOOL)pModal controller:(UIViewController *)pController indicator:(UIActivityIndicatorView *)pIndicator {
  if (!pIndicator) {
    pIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    pIndicator.center = pController.view.center;
    [pController performSelector:@selector(setActivityIndicator:) withObject:pIndicator];
  }

  SEL setter = @selector(setScrollEnabled:);
  if ([pController.view respondsToSelector:setter]) {
    [(UIScrollView *)pController.view setScrollEnabled:NO];
  }
  ;

  if (pModal) {
    ATGActionBlocker *blocker = [ATGActionBlocker sharedModalBlocker];
    if ([self isPad]) {
      CGSize size = pController.contentSizeForViewInPopover;
      [blocker showBlockView:pIndicator withFrame:CGRectMake(0, 0, size.width, size.height) withTarget:nil andAction:NULL forView:pController.view];
    } else {
      [blocker showView:pIndicator withTarged:nil andAction:nil];
      CGFloat y = [[UIApplication sharedApplication] statusBarFrame].size.height;
      if (!pController.navigationController.navigationBarHidden) {
        y += pController.navigationController.navigationBar.frame.size.height;
      }
      CGFloat height = [UIScreen mainScreen].bounds.size.height - y;
      if (!pController.navigationController.toolbarHidden) {
        height -= pController.navigationController.toolbar.frame.size.height;
      }
      blocker.frame = CGRectMake(0, y, 320, height);
    }
    pIndicator.center = CGPointMake(blocker.frame.size.width / 2, blocker.frame.size.height / 2);
    //change color to white in iOS5
    if ([pIndicator respondsToSelector:@selector(setColor:)]) {
      pIndicator.color = [UIColor activityIndicatorColor];
    }
  } else {
    [pController.view addSubview:pIndicator];
    pIndicator.center = pController.view.center;
    //change color to grey in iOS5
    if ([pIndicator respondsToSelector:@selector(setColor:)]) {
      pIndicator.color = [UIColor activityIndicatorDarkColor];
    }
  }

  [pIndicator startAnimating];
}

+ (void) _stopActivityIndication:(UIViewController *)pController indicator:(UIActivityIndicatorView *)pIndicator {
  [pIndicator stopAnimating];
  [[ATGActionBlocker sharedModalBlocker] dismissBlockView];
  SEL setter = @selector(setScrollEnabled:);
  if ([pController.view respondsToSelector:setter]) {
    [(UIScrollView *)pController.view setScrollEnabled:YES];
  }
  ;

  //non-modal
  if ([pIndicator superview]) {
    [pIndicator removeFromSuperview];
  }
}

#pragma mark - View controller


- (void) viewWillDisappear:(BOOL)pAnimated {
  [super viewWillDisappear:pAnimated];
  [self stopActivityIndication];
}

- (void) viewDidUnload {
  self.errors = nil;
  activityIndicator = nil;
  [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)pInterfaceOrientation {
  return (pInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGSize) contentSizeForViewInPopover {
  return CGSizeMake(320, 480);
}

- (void) requiresLogin {
  [self presentLoginViewControllerAnimated:YES];
}

- (void) setErrors:(NSArray *)pErrors inSection:(NSInteger)pSection {
  if (![self errors]) {
    self.errors = [[NSMutableDictionary alloc] init];
  }
  if (pErrors) {
    [[self errors] setObject:pErrors forKey:[NSNumber numberWithInteger:pSection]];
  } else {
    [[self errors] removeObjectForKey:[NSNumber numberWithInteger:pSection]];
  }
}

- (NSArray *) errorsInSection:(NSInteger)pSection {
  return [[self errors] objectForKey:[NSNumber numberWithInteger:pSection]];
}

- (void) startActivityIndication:(BOOL)pModal {
  [ATGViewController _startActivityIndication:pModal controller:self indicator:self.activityIndicator];
}

- (void) stopActivityIndication {
  [ATGViewController _stopActivityIndication:self indicator:self.activityIndicator];
}

- (void) reloadData {
  //noop stub
}

@end