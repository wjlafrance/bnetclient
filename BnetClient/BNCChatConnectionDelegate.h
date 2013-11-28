#import "BNCConstants.h"

@class BNCChatConnection;

@protocol BNCChatConnectionDelegate <NSObject>

#pragma mark - Debug outputs

- (void)battleNetConnection:(BNCChatConnection *)conn
    outputDebugString:(NSString *)string;


#pragma mark - Socket connection callbacks

- (void)battleNetConnection:(BNCChatConnection *)conn
    didBeginConnectingToService:(BattleNetService)service;

- (void)battleNetConnection:(BNCChatConnection *)conn
    didConnectToService:(BattleNetService)service;

- (void)battleNetConnection:(BNCChatConnection *)conn
    didDisconnectFromService:(BattleNetService)service
    withError:(NSString *)error;


#pragma mark - Client Authentication

- (void)battleNetConnection:(BNCChatConnection *)conn
    didBeginAuthenticatingClientToService:(BattleNetService)service;

- (void)battleNetConnection:(BNCChatConnection *)conn
    didAuthenticateClientToService:(BattleNetService)service;

- (void)battleNetConnection:(BNCChatConnection *)conn
    didFailToAuthenticateClientToService:(BattleNetService)service
    withError:(NSString *)error;


#pragma mark - User Authentication

- (void)battleNetConnection:(BNCChatConnection *)conn
    didBeginAuthenticatingUserToService:(BattleNetService)service;

- (void)battleNetConnection:(BNCChatConnection *)conn
    didAuthenticateUserToService:(BattleNetService)service;

- (void)battleNetConnection:(BNCChatConnection *)conn
    didFailToAuthenticateUserToService:(BattleNetService)service
    withError:(NSString *)error;

- (void)battleNetConnection:(BNCChatConnection *)conn
    didBeginCreatingAccountForService:(BattleNetService)service;

- (void)battleNetConnection:(BNCChatConnection *)conn
    didCreateAccountForService:(BattleNetService)service;


#pragma mark - Chat events

- (void)battleNetConnection:(BNCChatConnection *)conn
    eventDidOccur:(BattleNetEvent)event
    username:(NSString *)username
    text:(NSString *)text
    flags:(BattleNetFlags)flags
    ping:(uint32_t)ping;

@end
