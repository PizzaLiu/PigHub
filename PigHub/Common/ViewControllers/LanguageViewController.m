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
    NSInteger selectedIndex;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortBtn;

@end

@implementation LanguageViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Languages", @"");

    selectedIndex = 0;
    Language *selectedLanguage = nil;
    if (self.selectedLanguageName) {
        selectedLanguage = [[LanguagesModel sharedStore] languageForName:self.selectedLanguageName];
    }
    if (self.selectedLanguageQuery) {
        selectedLanguage = [[LanguagesModel sharedStore] languageForQuery:self.selectedLanguageQuery];
    }
    if (selectedLanguage) {
        selectedIndex = [[[LanguagesModel sharedStore] allLanguages] indexOfObject:selectedLanguage];
    }

    // scroll to selected row
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
    [self.tableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LangCell"];
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
        [self.tableView setEditing:NO animated:YES];
    } else {
        [self.sortBtn setImage:[UIImage imageNamed:@"Okay"]];
        [self.tableView setEditing:YES animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[LanguagesModel sharedStore] languagesCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LangCell" forIndexPath:indexPath];

    cell.textLabel.text = [[LanguagesModel sharedStore] languageNameForIndex:indexPath.row];

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

    if (self.dismissBlock) {
        Language *selectedLanguage = [[LanguagesModel sharedStore] languageForIndex:selectedIndex];
        self.dismissBlock(selectedLanguage);
    }
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [[LanguagesModel sharedStore] moveLanguageAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return FALSE;
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row == 0) {
        return [NSIndexPath indexPathForRow:1 inSection:proposedDestinationIndexPath.section];
    }
    if (proposedDestinationIndexPath.row >= [[LanguagesModel sharedStore] languagesCount]) {
        return sourceIndexPath;
    }
    return proposedDestinationIndexPath;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


@end
