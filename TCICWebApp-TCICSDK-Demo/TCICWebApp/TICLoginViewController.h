//
//  TICLoginViewController.h
//  TICWebApp
//
//  Created by AlexiChen on 2020/5/11.
//  Copyright © 2020 AlexiChen. All rights reserved.
//

#import "BaseViewController.h"

@class TICTextField;
@interface TICLoginViewController : BaseViewController

@property (nonatomic, weak) IBOutlet TICTextField   *userIdTF;
@property (nonatomic, weak) IBOutlet TICTextField   *classRoomTF;

@end

