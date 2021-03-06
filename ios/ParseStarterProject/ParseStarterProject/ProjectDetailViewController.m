//
//  ProjectDetailViewController.m
//  ParseStarterProject
//
//  Created by Fangzhou He on 16/08/2015.
//
//

#import "ProjectDetailViewController.h"
#import <Parse/Parse.h>
#import <JGProgressHUD/JGProgressHUD.h>//;

@interface ProjectDetailViewController (){
    NSNumber *currentProjectVote;
    NSNumber *currentUserVote;
    NSString *projectObjectID;
    NSString *userObjectID;
}

@end

@implementation ProjectDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];

    PFQuery *query2 = [PFQuery queryWithClassName:@"Account"];
    [query2 whereKey:@"username" equalTo:_username];
    [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *object2, NSError *error){
        NSString *voteString = [[object2 objectForKey:@"votesRemaining"]stringValue];
        _voteUserRemaining.text = voteString;
        userObjectID = [object2 objectId];
        currentUserVote = [object2 objectForKey:@"votesRemaining"];
        
    }];
    
    
    
    // Do any additional setup after loading the view.
    PFQuery *query = [PFQuery queryWithClassName:@"Project"];
    [query whereKey:@"projectID" equalTo:_projectID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSLog(@"%@",objects);
        _projectTitle.text = [[objects objectAtIndex:0]objectForKey:@"projectName"];
        _projectDescrition.text = [[objects objectAtIndex:0]objectForKey:@"projectDescription"];
        _voteLabel.text = [[[objects objectAtIndex:0]objectForKey:@"votes"]stringValue];
        _projectGoalLabel.text = [[[objects objectAtIndex:0]objectForKey:@"projectGoal"]stringValue];

        
        
        currentProjectVote = [[objects objectAtIndex:0]objectForKey:@"votes"];
        
        _projectProgress.progress = [[[objects objectAtIndex:0]objectForKey:@"votes"]floatValue] / [[[objects objectAtIndex:0]objectForKey:@"projectGoal"]floatValue];
        projectObjectID = [[objects objectAtIndex:0] objectId];
        PFFile *originImage = [[objects objectAtIndex:0] objectForKey:@"projectImage"];
        if (originImage != NULL) {
            [originImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
                UIImage *image = [UIImage imageWithData:imageData];
                _projectImage.image = image;
            }];
        }
        [HUD dismissAfterDelay:0];
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateMyVoteLabel {
    currentUserVote = [NSNumber numberWithInt:[currentUserVote intValue]-1];
    _voteUserRemaining.text = [currentUserVote stringValue];
}

- (void)updateProjectVote {
    currentProjectVote = [NSNumber numberWithInt:[currentProjectVote intValue]+1];
    _voteLabel.text = [currentProjectVote stringValue];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)voteButton:(id)sender {
    JGProgressHUD *HUDCONNECTION = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUDCONNECTION.textLabel.text = @"Connecting to server...";
    [HUDCONNECTION showInView:self.view];
    
    if(currentUserVote>0){
        int currentProjectVoteValue = [currentProjectVote intValue];
        int currentUserVoteValue = [currentUserVote intValue];
        NSNumber *postProjectVote = [NSNumber numberWithInt:currentProjectVoteValue+1];
        NSNumber *postUserVote = [NSNumber numberWithInt:currentUserVoteValue-1];

        
        PFQuery *query = [PFQuery queryWithClassName:@"Project"];
        [query getObjectInBackgroundWithId:projectObjectID block:^(PFObject *object, NSError *error){
            object[@"votes"]=postProjectVote;
            [object saveInBackground];
        }];
        
        PFQuery *query2 = [PFQuery queryWithClassName:@"Account"];
        [query2 getObjectInBackgroundWithId:userObjectID block:^(PFObject *object2, NSError *error){
            object2[@"votesRemaining"] = postUserVote;
            [object2 saveInBackground];
        }];
        
        [self updateMyVoteLabel];
        [self updateProjectVote];
        [HUDCONNECTION dismissAfterDelay:0];

    }
    else{
        [HUDCONNECTION dismissAfterDelay:0];
        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        HUD.textLabel.text = @"Error:Not enough votes, please top up!";
        HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init]; //JGProgressHUDSuccessIndicatorView is also available
        [HUD showInView:self.view];
        [HUD dismissAfterDelay:1.0];
        NSLog(@"Not enough votes, please top up");
    }
    
}
@end
