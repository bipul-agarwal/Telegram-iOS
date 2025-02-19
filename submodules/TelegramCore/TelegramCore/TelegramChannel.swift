import Foundation
#if os(macOS)
    import PostboxMac
#else
    import Postbox
#endif

public enum TelegramChannelParticipationStatus {
    case member
    case left
    case kicked
    
    fileprivate var rawValue: Int32 {
        switch self {
            case .member:
                return 0
            case .left:
                return 1
            case .kicked:
                return 2
        }
    }
    
    fileprivate init(rawValue: Int32) {
        switch rawValue {
            case 0:
                self = .member
            case 1:
                self = .left
            case 2:
                self = .kicked
            default:
                self = .left
        }
    }
}

public struct TelegramChannelBroadcastFlags: OptionSet {
    public var rawValue: Int32
    
    public init() {
        self.rawValue = 0
    }
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public static let messagesShouldHaveSignatures = TelegramChannelBroadcastFlags(rawValue: 1 << 0)
    public static let hasDiscussionGroup = TelegramChannelBroadcastFlags(rawValue: 1 << 1)

}

public struct TelegramChannelBroadcastInfo: Equatable {
    public let flags: TelegramChannelBroadcastFlags
    public init(flags: TelegramChannelBroadcastFlags) {
        self.flags = flags
    }
    
    public static func ==(lhs: TelegramChannelBroadcastInfo, rhs: TelegramChannelBroadcastInfo) -> Bool {
        return lhs.flags == rhs.flags
    }
}

public struct TelegramChannelGroupFlags: OptionSet {
    public var rawValue: Int32
    
    public init() {
        self.rawValue = 0
    }
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    public static let slowModeEnabled = TelegramChannelGroupFlags(rawValue: 1 << 0)
}

public struct TelegramChannelGroupInfo: Equatable {
    public let flags: TelegramChannelGroupFlags
    
    public init(flags: TelegramChannelGroupFlags) {
        self.flags = flags
    }

    public static func ==(lhs: TelegramChannelGroupInfo, rhs: TelegramChannelGroupInfo) -> Bool {
        return lhs.flags == rhs.flags
    }
}

public enum TelegramChannelInfo: Equatable {
    case broadcast(TelegramChannelBroadcastInfo)
    case group(TelegramChannelGroupInfo)
    
    public static func ==(lhs: TelegramChannelInfo, rhs: TelegramChannelInfo) -> Bool {
        switch lhs {
            case let .broadcast(lhsInfo):
                switch rhs {
                    case .broadcast(lhsInfo):
                        return true
                    default:
                        return false
                }
            case let .group(lhsInfo):
                switch rhs {
                    case .group(lhsInfo):
                        return true
                    default:
                        return false
                }
        }
    }
    
    fileprivate func encode(encoder: PostboxEncoder) {
        switch self {
            case let .broadcast(info):
                encoder.encodeInt32(0, forKey: "i.t")
                encoder.encodeInt32(info.flags.rawValue, forKey: "i.f")
            case let .group(info):
                encoder.encodeInt32(1, forKey: "i.t")
                encoder.encodeInt32(info.flags.rawValue, forKey: "i.f")
        }
    }
    
    fileprivate static func decode(decoder: PostboxDecoder) -> TelegramChannelInfo {
        let type: Int32 = decoder.decodeInt32ForKey("i.t", orElse: 0)
        if type == 0 {
            return .broadcast(TelegramChannelBroadcastInfo(flags: TelegramChannelBroadcastFlags(rawValue: decoder.decodeInt32ForKey("i.f", orElse: 0))))
        } else {
            return .group(TelegramChannelGroupInfo(flags: TelegramChannelGroupFlags(rawValue: decoder.decodeInt32ForKey("i.f", orElse: 0))))
        }
    }
}

public struct TelegramChannelFlags: OptionSet {
    public var rawValue: Int32
    
    public init() {
        self.rawValue = 0
    }
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public static let isVerified = TelegramChannelFlags(rawValue: 1 << 0)
    public static let isCreator = TelegramChannelFlags(rawValue: 1 << 1)
    public static let isScam = TelegramChannelFlags(rawValue: 1 << 2)
    public static let hasGeo = TelegramChannelFlags(rawValue: 1 << 3)
}

public final class TelegramChannel: Peer {
    public let id: PeerId
    public let accessHash: TelegramPeerAccessHash?
    public let title: String
    public let username: String?
    public let photo: [TelegramMediaImageRepresentation]
    public let creationDate: Int32
    public let version: Int32
    public let participationStatus: TelegramChannelParticipationStatus
    public let info: TelegramChannelInfo
    public let flags: TelegramChannelFlags
    public let restrictionInfo: PeerAccessRestrictionInfo?
    public let adminRights: TelegramChatAdminRights?
    public let bannedRights: TelegramChatBannedRights?
    public let defaultBannedRights: TelegramChatBannedRights?
    
    public var indexName: PeerIndexNameRepresentation {
        return .title(title: self.title, addressName: self.username)
    }
    
    public let associatedPeerId: PeerId? = nil
    public let notificationSettingsPeerId: PeerId? = nil
    
    public init(id: PeerId, accessHash: TelegramPeerAccessHash?, title: String, username: String?, photo: [TelegramMediaImageRepresentation], creationDate: Int32, version: Int32, participationStatus: TelegramChannelParticipationStatus, info: TelegramChannelInfo, flags: TelegramChannelFlags, restrictionInfo: PeerAccessRestrictionInfo?, adminRights: TelegramChatAdminRights?, bannedRights: TelegramChatBannedRights?, defaultBannedRights: TelegramChatBannedRights?) {
        self.id = id
        self.accessHash = accessHash
        self.title = title
        self.username = username
        self.photo = photo
        self.creationDate = creationDate
        self.version = version
        self.participationStatus = participationStatus
        self.info = info
        self.flags = flags
        self.restrictionInfo = restrictionInfo
        self.adminRights = adminRights
        self.bannedRights = bannedRights
        self.defaultBannedRights = defaultBannedRights
    }
    
    public init(decoder: PostboxDecoder) {
        self.id = PeerId(decoder.decodeInt64ForKey("i", orElse: 0))
        let accessHash = decoder.decodeOptionalInt64ForKey("ah")
        let accessHashType: Int32 = decoder.decodeInt32ForKey("aht", orElse: 0)
        if let accessHash = accessHash {
            if accessHashType == 0 {
                self.accessHash = .personal(accessHash)
            } else {
                self.accessHash = .genericPublic(accessHash)
            }
        } else {
            self.accessHash = nil
        }
        self.title = decoder.decodeStringForKey("t", orElse: "")
        self.username = decoder.decodeOptionalStringForKey("un")
        self.photo = decoder.decodeObjectArrayForKey("ph")
        self.creationDate = decoder.decodeInt32ForKey("d", orElse: 0)
        self.version = decoder.decodeInt32ForKey("v", orElse: 0)
        self.participationStatus = TelegramChannelParticipationStatus(rawValue: decoder.decodeInt32ForKey("ps", orElse: 0))
        self.info = TelegramChannelInfo.decode(decoder: decoder)
        self.flags = TelegramChannelFlags(rawValue: decoder.decodeInt32ForKey("fl", orElse: 0))
        self.restrictionInfo = decoder.decodeObjectForKey("ri") as? PeerAccessRestrictionInfo
        self.adminRights = decoder.decodeObjectForKey("ar", decoder: { TelegramChatAdminRights(decoder: $0) }) as? TelegramChatAdminRights
        self.bannedRights = decoder.decodeObjectForKey("br", decoder: { TelegramChatBannedRights(decoder: $0) }) as? TelegramChatBannedRights
        self.defaultBannedRights = decoder.decodeObjectForKey("dbr", decoder: { TelegramChatBannedRights(decoder: $0) }) as? TelegramChatBannedRights
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt64(self.id.toInt64(), forKey: "i")
        if let accessHash = self.accessHash {
            switch accessHash {
            case let .personal(value):
                encoder.encodeInt64(value, forKey: "ah")
                encoder.encodeInt32(0, forKey: "aht")
            case let .genericPublic(value):
                encoder.encodeInt64(value, forKey: "ah")
                encoder.encodeInt32(1, forKey: "aht")
            }
        } else {
            encoder.encodeNil(forKey: "ah")
        }
        encoder.encodeString(self.title, forKey: "t")
        if let username = self.username {
            encoder.encodeString(username, forKey: "un")
        } else {
            encoder.encodeNil(forKey: "un")
        }
        encoder.encodeObjectArray(self.photo, forKey: "ph")
        encoder.encodeInt32(self.creationDate, forKey: "d")
        encoder.encodeInt32(self.version, forKey: "v")
        encoder.encodeInt32(self.participationStatus.rawValue, forKey: "ps")
        self.info.encode(encoder: encoder)
        encoder.encodeInt32(self.flags.rawValue, forKey: "fl")
        if let restrictionInfo = self.restrictionInfo {
            encoder.encodeObject(restrictionInfo, forKey: "ri")
        } else {
            encoder.encodeNil(forKey: "ri")
        }
        if let adminRights = self.adminRights {
            encoder.encodeObject(adminRights, forKey: "ar")
        } else {
            encoder.encodeNil(forKey: "ar")
        }
        if let bannedRights = self.bannedRights {
            encoder.encodeObject(bannedRights, forKey: "br")
        } else {
            encoder.encodeNil(forKey: "br")
        }
        if let defaultBannedRights = self.defaultBannedRights {
            encoder.encodeObject(defaultBannedRights, forKey: "dbr")
        } else {
            encoder.encodeNil(forKey: "dbr")
        }
    }
    
    public func isEqual(_ other: Peer) -> Bool {
        guard let other = other as? TelegramChannel else {
            return false
        }
        
        if self.id != other.id || self.accessHash != other.accessHash || self.title != other.title || self.username != other.username || self.photo != other.photo {
            return false
        }
        
        if self.creationDate != other.creationDate || self.version != other.version || self.participationStatus != other.participationStatus {
            return false
        }
        
        if self.info != other.info || self.flags != other.flags || self.restrictionInfo != other.restrictionInfo {
            return false
        }
        
        if self.adminRights != other.adminRights {
            return false
        }
        
        if self.bannedRights != other.bannedRights {
            return false
        }
        
        if self.defaultBannedRights != other.defaultBannedRights {
            return false
        }
        
        return true
    }
    
    func withUpdatedAddressName(_ addressName: String?) -> TelegramChannel {
        return TelegramChannel(id: self.id, accessHash: self.accessHash, title: self.title, username: addressName, photo: self.photo, creationDate: self.creationDate, version: self.version, participationStatus: self.participationStatus, info: self.info, flags: self.flags, restrictionInfo: self.restrictionInfo, adminRights: self.adminRights, bannedRights: self.bannedRights, defaultBannedRights: self.defaultBannedRights)
    }
    
    func withUpdatedDefaultBannedRights(_ defaultBannedRights: TelegramChatBannedRights?) -> TelegramChannel {
        return TelegramChannel(id: self.id, accessHash: self.accessHash, title: self.title, username: self.addressName, photo: self.photo, creationDate: self.creationDate, version: self.version, participationStatus: self.participationStatus, info: self.info, flags: self.flags, restrictionInfo: self.restrictionInfo, adminRights: self.adminRights, bannedRights: self.bannedRights, defaultBannedRights: defaultBannedRights)
    }
}

public enum TelegramChannelPermission {
    case sendMessages
    case pinMessages
    case inviteMembers
    case editAllMessages
    case deleteAllMessages
    case banMembers
    case addAdmins
    case changeInfo
}

public extension TelegramChannel {
    public func hasPermission(_ permission: TelegramChannelPermission) -> Bool {
        if self.flags.contains(.isCreator) {
            return true
        }
        switch permission {
            case .sendMessages:
                if case .broadcast = self.info {
                    if let adminRights = self.adminRights {
                        return adminRights.flags.contains(.canPostMessages)
                    } else {
                        return false
                    }
                } else {
                    if let adminRights = self.adminRights, adminRights.flags.contains(.canPostMessages) {
                        return true
                    }
                    if let bannedRights = self.bannedRights, bannedRights.flags.contains(.banSendMessages) {
                        return false
                    }
                    if let defaultBannedRights = self.defaultBannedRights, defaultBannedRights.flags.contains(.banSendMessages) {
                        return false
                    }
                    return true
                }
            case .pinMessages:
                if case .broadcast = self.info {
                    if let adminRights = self.adminRights {
                        return adminRights.flags.contains(.canPinMessages) || adminRights.flags.contains(.canEditMessages)
                    } else {
                        return false
                    }
                } else {
                    if let adminRights = self.adminRights, adminRights.flags.contains(.canPinMessages) {
                        return true
                    }
                    if let bannedRights = self.bannedRights, bannedRights.flags.contains(.banPinMessages) {
                        return false
                    }
                    if let defaultBannedRights = self.defaultBannedRights, defaultBannedRights.flags.contains(.banPinMessages) {
                        return false
                    }
                    return true
                }
            case .inviteMembers:
                if case .broadcast = self.info {
                    if let adminRights = self.adminRights {
                        return adminRights.flags.contains(.canInviteUsers)
                    } else {
                        return false
                    }
                } else {
                    if let adminRights = self.adminRights, adminRights.flags.contains(.canInviteUsers) {
                        return true
                    }
                    if let bannedRights = self.bannedRights, bannedRights.flags.contains(.banAddMembers) {
                        return false
                    }
                    if let defaultBannedRights = self.defaultBannedRights, defaultBannedRights.flags.contains(.banAddMembers) {
                        return false
                    }
                    return true
                }
            case .editAllMessages:
                if let adminRights = self.adminRights, adminRights.flags.contains(.canEditMessages) {
                    return true
                }
                return false
            case .deleteAllMessages:
                if let adminRights = self.adminRights, adminRights.flags.contains(.canDeleteMessages) {
                    return true
                }
                return false
            case .banMembers:
                if let adminRights = self.adminRights, adminRights.flags.contains(.canBanUsers) {
                    return true
                }
                return false
            case .changeInfo:
                if case .broadcast = self.info {
                    if let adminRights = self.adminRights {
                        return adminRights.flags.contains(.canChangeInfo)
                    } else {
                        return false
                    }
                } else {
                    if let adminRights = self.adminRights, adminRights.flags.contains(.canChangeInfo) {
                        return true
                    }
                    if let bannedRights = self.bannedRights, bannedRights.flags.contains(.banChangeInfo) {
                        return false
                    }
                    if let defaultBannedRights = self.defaultBannedRights, defaultBannedRights.flags.contains(.banChangeInfo) {
                        return false
                    }
                    return true
                }
            case .addAdmins:
                if let adminRights = self.adminRights, adminRights.flags.contains(.canAddAdmins) {
                    return true
                }
                return false
        }
    }
    
    public func hasBannedPermission(_ rights: TelegramChatBannedRightsFlags) -> (Int32, Bool)? {
        if self.flags.contains(.isCreator) {
            return nil
        }
        if let adminRights = self.adminRights, !adminRights.flags.isEmpty {
            return nil
        }
        if let defaultBannedRights = self.defaultBannedRights, defaultBannedRights.flags.contains(rights) {
            return (Int32.max, false)
        }
        if let bannedRights = self.bannedRights, bannedRights.flags.contains(rights) {
            return (bannedRights.untilDate, true)
        }
        return nil
    }
    
    public var isRestrictedBySlowmode: Bool {
        if self.flags.contains(.isCreator) {
            return false
        }
        if let adminRights = self.adminRights, !adminRights.flags.isEmpty {
            return false
        }
        if case let .group(group) = self.info {
            return group.flags.contains(.slowModeEnabled)
        } else {
            return false
        }
    }
}
