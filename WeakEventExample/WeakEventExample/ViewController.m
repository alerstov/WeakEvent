//
//  ViewController.m
//  WeakEventExample
//
//  Created by Alexander Stepanov on 10/12/15.
//  Copyright © 2015 Alexander Stepanov. All rights reserved.
//

#import "ViewController.h"
#import "WeakEvent.h"

@interface Button : UIButton
EVENT_DECL(Click, id sender);
@end

@implementation Button

EVENT_IMPL(Click)

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)click:(id)sender
{
    EVENT_RAISE(Click, sender);
}

@end


@interface ViewController ()
@property (nonatomic) id clickToken;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    Button* button = [[Button alloc]initWithFrame:CGRectMake(50, 50, 100, 50)];
    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"click" forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    EVENT_ADD(button, onClick:^(id sender), {
        NSLog(@"click 1");
    });
    
    self.clickToken = EVENT_ADD(button, onClick:^(id sender), {
        NSLog(@"click 2");
        EVENT_REMOVE(self.clickToken);
    });
}

@end
