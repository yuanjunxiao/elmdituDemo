//
//  ViewController.m
//  baiduDemo
//
//  Created by 袁俊晓 on 2017/4/5.
//  Copyright © 2017年 yuanjunxiao. All rights reserved.
//

#import "ViewController.h"
#import "firstViewController.h"
#import "secondViewController.h"
#import "threeViewController.h"
#import "myTableViewCell.h"
#import "WMPageController.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件

#define XK_USERDEFAULT  [NSUserDefaults standardUserDefaults]
#define kScreenSize [UIScreen mainScreen].bounds.size
#define XK_NC [NSNotificationCenter defaultCenter]

#define XK_COL_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong)NSMutableArray *sourceArr;
@property(nonatomic ,strong) UITableView     *tableview;
@property (nonatomic,strong)BMKPoiInfo* poi;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地图";
    self.view.backgroundColor =[UIColor whiteColor];
    _sourceArr =[[NSMutableArray alloc]init];
    [XK_NC addObserver:self selector:@selector(backaction:) name:@"backSource" object:nil];
    [self creatTableview];
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)backaction:(NSNotification *)noti{
    _poi = [noti object];
    [_tableview reloadData];
  
}
-(void)creatTableview{
    
    _tableview                = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,kScreenSize.width, kScreenSize.height-64) style:UITableViewStylePlain];
    _tableview.delegate       = self;
    _tableview.dataSource     = self;//设置代理
    _tableview.backgroundColor = [UIColor colorWithRed:242/255.f green:242/255.f blue:242/255.f alpha:1.0];
    //    _tableview.separatorColor = XK_COL_RGB(0xe1e1e1);
    //允许多项选择 默认是no；默认是单选
    _tableview.allowsMultipleSelection = YES;
    //取消多余的cell
    _tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];//取消多余行数
    [_tableview registerClass:[myTableViewCell class] forCellReuseIdentifier:@"myTableViewCell"];
    [self.view addSubview:_tableview];
    
}
//返回几组数据
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//每组有多少个
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    myTableViewCell *cell              = [tableView dequeueReusableCellWithIdentifier:@"myTableViewCell" forIndexPath:indexPath];
    if (_poi.name) {
        if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",_poi.city];
        }else if (indexPath.row == 2){
          cell.textLabel.text = [NSString stringWithFormat:@"%@",_poi.address];
        }
    }
    return cell;
}
//选中事件 有反应
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消了一直高亮
    [_tableview deselectRowAtIndexPath:indexPath animated:YES];
    WMPageController *pageController = [self getDefaultControllerwith:0];
    pageController.menuViewStyle = WMMenuViewStyleLine;
    pageController.titleSizeSelected = 14;
    pageController.titleColorSelected = XK_COL_RGB(0x60d496);
    pageController.titleColorNormal   = XK_COL_RGB(0x2b2b2b);
    pageController.cachePolicy = WMPageControllerCachePolicyLowMemory;
    [self.navigationController pushViewController:pageController animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(WMPageController *)getDefaultControllerwith:(int)index{
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    for (int i = 0; i <3; i++) {
        Class vcClass;
        NSString *title;
        switch (i%3) {
            case 0:
                vcClass = [firstViewController class];
                title = @"写字楼";
                break;
            case 1:
                vcClass = [secondViewController class];
                title = @"小区";
                break;
            default:
                vcClass = [threeViewController class];
                title = @"学校";
                
                break;
        }
        [viewControllers addObject:vcClass];
        [titles addObject:title];
    }
    WMPageController *pageVC = [[WMPageController alloc] initWithViewControllerClasses:viewControllers andTheirTitles:titles];
    pageVC.pageAnimatable = YES;
    pageVC.menuItemWidth = kScreenSize.width/6;
    pageVC.postNotification = YES;
    pageVC.cachePolicy = WMPageControllerCachePolicyLowMemory;
    pageVC.selectIndex =index;
    return pageVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
