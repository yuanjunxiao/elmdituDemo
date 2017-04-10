//
//  myTableViewCell.m
//  baiduDemo
//
//  Created by 袁俊晓 on 2017/4/6.
//  Copyright © 2017年 yuanjunxiao. All rights reserved.
//

#import "myTableViewCell.h"
#define kScreenSize [UIScreen mainScreen].bounds.size
#define XK_COL_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@implementation myTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)showMessagewithName:(NSString *)name andAddress:(NSString *)address andIndex:(NSInteger)index{
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    if (index ==0) {
        UILabel *Label0 = [[UILabel alloc]initWithFrame:CGRectMake(30, 10,40, 15)];
        Label0.text = @"[当前]";
        Label0.textColor = XK_COL_RGB(0x60d496);
        Label0.textAlignment = NSTextAlignmentLeft;
        Label0.font =[UIFont systemFontOfSize:14];
        [self.contentView addSubview:Label0];
        UILabel *Label = [[UILabel alloc]initWithFrame:CGRectMake(70, 10, kScreenSize.width-80, 15)];
        Label.text = name;
        Label.textAlignment = NSTextAlignmentLeft;
        Label.font =[UIFont systemFontOfSize:15];
        [self.contentView addSubview:Label];

    }else{
        UILabel *Label = [[UILabel alloc]initWithFrame:CGRectMake(30, 10, kScreenSize.width-40, 15)];
        Label.text = name;
        Label.textAlignment = NSTextAlignmentLeft;
        Label.font =[UIFont systemFontOfSize:15];
        [self.contentView addSubview:Label];

    }
    
    UILabel *Label1 = [[UILabel alloc]initWithFrame:CGRectMake(30, 35, kScreenSize.width-40, 15)];
    Label1.text = address;
    Label1.textAlignment = NSTextAlignmentLeft;
    Label1.font =[UIFont systemFontOfSize:15];
    [self.contentView addSubview:Label1];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
