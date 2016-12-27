//
//  LanguageViewController.m
//  PigHub
//
//  Created by Rainbow on 2016/12/24.
//  Copyright © 2016年 PizzaLiu. All rights reserved.
//

#import "LanguageViewController.h"

@interface LanguageViewController ()

{
    NSArray *languages;
    NSInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortBtn;

@end

@implementation LanguageViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Languages", @"");

    languages = @[NSLocalizedString(@"All Languages", @""),@"JavaScript",@"Java",@"PHP",@"Ruby",@"Python",@"CSS",@"C++",@"C",@"Objective-C",@"Swift",@"Shell",@"R",@"Perl",@"Lua",@"HTML",@"Scala",@"Go"];
    selectedIndex = 0;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LangCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - reorder

- (IBAction)triggerReorder:(id)sender
{
    if (self.tableView.isEditing) {
        [self.sortBtn setImage:[UIImage imageNamed:@"Sort"]];
        [self.tableView setEditing:NO];
    } else {
        [self.sortBtn setImage:[UIImage imageNamed:@"Okay"]];
        [self.tableView setEditing:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [languages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LangCell" forIndexPath:indexPath];

    cell.textLabel.text = [languages objectAtIndex:indexPath.row];

    if (selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    selectedIndex = indexPath.row;
    [tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedIndex == indexPath.row) {
        selectedIndex = 0;
    }
    [tableView reloadData];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return FALSE;
    return YES;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return FALSE;
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
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
