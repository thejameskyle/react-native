/**
 * The examples provided by Facebook are for non-commercial testing and
 * evaluation purposes only.
 *
 * Facebook reserves all rights not expressly granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL
 * FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <XCTest/XCTest.h>

#import <React/RCTUIManager.h>
#import <React/RCTView.h>
#import <React/RCTViewManager.h>

#define RUN_RUNLOOP_WHILE(CONDITION) \
{ \
  NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:5]; \
  while ((CONDITION)) { \
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]; \
    if ([timeout timeIntervalSinceNow] <= 0) { \
      XCTFail(@"Runloop timed out before condition was met"); \
      break; \
    } \
  } \
}

@interface RCTUIManager ()

- (void)createView:(NSNumber *)reactTag
          viewName:(NSString *)viewName
           rootTag:(NSNumber *)rootTag
             props:(NSDictionary *)props;

- (void)updateView:(nonnull NSNumber *)reactTag
          viewName:(NSString *)viewName
             props:(NSDictionary *)props;

@end

@interface RCTPropsTestView : UIView

@property (nonatomic, assign) NSInteger integerProp;
@property (nonatomic, strong) id objectProp;
@property (nonatomic, assign) CGPoint structProp;
@property (nonatomic, copy) NSString *customProp;

@end

@implementation RCTPropsTestView
@end

@interface RCTPropsTestViewManager : RCTViewManager
@end

@implementation RCTPropsTestViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
  RCTPropsTestView *view = [RCTPropsTestView new];
  view.integerProp = 57;
  view.objectProp = @9;
  view.structProp = CGPointMake(5, 6);
  view.customProp = @"Hello";
  return view;
}

RCT_EXPORT_VIEW_PROPERTY(integerProp, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(objectProp, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(structProp, CGPoint)
RCT_CUSTOM_VIEW_PROPERTY(customProp, NSString, RCTPropsTestView)
{
  view.customProp = json ? [RCTConvert NSString:json] : defaultView.customProp;
}

@end

@interface RCTComponentPropsTests : XCTestCase

@end

@implementation RCTComponentPropsTests
{
  RCTBridge *_bridge;
}

- (void)setUp
{
  [super setUp];

  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  _bridge = [[RCTBridge alloc] initWithBundleURL:[bundle URLForResource:@"UIExplorerUnitTestsBundle" withExtension:@"js"]
                                  moduleProvider:nil
                                   launchOptions:nil];
}

- (void)testSetProps
{
  __block RCTPropsTestView *view;
  RCTUIManager *uiManager = _bridge.uiManager;
  NSDictionary *props = @{@"integerProp": @58,
                          @"objectProp": @10,
                          @"structProp": @{@"x": @7, @"y": @8},
                          @"customProp": @"Goodbye"};

  dispatch_async(uiManager.methodQueue, ^{
    [uiManager createView:@2 viewName:@"RCTPropsTestView" rootTag:nil props:props];
    [uiManager addUIBlock:^(__unused RCTUIManager *_uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
      view = (RCTPropsTestView *)viewRegistry[@2];
      XCTAssertEqual(view.integerProp, 58);
      XCTAssertEqualObjects(view.objectProp, @10);
      XCTAssertTrue(CGPointEqualToPoint(view.structProp, CGPointMake(7, 8)));
      XCTAssertEqualObjects(view.customProp, @"Goodbye");
    }];
    [uiManager setNeedsLayout];
  });

  RUN_RUNLOOP_WHILE(view == nil);
}

- (void)testResetProps
{
  __block RCTPropsTestView *view;
  RCTUIManager *uiManager = _bridge.uiManager;
  NSDictionary *props = @{@"integerProp": @58,
                          @"objectProp": @10,
                          @"structProp": @{@"x": @7, @"y": @8},
                          @"customProp": @"Goodbye"};

  NSDictionary *resetProps = @{@"integerProp": [NSNull null],
                               @"objectProp": [NSNull null],
                               @"structProp": [NSNull null],
                               @"customProp": [NSNull null]};

  dispatch_async(uiManager.methodQueue, ^{
    [uiManager createView:@2 viewName:@"RCTPropsTestView" rootTag:nil props:props];
    [uiManager updateView:@2 viewName:@"RCTPropsTestView" props:resetProps];
    [uiManager addUIBlock:^(__unused RCTUIManager *_uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
      view = (RCTPropsTestView *)viewRegistry[@2];
      XCTAssertEqual(view.integerProp, 57);
      XCTAssertEqualObjects(view.objectProp, @9);
      XCTAssertTrue(CGPointEqualToPoint(view.structProp, CGPointMake(5, 6)));
      XCTAssertEqualObjects(view.customProp, @"Hello");
    }];
    [uiManager setNeedsLayout];
  });

  RUN_RUNLOOP_WHILE(view == nil);
}

- (void)testResetBackgroundColor
{
  __block RCTView *view;
  RCTUIManager *uiManager = _bridge.uiManager;
  NSDictionary *props = @{@"backgroundColor": @0xffffffff};
  NSDictionary *resetProps = @{@"backgroundColor": [NSNull null]};

  dispatch_async(uiManager.methodQueue, ^{
    [uiManager createView:@2 viewName:@"RCTView" rootTag:nil props:props];
    [uiManager addUIBlock:^(__unused RCTUIManager *_uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
      view = (RCTView *)viewRegistry[@2];
      XCTAssertEqualObjects(view.backgroundColor, [RCTConvert UIColor:@0xffffffff]);
    }];
    [uiManager updateView:@2 viewName:@"RCTView" props:resetProps];
    [uiManager addUIBlock:^(__unused RCTUIManager *_uiManager, __unused NSDictionary<NSNumber *,UIView *> *viewRegistry) {
      view = (RCTView *)viewRegistry[@2];
      XCTAssertNil(view.backgroundColor);
    }];
    [uiManager setNeedsLayout];
  });

  RUN_RUNLOOP_WHILE(view == nil);
}

@end
