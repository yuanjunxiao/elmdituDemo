//
//  SuperVC.m
//  baiduDemo
//
//  Created by 袁俊晓 on 2017/4/6.
//  Copyright © 2017年 yuanjunxiao. All rights reserved.
//

#import "SuperVC.h"
#import "myTableViewCell.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件

#define kScreenSize [UIScreen mainScreen].bounds.size
@interface SuperVC ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SuperVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatTableview];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.f green:242/255.f blue:242/255.f alpha:1.0];
    _sourceArr =[[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(first:) name:@"first" object:nil];
    // Do any additional setup after loading the view.
}
-(void)first:(NSNotification *)noti {
    _sourceArr = [[NSArray alloc]initWithArray:[noti object]];
    [_tableview reloadData];
}
-(void)creatTableview{
    
    _tableview                = [[UITableView alloc]initWithFrame:CGRectMake(0, 15,kScreenSize.width, kScreenSize.height-300-64-45) style:UITableViewStylePlain];
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
    
    return _sourceArr.count;
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
    BMKPoiInfo* poi = _sourceArr[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backSource" object:poi];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
