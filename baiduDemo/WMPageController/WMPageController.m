//
//  WMPageController.m
//  WMPageController
//
//  Created by Mark on 15/6/11.
//  Copyright (c) 2015年 yq. All rights reserved.
//

#import "WMPageController.h"
#import "WMPageConst.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件

#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件

#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件

#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
//反编码
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "myTableViewCell.h"
#import "firstViewController.h"
#import "secondViewController.h"
#import "threeViewController.h"
#import "AppDelegate.h"
#define XK_COL_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kScreenSize [UIScreen mainScreen].bounds.size
@interface WMPageController () <WMMenuViewDelegate,UIScrollViewDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKPoiSearchDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate> {
    CGFloat viewHeight;
    CGFloat viewWidth;
    BOOL    animate;
}
@property (nonatomic,strong)BMKMapView* mapView;
@property (nonatomic,strong)BMKLocationService* locService;
@property (nonatomic,strong)BMKGeoCodeSearch* geocodesearch;
@property (nonatomic)CGFloat longlation;
@property (nonatomic)CGFloat latilation;
@property (nonatomic,strong)BMKPoiSearch* poisearch;
@property (nonatomic ,strong)NSMutableArray *sourceArr;
@property (nonatomic ,strong) firstViewController *first;
@property (nonatomic ,strong)UIView *backView;
@property (nonatomic)int aaa;
@property (nonatomic, strong, readwrite) UIViewController *currentViewController;
@property (nonatomic, weak) WMMenuView *menuView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property(nonatomic ,strong) UITableView     *tableview;
@property(nonatomic ,strong) NSMutableArray *sourceArr1;//搜索数据源

// 用于记录子控制器view的frame，用于 scrollView 上的展示的位置
@property (nonatomic, strong) NSMutableArray *childViewFrames;
// 当前展示在屏幕上的控制器，方便在滚动的时候读取 (避免不必要计算)
@property (nonatomic, strong) NSMutableDictionary *displayVC;
// 用于记录销毁的viewController的位置 (如果它是某一种scrollView的Controller的话)
@property (nonatomic, strong) NSMutableDictionary *posRecords;
// 用于缓存加载过的控制器
@property (nonatomic, strong) NSCache *memCache;
// 收到内存警告的次数
@property (nonatomic, assign) int memoryWarningCount;
@end

@implementation WMPageController
- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
    if (_geocodesearch != nil) {
        _geocodesearch = nil;
    }
}
#pragma mark - Lazy Loading
- (NSMutableDictionary *)posRecords {
    if (_posRecords == nil) {
        _posRecords = [[NSMutableDictionary alloc] init];
    }
    return _posRecords;
}
- (NSMutableDictionary *)displayVC {
    if (_displayVC == nil) {
        _displayVC = [[NSMutableDictionary alloc] init];
    }
    return _displayVC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"地图demo";
    _sourceArr1 = [[NSMutableArray alloc]init];
    self.view.backgroundColor =[UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self addScrollView];
    [self addMenuView];
    [self createLeftItem];
    [self addViewControllerAtIndex:self.selectIndex];
    //地图
    _sourceArr =[[NSMutableArray alloc]init];
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, kScreenSize.width, 300)];
    [_mapView setZoomLevel:17];
    _mapView.isSelectedAnnotationViewFront = YES;
    [self.view addSubview:_mapView];
    _locService = [[BMKLocationService alloc]init];
    [self beginLoad];
    
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    
    _poisearch = [[BMKPoiSearch alloc]init];
    
    _aaa = 0;
    [self createLeftItem1];
    [self creatUiSearchbar];
}
-(void)creatUiSearchbar{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 35)];//allocate titleView
    UIColor *color =  self.navigationController.navigationBar.barTintColor;
    
    [titleView setBackgroundColor:color];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.tag = 1000;
    searchBar.delegate = self;
    searchBar.frame = CGRectMake(0, 0, 200, 35);
    searchBar.backgroundColor = color;
    searchBar.layer.cornerRadius = 18;
    searchBar.layer.masksToBounds = YES;
    [searchBar.layer setBorderWidth:8];
    [searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];  //设置边框为白色
    
    searchBar.placeholder = @"|写字楼/小区/学校";
    [titleView addSubview:searchBar];
    
    //Set to titleView
    [self.navigationItem.titleView sizeToFit];
    self.navigationItem.titleView = titleView;

}
#pragma mark 实时变化
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text isEqualToString:@""]) {
         NSLog(@"333333333333333333333333333333");
        [_backView removeFromSuperview];
        [searchBar resignFirstResponder];

    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"111111111111111111111111111111111111");
}
#pragma mark 点击search实现搜索结果
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"22222222222222222222222222222222222222");
    BMKNearbySearchOption *citySearchOption = [[BMKNearbySearchOption alloc]init];
    citySearchOption.location = CLLocationCoordinate2D{_latilation,_longlation};
    citySearchOption.radius = 10000;
    citySearchOption.sortType = BMK_POI_SORT_BY_DISTANCE;
    citySearchOption.pageIndex = 0;
    citySearchOption.pageCapacity = 30;
    citySearchOption.keyword = searchBar.text;
    BOOL flag = [_poisearch poiSearchNearBy:citySearchOption];
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
        _aaa=3;
        [self creatBackView];
    }
    else
    {
        NSLog(@"城市内检索发送失败");
    }

}
-(void)creatBackView{
    _backView =[[UIView alloc]initWithFrame:CGRectMake(0, 64, kScreenSize.width, kScreenSize.height-64)];
    _backView.backgroundColor=XK_COL_RGB(0xf2f2f2);
    AppDelegate * appdelegte = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appdelegte.window addSubview:_backView];
    [self creatTableview];
}
//创建搜索列表
-(void)creatTableview{
    
    _tableview                = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,kScreenSize.width,kScreenSize.height-64) style:UITableViewStylePlain];
    _tableview.delegate       = self;
    _tableview.dataSource     = self;//设置代理
    _tableview.backgroundColor = [UIColor colorWithRed:242/255.f green:242/255.f blue:242/255.f alpha:1.0];
    //    _tableview.separatorColor = XK_COL_RGB(0xe1e1e1);
    //允许多项选择 默认是no；默认是单选
    _tableview.allowsMultipleSelection = YES;
    //取消多余的cell
    _tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];//取消多余行数
    [_tableview registerClass:[myTableViewCell class] forCellReuseIdentifier:@"myTableViewCell"];
    [_backView addSubview:_tableview];
    
}
//返回几组数据
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//每组有多少个
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_sourceArr.count ==0) {
        [self creatImgaeView];
    }
    return _sourceArr.count;
}
-(void)creatImgaeView{
    UILabel *Label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
    Label.text = @"暂无数据";
    Label.textColor= XK_COL_RGB(0x111111);
    Label.textAlignment = NSTextAlignmentLeft;
    Label.center = _backView.center;
    Label.font =[UIFont systemFontOfSize:15];
    [_backView addSubview:Label];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    myTableViewCell *cell              = [tableView dequeueReusableCellWithIdentifier:@"myTableViewCell" forIndexPath:indexPath];
    BMKPoiInfo* poi = _sourceArr[indexPath.row];
    [cell showMessagewithName:poi.name andAddress:poi.address andIndex:indexPath.row];
    return cell;
}
//选中事件 有反应
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消了一直高亮
    [_tableview deselectRowAtIndexPath:indexPath animated:YES];
    [_backView removeFromSuperview];
    BMKPoiInfo* poi = _sourceArr[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backSource" object:poi];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


//地图
#pragma mark 定位处理
-(void)button:(NSString *)name{
    BMKNearbySearchOption *citySearchOption = [[BMKNearbySearchOption alloc]init];
    citySearchOption.location = CLLocationCoordinate2D{_latilation,_longlation};
    citySearchOption.radius = 10000;
    citySearchOption.sortType = BMK_POI_SORT_BY_DISTANCE;
    citySearchOption.pageIndex = 0;
    citySearchOption.pageCapacity = 30;
    citySearchOption.keyword = name;
    BOOL flag = [_poisearch poiSearchNearBy:citySearchOption];
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
    }
    else
    {
        NSLog(@"城市内检索发送失败");
    }
}


#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"正在加载搜索数据");
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    [_sourceArr removeAllObjects];
    NSLog(@"请求结果：%d",error);
    if (error == BMK_SEARCH_NO_ERROR) {
        NSLog(@"请求数据成功");
        NSMutableArray *annotations = [NSMutableArray array];
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            [_sourceArr addObject:poi];
            NSLog(@"%@=%@",poi.name,poi.address);
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [annotations addObject:item];
        }
        if (_aaa==0) {
            NSLog(@"请求了第一列数据");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"first" object:_sourceArr];
        }else if (_aaa==1){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"first" object:_sourceArr];
        }else if (_aaa==2){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"first" object:_sourceArr];
        }else{
            NSLog(@"搜索出来的数据:%@",_sourceArr);
            [_tableview reloadData];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"first" object:_sourceArr];
        }
        
        [_mapView addAnnotations:annotations];
        [_mapView showAnnotations:annotations animated:YES];
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
        NSLog(@"其他情况");
    }
}

-(void)beginLoad{
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    _longlation =userLocation.location.coordinate.longitude;
    _latilation =userLocation.location.coordinate.latitude;
    [_mapView updateLocationData:userLocation];

    
        if (_longlation >0) {
            NSLog(@"有地理位置了");
            NSLog(@"=%@=",[[NSUserDefaults standardUserDefaults] objectForKey:@"longLation"]);
           if (![[NSUserDefaults standardUserDefaults] objectForKey:@"longLation"]) {
               NSLog(@"第一次进来页面");
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"longLation"];
               [self button:@"写字楼"];
        }
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _poisearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil; // 不用时，置nil
    _poisearch.delegate = nil; // 不用时，置nil
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"longLation"];
    [_backView removeFromSuperview];

    
}













#pragma mark - Public Methods
- (instancetype)initWithViewControllerClasses:(NSArray *)classes andTheirTitles:(NSArray *)titles {
    if (self = [super init]) {
        NSAssert(classes.count == titles.count, @"classes.count != titles.count");
        self.viewControllerClasses = [NSArray arrayWithArray:classes];
        self.titles = [NSArray arrayWithArray:titles];

        [self setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setCachePolicy:(WMPageControllerCachePolicy)cachePolicy {
    _cachePolicy = cachePolicy;
    self.memCache.countLimit = _cachePolicy;
}

- (void)setItemsWidths:(NSArray *)itemsWidths {
    NSAssert(itemsWidths.count == self.titles.count, @"itemsWidths.count != self.titles.count");
    _itemsWidths = itemsWidths;
}

- (void)setSelectIndex:(int)selectIndex {
    _selectIndex = selectIndex;
    if (self.menuView) {
        [self.menuView selectItemAtIndex:selectIndex];
    }
}

#pragma mark - Private Methods

// 当子控制器init完成时发送通知
- (void)postAddToSuperViewNotificationWithIndex:(int)index {
    if (!self.postNotification) return;
    NSDictionary *info = @{
                           @"index":@(index),
                           @"title":self.titles[index]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:WMControllerDidAddToSuperViewNotification
                                                        object:info];
}

// 当子控制器完全展示在user面前时发送通知
- (void)postFullyDisplayedNotificationWithCurrentIndex:(int)index {
    NSLog(@"++++%d+++",index);
    _aaa =index;
    if (index ==0) {
    [self button:@"写字楼"];
    }else if (index ==1){
    [self button:@"小区"];
    }else{
     [self button:@"学校"];
    }
    
    if (!self.postNotification) return;
    NSDictionary *info = @{
                           @"index":@(index),
                           @"title":self.titles[index]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:WMControllerDidFullyDisplayedNotification
                                                        object:info];
}

// 初始化一些参数，在init中调用
- (void)setup {
    // title
    self.titleSizeSelected = WMTitleSizeSelected;
    self.titleColorSelected = WMTitleColorSelected;
    self.titleSizeNormal = WMTitleSizeNormal;
    self.titleColorNormal = WMTitleColorNormal;
    // menu
    self.menuBGColor = WMMenuBGColor;
    self.menuHeight = WMMenuHeight;
    self.menuItemWidth = WMMenuItemWidth;
    // cache
    self.memCache = [[NSCache alloc] init];
}

// 包括宽高，子控制器视图frame
- (void)calculateSize {
    viewHeight = self.view.frame.size.height - self.menuHeight;
    viewWidth = self.view.frame.size.width;
    // 重新计算各个控制器视图的宽高
    _childViewFrames = [NSMutableArray array];
    for (int i = 0; i < self.viewControllerClasses.count; i++) {
        CGRect frame = CGRectMake(i*viewWidth, 0, viewWidth, viewHeight);
        [_childViewFrames addObject:[NSValue valueWithCGRect:frame]];
    }
}

- (void)addScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)addMenuView {
    CGRect frame = CGRectMake(0, 300, self.view.frame.size.width, 40);//上面小导航的高
    WMMenuView *menuView = [[WMMenuView alloc] initWithFrame:frame buttonItems:self.titles backgroundColor:self.menuBGColor norSize:self.titleSizeNormal selSize:self.titleSizeSelected norColor:self.titleColorNormal selColor:self.titleColorSelected];
    menuView.delegate = self;
    menuView.style = self.menuViewStyle;
    if (self.titleFontName) {
        menuView.fontName = self.titleFontName;
    }
    if (self.progressColor) {
        menuView.lineColor = self.progressColor;
    }
    [self.view addSubview:menuView];
    self.menuView = menuView;
    // 如果设置了初始选择的序号，那么选中该item
    if (self.selectIndex != 0) {
        [self.menuView selectItemAtIndex:self.selectIndex];
    }
}

- (void)layoutChildViewControllers {
    int currentPage = (int)self.scrollView.contentOffset.x / viewWidth;
    int start,end;
    if (currentPage == 0) {
        start = currentPage;
        end = currentPage + 1;
    }else if (currentPage + 1 == self.viewControllerClasses.count){
        start = currentPage - 1;
        end = currentPage;
    }else{
        start = currentPage - 1;
        end = currentPage + 1;
    }
    for (int i = start; i <= end; i++) {
        CGRect frame = [self.childViewFrames[i] CGRectValue];
        UIViewController *vc = [self.displayVC objectForKey:@(i)];
        if ([self isInScreen:frame]) {
            if (vc == nil) {
                // 先从 cache 中取
                vc = [self.memCache objectForKey:@(i)];
                if (vc) {
                    // cache 中存在，添加到 scrollView 上，并放入display
                    [self addCachedViewController:vc atIndex:i];
                }else{
                    // cache 中也不存在，创建并添加到display
                    [self addViewControllerAtIndex:i];
                }
                [self postAddToSuperViewNotificationWithIndex:i];
            }
        }else{
            if (vc) {
                // vc不在视野中且存在，移除他
                [self removeViewController:vc atIndex:i];
            }
        }
    }
}

- (void)addCachedViewController:(UIViewController *)viewController atIndex:(NSInteger)index {

    [self addChildViewController:viewController];
    viewController.view.frame = [self.childViewFrames[index] CGRectValue];
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    [self.displayVC setObject:viewController forKey:@(index)];
}

// 添加子控制器
- (void)addViewControllerAtIndex:(int)index {
    Class vcClass = self.viewControllerClasses[index];
    UIViewController *viewController  = nil;
    if ([self.viewControllerClasses[index] isKindOfClass:[UIViewController class]]) {
        viewController = self.viewControllerClasses[index];
    }else{
        viewController = [[vcClass alloc] init];
    }
    [self addChildViewController:viewController];
    viewController.view.frame = [self.childViewFrames[index] CGRectValue];
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    [self.displayVC setObject:viewController forKey:@(index)];
    
    [self backToPositionIfNeeded:viewController atIndex:index];
}

// 移除控制器，且从display中移除
- (void)removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self rememberPositionIfNeeded:viewController atIndex:index];
//    [viewController.view removeFromSuperview];
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [self.displayVC removeObjectForKey:@(index)];
    
    // 放入缓存
    if (![self.memCache objectForKey:@(index)]) {
        [self.memCache setObject:viewController forKey:@(index)];
    }
}

- (void)backToPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if (!self.rememberLocation) return;
#pragma clang diagnostic pop
    if ([self.memCache objectForKey:@(index)]) return;
    UIScrollView *scrollView = [self isKindOfScrollViewController:controller];
    if (scrollView) {
        NSValue *pointValue = self.posRecords[@(index)];
        if (pointValue) {
            CGPoint pos = [pointValue CGPointValue];
            // 奇怪的现象，我发现collectionView的contentSize是 {0, 0};
            [scrollView setContentOffset:pos];
        }
    }
}

- (void)rememberPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if (!self.rememberLocation) return;
#pragma clang diagnostic pop
    UIScrollView *scrollView = [self isKindOfScrollViewController:controller];
    if (scrollView) {
        CGPoint pos = scrollView.contentOffset;
        self.posRecords[@(index)] = [NSValue valueWithCGPoint:pos];
    }
}

- (UIScrollView *)isKindOfScrollViewController:(UIViewController *)controller {
    UIScrollView *scrollView = nil;
    if ([controller.view isKindOfClass:[UIScrollView class]]) {
        // Controller的view是scrollView的子类(UITableViewController/UIViewController替换view为scrollView)
        scrollView = (UIScrollView *)controller.view;
    }else if (controller.view.subviews.count >= 1) {
        // Controller的view的subViews[0]存在且是scrollView的子类，并且frame等与view得frame(UICollectionViewController/UIViewController添加UIScrollView)
        UIView *view = controller.view.subviews[0];
        if ([view isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)view;
        }
    }
    return scrollView;
}

- (BOOL)isInScreen:(CGRect)frame {
    CGFloat x = frame.origin.x;
    CGFloat ScreenWidth = self.scrollView.frame.size.width;
    
    CGFloat contentOffsetX = self.scrollView.contentOffset.x;
    if (CGRectGetMaxX(frame) > contentOffsetX && x-contentOffsetX < ScreenWidth) {
        return YES;
    }else{
        return NO;
    }
}

- (void)resetMenuView {
    WMMenuView *oldMenuView = self.menuView;
    [self addMenuView];
    [oldMenuView removeFromSuperview];
}

- (void)growCachePolicyAfterMemoryWarning {
    self.cachePolicy = WMPageControllerCachePolicyBalanced;
    [self performSelector:@selector(growCachePolicyToHigh) withObject:nil afterDelay:2.0];
}

- (void)growCachePolicyToHigh {
    self.cachePolicy = WMPageControllerCachePolicyHigh;
}

#pragma mark - Life Cycle
#pragma mark - 导航栏返回按钮
- (void)createLeftItem{
    UIButton *backButton =[UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame=CGRectMake(10, 20, 12, 20);
    [backButton setBackgroundImage:[UIImage imageNamed:@"nav_back11"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightbutton1=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem=rightbutton1;
}


- (void)backButton{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 计算宽高及子控制器的视图frame
    [self calculateSize];
    CGRect scrollFrame = CGRectMake(0, self.menuHeight+300, viewWidth, viewHeight);
    self.scrollView.frame = scrollFrame;
    self.scrollView.contentSize = CGSizeMake(self.titles.count*viewWidth, viewHeight);
    [self.scrollView setContentOffset:CGPointMake(self.selectIndex*viewWidth, 0)];

    self.currentViewController.view.frame = [self.childViewFrames[self.selectIndex] CGRectValue];
    
    [self resetMenuView];

    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.memoryWarningCount++;
    self.cachePolicy = WMPageControllerCachePolicyLowMemory;
    // 取消正在增长的 cache 操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(growCachePolicyToHigh) object:nil];
    
    [self.memCache removeAllObjects];
    [self.posRecords removeAllObjects];
    self.posRecords = nil;
    
    // 如果收到内存警告次数小于 3，一段时间后切换到模式 Balanced
    if (self.memoryWarningCount < 3) {
        [self performSelector:@selector(growCachePolicyAfterMemoryWarning) withObject:nil afterDelay:3.0];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self layoutChildViewControllers];
    if (animate) {
        CGFloat width = scrollView.frame.size.width;
        CGFloat contentOffsetX = scrollView.contentOffset.x;
        CGFloat rate = contentOffsetX / width;
        [self.menuView slideMenuAtProgress:rate];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    animate = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _selectIndex = (int)scrollView.contentOffset.x / viewWidth;
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    [self postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
}

#pragma mark - WMMenuView Delegate
- (void)menuView:(WMMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    NSInteger gap = (NSInteger)labs(index - currentIndex);
    animate = NO;
    CGPoint targetP = CGPointMake(viewWidth*index, 0);
    
    [self.scrollView setContentOffset:targetP animated:gap > 1?NO:self.pageAnimatable];
    if (gap > 1 || !self.pageAnimatable) {
        [self postFullyDisplayedNotificationWithCurrentIndex:(int)index];
        // 由于不触发-scrollViewDidScroll: 手动清除控制器..
        UIViewController *vc = [self.displayVC objectForKey:@(currentIndex)];
        if (vc) {
            [self removeViewController:vc atIndex:currentIndex];
        }
    }
    _selectIndex = (int)index;
    self.currentViewController = self.displayVC[@(self.selectIndex)];
}

- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    if (self.itemsWidths) {
        return [self.itemsWidths[index] floatValue];
    }
    return self.menuItemWidth;
}


#pragma mark - 导航栏返回按钮
- (void)createLeftItem1{
    if (self.navigationController) {
        NSArray* vcs = [self.navigationController viewControllers];
        NSInteger vcIndex = [vcs indexOfObject:self];
        if ([self canShowBackButton] && vcIndex != NSNotFound) {
            UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
            self.navigationItem.leftBarButtonItem = shareItem;
        }
    }
}

- (BOOL)canShowBackButton{
    NSArray* vcs = [self.navigationController viewControllers];
    return vcs && vcs.count > 1;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
