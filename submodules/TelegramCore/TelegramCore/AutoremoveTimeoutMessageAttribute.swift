import Foundation
#if os(macOS)
    import PostboxMac
    import SwiftSignalKitMac
    import MtProtoKitMac
#else
    import Postbox
    import SwiftSignalKit
    #if BUCK
        import MtProtoKit
    #else
        import MtProtoKitDynamic
    #endif
#endif

public class AutoremoveTimeoutMessageAttribute: MessageAttribute {
    public let timeout: Int32
    public let countdownBeginTime: Int32?
    
    public var associatedMessageIds: [MessageId] = []
    
    public init(timeout: Int32, countdownBeginTime: Int32?) {
        self.timeout = timeout
        self.countdownBeginTime = countdownBeginTime
    }
    
    required public init(decoder: PostboxDecoder) {
        self.timeout = decoder.decodeInt32ForKey("t", orElse: 0)
        self.countdownBeginTime = decoder.decodeOptionalInt32ForKey("c")
    }
    
    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.timeout, forKey: "t")
        if let countdownBeginTime = self.countdownBeginTime {
            encoder.encodeInt32(countdownBeginTime, forKey: "c")
        } else {
            encoder.encodeNil(forKey: "c")
        }
    }
}

public extension Message {
    public var containsSecretMedia: Bool {
        var found = false
        for attribute in self.attributes {
            if let attribute = attribute as? AutoremoveTimeoutMessageAttribute {
                if attribute.timeout > 1 * 60 {
                    return false
                }
                found = true
                break
            }
        }
        
        if !found {
            return false
        }
        
        for media in self.media {
            switch media {
                case _ as TelegramMediaImage:
                    return true
                case let file as TelegramMediaFile:
                    if file.isVideo || file.isAnimated || file.isVoice || file.isMusic {
                        return true
                    }
                default:
                    break
            }
        }
        
        return false
    }
    
    public var secretMediaDuration: Int32? {
        var found = false
        for attribute in self.attributes {
            if let attribute = attribute as? AutoremoveTimeoutMessageAttribute {
                found = true
                break
            }
        }
        
        if !found {
            return nil
        }
        
        for media in self.media {
            switch media {
            case _ as TelegramMediaImage:
                return nil
            case let file as TelegramMediaFile:
                return file.duration
            default:
                break
            }
        }
        
        return nil
    }
}
