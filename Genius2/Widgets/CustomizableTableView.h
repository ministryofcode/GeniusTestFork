/* CustomizableTableView */

#import <Cocoa/Cocoa.h>

@interface CustomizableTableView : NSTableView
{
	NSArray * _allTableColumns;
	NSMutableDictionary * _configDict;
	NSMenu * _toggleColumnsMenu;
}

- (NSDictionary *)configurationDictionary;
- (void)setConfigurationFromDictionary:(NSDictionary *)configDict;

- (NSMenu *) toggleColumnsMenu;
- (IBAction) toggleTableColumnShown:(NSMenuItem *)sender;
- (NSTableColumn *) tableColumnWithIdentifier:(NSString *)identifier;

@end


@interface NSObject (CustomizableTableViewDelegate)

- (NSArray *)tableViewDefaultTableColumnIdentifiers:(NSTableView *)aTableView;
- (void) tableView:(NSTableView *)aTableView didHideTableColumn:(NSTableColumn *)tableColumn;
- (void) tableView:(NSTableView *)aTableView didShowTableColumn:(NSTableColumn *)tableColumn;

- (BOOL) tableView:(NSTableView *)aTableView shouldChangeHeaderTitleOfTableColumn:(NSTableColumn *)aTableColumn;
- (void) tableView:(NSTableView *)aTableView didChangeHeaderTitleOfTableColumn:(NSTableColumn *)aTableColumn;

@end