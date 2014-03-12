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

#import "ATGAssemblerConnectionManager.h"
#import "ATGAssemblerConnectionURLBuilder.h"

static EMConnectionManager *connectionManager = nil;

NSString *const ENDECA_SERVER_HOST_KEY = @"ATG_REST_SERVER_HOST";
NSString *const ENDECA_SERVER_PORT_KEY = @"ATG_REST_SERVER_PORT";

NSString *const ENDECA_CONTEXT_PATH_KEY = @"ENDECA_CONTEXT_PATH";

@implementation ATGAssemblerConnectionManager

+ (EMConnectionManager *) sharedManager {
  static dispatch_once_t pred_atg_assembler_connection_manager;
  dispatch_once(&pred_atg_assembler_connection_manager,
                ^{
                  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                  
                  NSString *host = [defaults stringForKey:ENDECA_SERVER_HOST_KEY];
                  NSInteger port = [defaults integerForKey:ENDECA_SERVER_PORT_KEY];
                  
                  NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                  NSString *contextPath = [infoDictionary objectForKey:ENDECA_CONTEXT_PATH_KEY];
                  
                  ATGAssemblerConnectionURLBuilder *urlBuilder = [[ATGAssemblerConnectionURLBuilder alloc] init];
                  connectionManager = [[self alloc] initWithHost:host port:port contextPath:contextPath urlBuilder: urlBuilder];
                  
                  [[NSNotificationCenter defaultCenter] addObserver:connectionManager
                                                           selector:@selector(defaultsDidChange:)
                                                               name:NSUserDefaultsDidChangeNotification
                                                             object:nil];
                }
                );
  return connectionManager;
}

- (void)defaultsDidChange:(NSNotification *)pNotification {
  [self updateConnectionFromDefaults:[pNotification object]];
}

- (void)updateConnectionFromDefaults:(NSUserDefaults *)pDefaults {
  NSString *host = [pDefaults stringForKey:ENDECA_SERVER_HOST_KEY];
  NSInteger port = [pDefaults integerForKey:ENDECA_SERVER_PORT_KEY];
  
  ATGAssemblerConnectionURLBuilder *urlBuilder = [[ATGAssemblerConnectionURLBuilder alloc] init];
  
  connectionManager.connection = [EMAssemblerConnection connectionWithHost:host port:port contextPath:connectionManager.connection.contextPath responseFormat:EMAssemblerResponseFormatJSON urlBuilder:urlBuilder];
}

- (void) resetContextPath {
  ATGAssemblerConnectionURLBuilder *urlBuilder = [[ATGAssemblerConnectionURLBuilder alloc] init];

  NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
  NSString *contextPath = [infoDictionary objectForKey:ENDECA_CONTEXT_PATH_KEY];
  connectionManager.connection = [EMAssemblerConnection connectionWithHost:connectionManager.connection.host port:connectionManager.connection.port contextPath:contextPath responseFormat:EMAssemblerResponseFormatJSON urlBuilder:urlBuilder];
}

@end
