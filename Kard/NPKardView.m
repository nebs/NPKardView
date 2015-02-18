#import "NPKardView.h"

static const CGFloat kNPKardViewAngleScale = 7.0;

@interface NPKardView ()

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat halfWidth;
@property (nonatomic) CGFloat halfHeight;

@end

@implementation NPKardView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.width = CGRectGetWidth(self.frame);
    self.height = CGRectGetHeight(self.frame);
    self.halfWidth = self.width / 2.0;
    self.halfHeight = self.height / 2.0;

    self.layer.allowsEdgeAntialiasing = YES;
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = 0.9;
    self.layer.shadowOpacity = 0.4;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self rotateForTouchPoint:[[touches anyObject] locationInView:self] animated:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self rotateForTouchPoint:[[touches anyObject] locationInView:self] animated:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self resetRotation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self resetRotation];
}

#pragma mark - Rotation

- (void)resetRotation {
    [UIView animateWithDuration:0.2 animations:^{
        self.layer.transform = CATransform3DIdentity;
    }];
}

- (void)rotateForTouchPoint:(CGPoint)touchPoint animated:(BOOL)animated {
    /*
     Vector 'a' is the user's touch relative to the center.
     Vector 'b' is the rotation vector which is orthogonal to 'a'.

     Given 'a' we find 'b' using a dot product. We fix 'bx' to some
     value in the opposing quadrant then solve for 'by' using the
     dot product:

     ax * bx + ay * by = 0
     by = - (ax * bx) / ay


             |
        o    |
     (bx, by)|    o (ax, ay)
             |
     -----------------
             |
             |
             |
             |
     */

    // Shift the touch vector to the center
    CGFloat ax = touchPoint.x - self.halfWidth;
    CGFloat ay = touchPoint.y - self.halfHeight;

    // Calculate the 'b' vector
    CGFloat factor = ax > 0.0 ? -1.0 : 1.0;
    CGFloat bx = ax + (factor * self.width);
    CGFloat by = - (ax * bx) / ay;

    // The rotation angle is proportial to 'a's distance from the center
    CGFloat magnitude = sqrtf((ax * ax) + (ay * ay));
    CGFloat angleScale = (ax < 0) == (ay < 0) ? kNPKardViewAngleScale : -kNPKardViewAngleScale;
    CGFloat angle = (magnitude / self.halfWidth) * angleScale;

    // Apply the rotation
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -500;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, angle * M_PI / 180.0f, bx, by, 0.0);

    if (animated) {
        self.layer.transform = rotationAndPerspectiveTransform;
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.layer.transform = rotationAndPerspectiveTransform;
        }];
    }
}

@end
