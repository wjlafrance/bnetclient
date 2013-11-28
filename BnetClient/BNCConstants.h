#ifndef BnetClient_BattleNetCommon_h
#define BnetClient_BattleNetCommon_h

@class BNCChatConnection;
@class BNCPacket;

typedef NS_ENUM(NSUInteger, BattleNetService) {
    None,
    BNLS,
    BNCS,
    MCP,
    BotNet,
    D2GS,
    W3GS
};

#pragma mark - SID_CHATEVENT events and flags

typedef NS_ENUM(uint32_t, BattleNetEvent) {
    EID_SHOWUSER            = 0x01, // User in channel
    EID_JOIN                = 0x02, // User joined channel
    EID_LEAVE               = 0x03, // User left channel
    EID_WHISPER             = 0x04, // Recieved whisper
    EID_TALK                = 0x05, // Chat text
    EID_BROADCAST           = 0x06, // Server broadcast
    EID_CHANNEL             = 0x07, // Channel information
    EID_USERFLAGS           = 0x09, // Flags update
    EID_WHISPERSENT         = 0x0A, // Sent whisper
    EID_CHANNELFULL         = 0x0D, // Channel full
    EID_CHANNELDOESNOTEXIST = 0x0E, // Channel doesn't exist
    EID_CHANNELRESTRICTED   = 0x0F, // Channel is restricted
    EID_INFO                = 0x12, // Information
    EID_ERROR               = 0x13, // Error message
    EID_EMOTE               = 0x17  // Emote
};

typedef NS_ENUM(uint32_t, BattleNetFlags) {
    BlizzardRepresentative =      0x01,
    ChannelOperator        =      0x02,
    Speaker                =      0x04,
    BattleNetAdministrator =      0x08,
    NoUDPSupport           =      0x10,
    Squelched              =      0x20,
    SpecialGuest           =      0x40,
    WCGOfficial            =    0x1000,
    GFOfficial             =  0x100000,
    GFPlayer               =  0x200000,
    PGLPlayer              = 0x2000000
};

#pragma mark - Packet Identifiers

#define SID_IDENTIFIER_BASE     0x000
#define BNLS_IDENTIFIER_BASE    0x100

typedef NS_ENUM(uint8_t, BattleNetPacketIdentifier) {
    SID_NULL           = 0x00,
    SID_ENTERCHAT      = 0x0A,
    SID_GETCHANNELLIST = 0x0B,
    SID_JOINCHANNEL    = 0x0C,
    SID_CHATCOMMAND    = 0x0E,
    SID_CHATEVENT      = 0x0F,
    SID_MESSAGEBOX     = 0x19,
    SID_PING           = 0x25,
    SID_LOGONRESPONSE  = 0x29,
    SID_LOGONRESPONSE2 = 0x3A,
    SID_CREATEACCOUNT2 = 0x3D,
    SID_AUTH_INFO      = 0x50,
    SID_AUTH_CHECK     = 0x51
};

typedef NS_ENUM(uint8_t, BnlsPacketIdentifier) {
    BNLS_NULL               = 0x00,
    BNLS_CDKEY              = 0x01,
    BNLS_HASHDATA           = 0x0B,
    BNLS_REQUESTVERSIONBYTE = 0x10,
    BNLS_VERSIONCHECKEX2    = 0x1A
};

#endif
