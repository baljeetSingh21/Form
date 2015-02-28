#import "HYPDemoLoginCollectionViewController.h"
#import "FORMDataSource.h"
#import "NSJSONSerialization+ANDYJSONFile.h"
#import "UIColor+HYPFormsColors.h"
#import "FORMTextField.h"
#import "FORMLayout.h"
#import "FORMButtonFieldCell.h"

@interface HYPDemoLoginCollectionViewController () <FORMBaseFieldCellDelegate>

@property (nonatomic, strong) NSArray *JSON;
@property (nonatomic, strong) FORMDataSource *dataSource;
@property (nonatomic, strong) FORMLayout *layout;
@property (nonatomic) FORMField *emailTextField;
@property (nonatomic) FORMField *passwordTextField;
@property NSIndexPath *indexPathButton;

@end

@implementation HYPDemoLoginCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    FORMLayout *layout = [FORMLayout new];

    self.JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"JSON.json"];
    self.layout = layout;

    self.collectionView.dataSource = self.dataSource;
    self.collectionView.contentInset = UIEdgeInsetsMake([UIScreen mainScreen].bounds.size.width/3, 0, 0, 0);
    self.collectionView.backgroundColor = [UIColor HYPFormsLightGray];
}

#pragma mark - Data source collection view

- (FORMDataSource *)dataSource
{
    if (_dataSource) return _dataSource;

    _dataSource = [[FORMDataSource alloc] initWithJSON:self.JSON
                                        collectionView:self.collectionView
                                                layout:self.layout
                                                values:nil
                                              disabled:NO];

    __weak typeof(self)weakSelf = self;

    _dataSource.configureCellForIndexPath = ^(FORMField *field, UICollectionView *collectionView, NSIndexPath *indexPath) {
        FORMBaseFieldCell *cell;
        if ([field.typeString isEqualToString:@"button"]) {
            weakSelf.indexPathButton = indexPath;
        }
        return cell;
    };

    _dataSource.configureFieldUpdatedBlock = ^(FORMBaseFieldCell *cell, FORMField *field) {
        cell.delegate = weakSelf;
        if ([field.title isEqualToString:@"Email"]) {
            weakSelf.emailTextField = field;
        } else if ([field.title isEqualToString:@"Password"]) {
            weakSelf.passwordTextField = field;
        } else {
            [weakSelf checkButtonPressedWithField:field];
        }
    };

    return _dataSource;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource sizeForItemAtIndexPath:indexPath];
}

#pragma mark - Delegate methods

// It's a must do, otherways the button won't work.

- (void)fieldCell:(UICollectionViewCell *)fieldCell updatedWithField:(FORMField *)field
{
    if (self.emailTextField.valid && self.passwordTextField.valid) {
        FORMButtonFieldCell *cell = (FORMButtonFieldCell *)[self.collectionView cellForItemAtIndexPath:self.indexPathButton];
        cell.disabled = NO;
    }

    if ([field.typeString isEqualToString:@"button"]) {
        [self checkButtonPressedWithField:field];
    }
}

- (void)fieldCell:(UICollectionViewCell *)fieldCell processTargets:(NSArray *)targets { }

#pragma mark - Helper methods

- (void)checkButtonPressedWithField:(FORMField *)field
{
    if ([field.typeString isEqualToString:@"button"] && self.emailTextField.valid && self.passwordTextField.valid) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hey" message:@"You just logged in! Congratulations" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertActionNice = [UIAlertAction actionWithTitle:@"NICE" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];

        [alertController addAction:alertActionNice];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


@end