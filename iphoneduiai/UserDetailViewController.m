//
//  UserDetailViewController.m
//  iphoneduiai
//
//  Created by Cloud Dai on 12-9-28.
//  Copyright (c) 2012年 duiai.com. All rights reserved.
//

#import "UserDetailViewController.h"
#import "Utils.h"
#import <RestKit/RestKit.h>
#import <RestKit/JSONKit.h>
#import "SVProgressHUD.h"
#import "ShowPhotoView.h"
#import "AvatarView.h"
#import "MarrayReqView.h"
#import "MoreUserInfoView.h"
#import "WeiyuWordCell.h"
#import "CustomBarButtonItem.h"
#import "CopyQQViewController.h"
#import "SessionViewController.h"

static CGFloat dHeight = 0.0f;
static CGFloat dHeight2 = 0.0f;

@interface UserDetailViewController () <CustomCellDelegate>

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet ShowPhotoView *showPhotoView;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSDictionary *userInfo, *userBody, *userLife, *userInterest, *userWork, *marrayReq, *searchIndex;
@property (retain, nonatomic) IBOutlet UILabel *nameAgeLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeDistanceLabel;

@property (retain, nonatomic) IBOutlet UILabel *heightLabel;
@property (retain, nonatomic) IBOutlet UILabel *areaLabel;
@property (retain, nonatomic) IBOutlet UILabel *incomeLabel;
@property (retain, nonatomic) IBOutlet UILabel *weightLabel;
@property (retain, nonatomic) IBOutlet UILabel *degreeLabel;
@property (retain, nonatomic) IBOutlet UILabel *careerLabel;
@property (retain, nonatomic) IBOutlet UILabel *addressLabel;
@property (retain, nonatomic) IBOutlet UILabel *phoneLabel;
@property (retain, nonatomic) IBOutlet UIImageView *phoneImageView;
@property (retain, nonatomic) IBOutlet UIButton *snsbtn0;
@property (retain, nonatomic) IBOutlet UIButton *snsbtn1;
@property (retain, nonatomic) IBOutlet UIButton *snsbtn2;
@property (retain, nonatomic) IBOutlet MoreUserInfoView *moreUserInfoView;
@property (retain, nonatomic) IBOutlet MarrayReqView *marrayReqView;
@property (retain, nonatomic) IBOutlet UIView *move2View;
@property (retain, nonatomic) IBOutlet UIView *move1View;
@property (retain, nonatomic) IBOutlet UILabel *dySexLabel;
@property (retain, nonatomic) IBOutlet CountView *countView;

@property (strong, nonatomic) NSMutableArray *weiyus;
@property (strong, nonatomic) UITableViewCell *moreCell;
@property (nonatomic) NSInteger curPage, totalPage;
@property (nonatomic) BOOL loading;

@end

@implementation UserDetailViewController

- (void)dealloc
{
    [_photos release];
    [_tableView release];
    [_user release];
    [_showPhotoView release];
    [_avatarView release];
    [_userInfo release];
    [_nameAgeLabel release];
    [_timeDistanceLabel release];
    [_heightLabel release];
    [_areaLabel release];
    [_incomeLabel release];
    [_weightLabel release];
    [_degreeLabel release];
    [_careerLabel release];
    [_addressLabel release];
    [_phoneLabel release];
    [_phoneImageView release];
    [_userBody release];
    [_userLife release];
    [_userInterest release];
    [_userWork release];
    [_marrayReq release];
    [_snsbtn0 release];
    [_snsbtn1 release];
    [_snsbtn2 release];
    [_marrayReqView release];
    [_move2View release];
    [_move1View release];
    [_dySexLabel release];
    [_moreUserInfoView release];
    [_weiyus release];
    [_moreCell release];
    [_countView release];
    [_searchIndex release];
    [super dealloc];
}

- (void)setWeiyus:(NSMutableArray *)weiyus
{
    if (![_weiyus isEqualToArray:weiyus]) {
        if (self.curPage > 1) {
            [_weiyus addObjectsFromArray:weiyus];
        } else{
            _weiyus = [[NSMutableArray alloc] initWithArray:weiyus];
        }
        
        [self.tableView reloadData];
    }
}

- (void)setMarrayReq:(NSDictionary *)marrayReq
{
    if (![_marrayReq isEqualToDictionary:marrayReq]) {
        _marrayReq = [marrayReq retain];
        self.marrayReqView.marrayReq = marrayReq;
    }
}

- (void)setUserInterest:(NSDictionary *)userInterest
{
    if (![_userInterest isEqualToDictionary:userInterest]) {
        _userInterest = [userInterest retain];
        self.moreUserInfoView.moreUserInfo = userInterest;
    }
}

- (void)setPhotos:(NSMutableArray *)photos
{
    if (![_photos isEqualToArray:photos]) {
        _photos = [photos retain];
        self.showPhotoView.photos = photos;
    }
}

- (void)setSearchIndex:(NSDictionary *)searchIndex
{
    if (![_searchIndex isEqualToDictionary:searchIndex]) {
        _searchIndex = [searchIndex retain];
        
        self.timeDistanceLabel.text = [NSString stringWithFormat:@"%@/900m", [Utils descriptionForTime:[NSDate dateWithTimeIntervalSince1970:[[searchIndex objectForKey:@"acctime"] integerValue]]]];
        self.countView.count = [[searchIndex objectForKey:@"digocount"] description];
    }
}

- (void)setUserInfo:(NSDictionary *)userInfo
{
    if (![_userInfo isEqualToDictionary:userInfo]) {
        _userInfo = [userInfo retain];
        
        self.avatarView.sex = [userInfo objectForKey:@"sex"];
        [self.avatarView.imageView loadImage:[userInfo objectForKey:@"photo"]];
        self.nameAgeLabel.text = [NSString stringWithFormat:@"%@, %@岁", [userInfo objectForKey:@"niname"], [userInfo objectForKey:@"age"]];

        
        self.heightLabel.text = [NSString stringWithFormat:@"%@cm", [userInfo objectForKey:@"height"]];
        self.areaLabel.text = [userInfo objectForKey:@"area"];
        self.incomeLabel.text = [userInfo objectForKey:@"income"];
        self.degreeLabel.text = [userInfo objectForKey:@"degree"];
        self.careerLabel.text = [userInfo objectForKey:@"industry"];
        
        self.dySexLabel.text = [NSString stringWithFormat:@"%@的动态", [userInfo objectForKey:@"ta"]];
        
        self.navigationItem.titleView = [CustomBarButtonItem titleForNavigationItem:userInfo[@"niname"]];

    }
}

- (void)setUserBody:(NSDictionary *)userBody
{
    if (![_userBody isEqualToDictionary:userBody]) {
        _userBody = [userBody retain];
        
        self.weightLabel.text = [userBody objectForKey:@"weight"];
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setShowPhotoView:nil];
    [self setAvatarView:nil];
    [self setNameAgeLabel:nil];
    [self setTimeDistanceLabel:nil];
    [self setHeightLabel:nil];
    [self setAreaLabel:nil];
    [self setIncomeLabel:nil];
    [self setWeightLabel:nil];
    [self setDegreeLabel:nil];
    [self setCareerLabel:nil];
    [self setAddressLabel:nil];
    [self setPhoneLabel:nil];
    [self setPhoneImageView:nil];
    [self setSnsbtn0:nil];
    [self setSnsbtn1:nil];
    [self setSnsbtn2:nil];
    [self setMarrayReqView:nil];
    [self setMove2View:nil];
    [self setMove1View:nil];
    [self setDySexLabel:nil];
    [self setMoreUserInfoView:nil];
    [self setCountView:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"user data:%@", self.user);
    dHeight = self.marrayReqView.frame.size.height;
    dHeight2 = self.moreUserInfoView.frame.size.height;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    self.tableView.alwaysBounceVertical = YES;
    self.navigationItem.leftBarButtonItem = [[[CustomBarButtonItem alloc] initBackBarButtonWithTitle:@"返回"
                                                                                              target:self
                                                                                              action:@selector(backAction)] autorelease];
    [self.countView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scoreGestureAction:)] autorelease]];
}

- (void)scoreGestureAction:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged ||
        gesture.state == UIGestureRecognizerStateEnded) {
        
        [Utils scoreUserWithUid:[self.user objectForKey:@"_id"] block:^{
            NSString *scoreString = [NSString stringWithFormat:@"%d", [self.countView.count integerValue]+1];
            self.countView.count = scoreString;
        }];
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self grabUserInfoDetailRequest];
    [self grabMyWeiyuListReqeustWithPage:1];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.totalPage <= self.curPage) {
        return self.weiyus.count;
    } else{
        return self.weiyus.count + 1;
    }

}

-(UITableViewCell *)createMoreCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moretag"] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UILabel *labelNumber = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 100, 20)];
    labelNumber.textAlignment = UITextAlignmentCenter;
    
    if (self.totalPage <= self.curPage){
        labelNumber.text = @"";
    } else {
        labelNumber.text = @"更多";
    }
    
	[labelNumber setTag:1];
	labelNumber.backgroundColor = [UIColor clearColor];
	labelNumber.font = [UIFont boldSystemFontOfSize:18];
	[cell.contentView addSubview:labelNumber];
	[labelNumber release];
	
    self.moreCell = cell;
    
    return self.moreCell;
}

- (UITableViewCell *)creatNormalCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"weiyuWordCell";
    WeiyuWordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:2];
        cell.delegate = self;
    }
    
    // Configure the cell...
    cell.weiyu = [self.weiyus objectAtIndex:indexPath.row];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.weiyus.count) {
        return [self createMoreCell:tableView cellForRowAtIndexPath:indexPath];
    }else {
        return [self creatNormalCell:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.weiyus.count) {
        
        return 40.0f;
    }else {
        WeiyuWordCell *cell = (WeiyuWordCell *)[self creatNormalCell:tableView cellForRowAtIndexPath:indexPath];
        return [cell requiredHeight];
        
    }
}

- (void)loadNextInfoList
{
    UILabel *label = (UILabel*)[self.moreCell.contentView viewWithTag:1];
    label.text = @"正在加载..."; // bug no reload table not show it.
    
    if (!self.loading) {
        [self grabMyWeiyuListReqeustWithPage:self.curPage+1];
        self.loading = YES;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.weiyus.count) {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self loadNextInfoList];
        });
    }
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)grabUserInfoDetailRequest
{
    NSMutableDictionary *dParams = [Utils queryParams];
    [dParams setObject:[self.user objectForKey:@"_id"] forKey:@"uid"];
    
    [[RKClient sharedClient] get:[@"user" stringByAppendingQueryParameters:dParams] usingBlock:^(RKRequest *request){
        [request setOnDidLoadResponse:^(RKResponse *response){
            if (response.isOK && response.isJSON) {
                NSMutableDictionary *data = [[response bodyAsString] mutableObjectFromJSONString];
//                NSLog(@"user data: %@", data);
                NSInteger code = [[data objectForKey:@"error"] integerValue];
                if (code == 0) {
                    NSDictionary *dataData = [data objectForKey:@"data"];
                    self.photos = [dataData objectForKey:@"photo"];
                    self.userInfo = [dataData objectForKey:@"user_info"];
                    self.userBody = [dataData objectForKey:@"user_body"];
                    self.userLife = [dataData objectForKey:@"user_life"];
                    self.userInterest = [dataData objectForKey:@"user_interest"];
                    self.userWork = [dataData objectForKey:@"user_work"];
                    self.marrayReq = [dataData objectForKey:@"marray_req"];
                    if (dataData[@"searchindex"] != [NSNull null]) {
                        self.searchIndex = [dataData objectForKey:@"searchindex"];
                    }
                    
                }
            }
        }];
        
        [request setOnDidFailLoadWithError:^(NSError *error){
            NSLog(@"error: %@", [error description]);
        }];
        
    }];
}

- (void)grabMyWeiyuListReqeustWithPage:(NSInteger)page
{
    NSMutableDictionary *dParams = [Utils queryParams];

//    [dParams setObject:@"myv" forKey:@"a"];
    [dParams setObject:[self.user objectForKey:@"_id"] forKey:@"uid"];
    [dParams setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    [dParams setObject:@"10" forKey:@"pagesize"];
    
    [[RKClient sharedClient] get:[@"/v" stringByAppendingQueryParameters:dParams] usingBlock:^(RKRequest *request){
        [request setOnDidLoadResponse:^(RKResponse *response){
            if (response.isOK && response.isJSON) {
                NSMutableDictionary *data = [[response bodyAsString] mutableObjectFromJSONString];
                NSInteger code = [data[@"error"] integerValue];
                //                NSLog(@"my weiyu data: %@", data);
                if (code == 0) {
                    if (![[data objectForKey:@"data"] isKindOfClass:[NSString class]]) {
                        self.loading = NO;
                        self.totalPage = [[[data objectForKey:@"pager"] objectForKey:@"pagecount"] integerValue];
                        self.curPage = [[[data objectForKey:@"pager"] objectForKey:@"thispage"] integerValue];
                        // 此行须在前两行后面
                        self.weiyus = [data objectForKey:@"data"];
                    }
                } else{
                    [SVProgressHUD showErrorWithStatus:data[@"message"]];
                }

            }
        }];
        
        [request setOnDidFailLoadWithError:^(NSError *error){
            NSLog(@"error: %@", [error description]);
        }];
        
    }];
}

#pragma mark - event actions

- (IBAction)sendMsgAction
{
    NSLog(@"send message...");
    SessionViewController *svc = [[SessionViewController alloc] initWithNibName:@"SessionViewController" bundle:nil];
    NSMutableDictionary *info = [[[NSMutableDictionary alloc] init] autorelease];
    NSMutableDictionary *tmp = [[[NSMutableDictionary alloc] init] autorelease];
    info[@"niname"] = self.user[@"niname"];
    tmp[@"senduid"] = self.user[@"_id"];
    tmp[@"uinfo"] = info;
    
    svc.messageData = tmp;
    svc.senduid = self.user[@"_id"];
    [self.navigationController pushViewController:svc animated:YES];
    [svc release];
    
}

- (IBAction)checkQQAction
{
    NSLog(@"check QQ now");
    
    NSMutableDictionary *dp = [Utils queryParams];
    [SVProgressHUD show];
    [[RKClient sharedClient] post:[@"/common/contact.api" stringByAppendingQueryParameters:dp] usingBlock:^(RKRequest *request){
        
        // 设置POST的form表单的参数
        NSMutableDictionary *updateArgs = [NSMutableDictionary dictionary];
        
        updateArgs[@"uid"] = self.user[@"_id"];
        updateArgs[@"agree"] = @"0";
        
        request.params = [RKParams paramsWithDictionary:updateArgs];
        
        // 请求失败时
        [request setOnDidFailLoadWithError:^(NSError *error){
            NSLog(@"Error: %@", [error description]);
        }];
        
        // 请求成功时
        [request setOnDidLoadResponse:^(RKResponse *response){
            NSLog(@"error: %@", response.bodyAsString);
            if (response.isOK && response.isJSON) { // 200的返回并且是JSON数据
                NSDictionary *data = [response.bodyAsString objectFromJSONString]; // 提交后返回的状态
                NSInteger code = [data[@"error"] integerValue];  // 返回的状态
                if (code == 0) {
                    // 成功提交的情况
                    // ....
                    CopyQQViewController *copyQQViewController = [[[CopyQQViewController alloc]init]autorelease];
                    copyQQViewController.QQdata = data;
                    [self.navigationController pushViewController:copyQQViewController animated:YES];
                
                   // [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                } else{
                    // 失败的情况
                    [SVProgressHUD showErrorWithStatus:data[@"message"]];
                }
                
            } else{
                [SVProgressHUD showErrorWithStatus:@"网络故障"];
            }
        }];
        
    }];
   
}

- (IBAction)moreDetailAction:(UIButton *)sender
{

    if (sender.tag == 0) {
        UIView *view = sender.superview;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect move1 = self.move1View.frame;
            CGRect move2 = self.move2View.frame;
            move1.origin.y += dHeight2;
            move2.origin.y += dHeight2;
            self.move1View.frame = move1;
            self.move2View.frame = move2;
            
            UIView *headerView = self.tableView.tableHeaderView;
            CGRect frame = headerView.frame;
            frame.size.height += dHeight2;
            headerView.frame = frame;
            self.tableView.tableHeaderView = headerView;
            
            if ([self.marrayReqView superview] != nil) {
                CGRect marray = self.marrayReqView.frame;
                marray.origin.y += dHeight2;
                self.marrayReqView.frame = marray;
            }
            
        }];
        [self.moreUserInfoView showMeInView:self.tableView.tableHeaderView
                                    atPoint:CGPointMake(view.frame.origin.x, view.frame.origin.y+view.frame.size.height)
                                   animated:YES];
        
        
        sender.tag = 1;
    } else{
        [self.moreUserInfoView removeMeWithAnimated:YES];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect move1 = self.move1View.frame;
            CGRect move2 = self.move2View.frame;
            move1.origin.y -= dHeight2;
            move2.origin.y -= dHeight2;
            self.move1View.frame = move1;
            self.move2View.frame = move2;
            
            UIView *headerView = self.tableView.tableHeaderView;
            CGRect frame = headerView.frame;
            frame.size.height -= dHeight2;
            headerView.frame = frame;
            self.tableView.tableHeaderView = headerView;
            
            if ([self.marrayReqView superview] != nil) {
                CGRect marray = self.marrayReqView.frame;
                marray.origin.y -= dHeight2;
                self.marrayReqView.frame = marray;
            }
        }];
        sender.tag = 0;
    }
    
}

- (IBAction)friendConditionAction:(UIButton *)sender
{

    if (sender.tag == 0) {  
        UIView *view = sender.superview;
        [UIView animateWithDuration:0.3 animations:^{
            //            CGRect move1 = self.move1View.frame;
            CGRect move2 = self.move2View.frame;
            //            move1.origin.y += dHeight;
            move2.origin.y += dHeight;
            //            self.move1View.frame = move1;
            self.move2View.frame = move2;
            
            UIView *headerView = self.tableView.tableHeaderView;
            CGRect frame = headerView.frame;
            frame.size.height += dHeight;
            headerView.frame = frame;
            self.tableView.tableHeaderView = headerView;
            
        }];
        [self.marrayReqView showMeInView:self.tableView.tableHeaderView
                                 atPoint:CGPointMake(view.frame.origin.x, view.frame.origin.y+view.frame.size.height)
                                animated:YES];

        
        sender.tag = 1;
    } else{
        [self.marrayReqView removeMeWithAnimated:YES];
        
        [UIView animateWithDuration:0.3 animations:^{
            //            CGRect move1 = self.move1View.frame;
            CGRect move2 = self.move2View.frame;
            //            move1.origin.y += dHeight;
            move2.origin.y -= dHeight;
            //            self.move1View.frame = move1;
            self.move2View.frame = move2;
            
            UIView *headerView = self.tableView.tableHeaderView;
            CGRect frame = headerView.frame;
            frame.size.height -= dHeight;
            headerView.frame = frame;
            self.tableView.tableHeaderView = headerView;
        }];
        sender.tag = 0;
    }
    
}

#pragma mark - cell delegate
- (void)didChangeStatus:(UITableViewCell *)cell toStatus:(NSString *)status
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"weiyu data: %@", [self.weiyus objectAtIndex:indexPath.row]);
    NSLog(@"status: %@", status);
}


@end
