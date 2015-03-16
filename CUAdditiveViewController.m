//
//  CUAdditiveViewController.m
//  CoreAnimationExample
//
//  Created by yuguang on 30/6/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import "CUAdditiveViewController.h"

//#define USING_UIKIT 1



typedef NS_OPTIONS(NSUInteger, CUAnimationType) {
    CUAnimationTypeNone,
    CUAnimationTypeAdditive,
    CUAnimationTypeBeginFromCurrentState
};

@interface CUAdditiveViewController ()
@property (weak, nonatomic) IBOutlet UIView *pragressView;

@property(weak, nonatomic) IBOutlet UIImageView *imageViewLeft;
@property(weak, nonatomic) IBOutlet UIImageView *imageViewCenter;
@property(weak, nonatomic) IBOutlet UIImageView *imageViewRight;


@property(strong,nonatomic) CAShapeLayer *shapelayer;//环
@property(strong,nonatomic) UIBezierPath *path;

@property(strong,nonatomic) CAShapeLayer *dotlayer;//点
@property(strong,nonatomic) UIBezierPath *dotpath;

@end

@implementation CUAdditiveViewController
{
  BOOL _isForwardLeft;
  BOOL _isForwardCenter;
  BOOL _isForwardRight;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  self.imageViewLeft.backgroundColor = [UIColor redColor];
  self.imageViewCenter.backgroundColor = [UIColor blueColor];
  self.imageViewRight.backgroundColor = [UIColor greenColor];
    
    [self initProgressView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)animationClicked:(id)sender {
    
    [self drawCircle];
  
#ifdef USING_UIKIT
  
  static BOOL bTest = NO;
  [self UIKitAnimation:bTest];
  [self  UIKitAnimationDefault:bTest];
  bTest = !bTest;
  
#else
  
  [self animateType:CUAnimationTypeNone inLayer:self.imageViewLeft.layer];
  [self animateType:CUAnimationTypeAdditive inLayer:self.imageViewCenter.layer];
  [self animateType:CUAnimationTypeBeginFromCurrentState inLayer:self.imageViewRight.layer];
  
#endif
}

- (void)UIKitAnimation:(BOOL)isReverse
{
  if (!isReverse) {
    [UIView animateWithDuration:1.0f
                     animations:^{
                       self.imageViewRight.center = CGPointMake(self.imageViewRight.center.x, 500);
                     }];
  }
  else
  {
    [UIView animateWithDuration:1.0f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                     animations:^{
                       self.imageViewRight.center = CGPointMake(self.imageViewRight.center.x, 88);
                     } completion:^(BOOL finished) {
                     }];
  }
}

- (void)UIKitAnimationDefault:(BOOL)isReverse
{
  if (!isReverse) {
    [UIView animateWithDuration:1.0f
                     animations:^{
                       self.imageViewLeft.center = CGPointMake(self.imageViewLeft.center.x, 500);
                     }];
  }
  else
  {
    [UIView animateWithDuration:1.0f
                     animations:^{
                       self.imageViewLeft.center = CGPointMake(self.imageViewLeft.center.x, 88);
                     } completion:^(BOOL finished) {
                     }];
  }
}

- (void)animateType:(CUAnimationType)type inLayer:(CALayer *)animationLayer {
  
  NSNumber *fromValue = @88;
  NSNumber *toValue = @500;
  NSNumber *endValue = toValue;
  CABasicAnimation *animation = [CABasicAnimation animation];
  animation.keyPath = @"position.y";
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  animation.duration = 1; //modify better
  
  switch (type) {
  case CUAnimationTypeNone: {
    
    if (!_isForwardLeft) {
      _isForwardLeft = YES;
      animation.fromValue = fromValue;
      animation.toValue = toValue;
      endValue = toValue;
    }
    else {
      _isForwardLeft = NO;
      animation.fromValue = toValue;
      animation.toValue = fromValue;
      endValue = fromValue;
    }
    
    animationLayer.position = CGPointMake(animationLayer.position.x, [endValue intValue]);
    
    NSString *key = [NSString stringWithFormat:@"ani"];
    [animationLayer addAnimation:animation forKey:key];
  }
      break;
  case CUAnimationTypeAdditive: {
    
    if (!_isForwardCenter) {
      _isForwardCenter = YES;
      animation.fromValue = @([fromValue intValue] - [toValue intValue]);
    }
    else {
      _isForwardCenter = NO;
      animation.fromValue = @([toValue intValue] - [fromValue intValue]);
      endValue = fromValue;
    }
    
    animation.toValue = @(0);
    animation.additive = YES;

    animationLayer.position = CGPointMake(animationLayer.position.x, [endValue intValue]);
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :0 :.5 :1]; // better easing function
    
    static NSUInteger number = 0; // use nil key or integer, not [NSDate date] because string description only shows seconds
    NSString *key = [NSString stringWithFormat:@"ani_%lu", (unsigned long)number++];
    
    [animationLayer addAnimation:animation forKey:key];
  }
      break;
  case CUAnimationTypeBeginFromCurrentState: {
    if (!_isForwardRight) {
      _isForwardRight = YES;
      animation.fromValue = @([animationLayer.presentationLayer position].y);
      animation.toValue = toValue;
      endValue = toValue;
    }
    else {
      _isForwardRight = NO;
      animation.fromValue = @([animationLayer.presentationLayer position].y);
      animation.toValue = fromValue;
      endValue = fromValue;
    }
    
    animationLayer.position = CGPointMake(animationLayer.position.x, [endValue intValue]);
    
    NSString *key = [NSString stringWithFormat:@"ani"];
    [animationLayer addAnimation:animation forKey:key];
  }
      break;

  default:
    break;
  }
}

- (void)timeProc
{
  
}

-(void)initProgressView
{
    _shapelayer = [[CAShapeLayer alloc] init];
    _path = [[UIBezierPath alloc] init];
    [_path addArcWithCenter:CGPointMake(50, 50) radius:(CGFloat)40 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [_shapelayer setPath:_path.CGPath];
    _shapelayer.lineCap = kCALineCapRound;
//    _shapelayer.lineJoin = kCALineCapRound;
//    _shapelayer.lineJoin = kCALineJoinMiter;
//    _shapelayer.lineJoin = kCALineJoinRound;
//    _shapelayer.lineJoin = kCALineJoinBevel;
//    _shapelayer.lineCap = kCALineCapSquare;
    _shapelayer.lineWidth = 10.0;
    [_pragressView.layer addSublayer:_shapelayer];
    [_shapelayer setFillColor:[UIColor clearColor].CGColor];
    [_shapelayer setStrokeColor:[UIColor blueColor].CGColor];
    
    
    //点初始化
    _dotlayer = [[CAShapeLayer alloc] init];
    _dotpath = [[UIBezierPath alloc] init];
    [_dotpath addArcWithCenter:CGPointMake(0, 0) radius:3 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [_dotlayer setFillColor:[UIColor redColor].CGColor];
    [_dotlayer setPath:_dotpath.CGPath];
    [_pragressView.layer addSublayer:_dotlayer];
    
    CGRect frame = _dotlayer.frame;
}

- (void)drawCircle
{
    //基础动画
//    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//    pathAnimation.duration = 5.0;
//    pathAnimation.fromValue = @(0.25);
//    pathAnimation.toValue = @(0.5);
//    pathAnimation.removedOnCompletion = YES;
//    
//    [self.shapelayer addAnimation:pathAnimation forKey:nil];
    
    
    //关键帧动画
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    keyAnimation.duration = 10.0;
    keyAnimation.values = @[@(0.0),@(0.5),@(0.65),@(1.0)];
    keyAnimation.keyTimes = @[@(0.0),@(0.1),@(0.8),@(1.0)];
    keyAnimation.removedOnCompletion = YES;
    
    [self.shapelayer addAnimation:keyAnimation forKey:nil];
    
    
    //点移动动画
    //keyPath是@"position"，说明要修改的是CALayer的position属性，也就是会执行平移动画
    CAKeyframeAnimation *keyAnimation1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *positionPath = [[UIBezierPath alloc] init];
    [positionPath addArcWithCenter:CGPointMake(50, 50) radius:40 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [keyAnimation1 setPath:positionPath.CGPath];
    keyAnimation1.duration = 10.0;
    keyAnimation1.values = @[@(0.0),@(0.3),@(0.5),@(0.65),@(1)];
    keyAnimation1.keyTimes = @[@(0.0),@(0.1),@(0.5),@(0.7),@(1.0)];
    //1.2设置动画执行完毕之后删除动画
    keyAnimation1.removedOnCompletion=NO;
    //1.3设置保存动画的最新状态
    keyAnimation1.fillMode=kCAFillModeForwards;
    //设置动画监听代理
    keyAnimation1.delegate = self;
    
    [self.dotlayer addAnimation:keyAnimation1 forKey:nil];
    
    CALayer *gradientlayer = [[CALayer alloc] init];
    CAGradientLayer *gradientlayer1 = [[CAGradientLayer alloc] init];
    [gradientlayer1 setColors:[NSArray arrayWithObjects:(id)[[UIColor redColor] CGColor],(id)[[UIColor orangeColor] CGColor], nil]];
    gradientlayer1.frame = CGRectMake(0, 50, 50, 50);
    [gradientlayer1 setLocations:@[@0.0,@0.5,@1]];
    [gradientlayer1 setStartPoint:CGPointMake(0, 1)];
    [gradientlayer1 setEndPoint:CGPointMake(0, 0)];
    [gradientlayer addSublayer:gradientlayer1];
    
    CAGradientLayer *gradientlayer2 = [[CAGradientLayer alloc] init];
    [gradientlayer2 setColors:[NSArray arrayWithObjects:(id)[[UIColor orangeColor] CGColor],(id)[[UIColor yellowColor] CGColor], nil]];
    gradientlayer2.frame = CGRectMake(0, 0, 50, 50);
    [gradientlayer2 setLocations:@[@0.0,@0.5,@1]];
    [gradientlayer2 setStartPoint:CGPointMake(0, 1)];
    [gradientlayer2 setEndPoint:CGPointMake(0, 0)];
    [gradientlayer addSublayer:gradientlayer2];
    
    CAGradientLayer *gradientlayer3 = [[CAGradientLayer alloc] init];
    [gradientlayer3 setColors:[NSArray arrayWithObjects:(id)[[UIColor yellowColor] CGColor],(id)[[UIColor blueColor] CGColor], nil]];
    gradientlayer3.frame = CGRectMake(50, 0, 50, 50);
    [gradientlayer3 setLocations:@[@0.0,@0.5,@1]];
    [gradientlayer3 setStartPoint:CGPointMake(0, 0)];
    [gradientlayer3 setEndPoint:CGPointMake(0, 1)];
    [gradientlayer addSublayer:gradientlayer3];
    
    CAGradientLayer *gradientlayer4 = [[CAGradientLayer alloc] init];
    [gradientlayer4 setColors:[NSArray arrayWithObjects:(id)[[UIColor blueColor] CGColor],(id)[[UIColor redColor] CGColor], nil]];
    gradientlayer4.frame = CGRectMake(50, 50, 50, 50);
    [gradientlayer4 setLocations:@[@0.0,@0.5,@1]];
    [gradientlayer4 setStartPoint:CGPointMake(0, 0)];
    [gradientlayer4 setEndPoint:CGPointMake(0, 1)];
    [gradientlayer addSublayer:gradientlayer4];
    
    
    [gradientlayer setMask:_shapelayer];
    [self.pragressView.layer insertSublayer:gradientlayer atIndex:0];
    
    
    
//    [CATransaction setDisableActions:NO];    //  设置是否启动隐式动画
//    [CATransaction setAnimationDuration:1];
//    _shapelayer.cornerRadius = (_shapelayer.cornerRadius == 0.0f) ? 30.0f : 0.0f;    //   设置圆角
//    _shapelayer.opacity = (_shapelayer.opacity == 1.0f) ? 0.5f : 1.0f;   // 设置透明度
    
    
//    [CATransaction begin];
//    
//    //显式事务默认开启动画效果,kCFBooleanTrue关闭
//    [CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
//    
//    //动画执行时间
//    [CATransaction setValue:[NSNumber numberWithFloat:5.0f] forKey:kCATransactionAnimationDuration];
//////[CATransaction setAnimationDuration:[NSNumber numberWithFloat:5.0f]];
////    
////    layer.cornerRadius = (layer.cornerRadius == 0.0f) ? 30.0f : 0.0f;
////    layer.opacity = (layer.opacity == 1.0f) ? 0.5f : 1.0f;
//    
//    [_path addArcWithCenter:CGPointMake(50, 50)
//                     radius:(CGFloat)40
//                 startAngle:M_PI*0
//                   endAngle:M_PI*1.5
//                  clockwise:YES];
//    [_shapelayer setPath:_path.CGPath];
//    
//    [CATransaction commit];

}

-(void)animationDidStart:(CAAnimation *)anim
{
    //动画开始...do something
    NSLog(@"动画开始");
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //动画结束...do something
    NSLog(@"动画结束");
}

@end
