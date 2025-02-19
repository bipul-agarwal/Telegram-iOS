import Foundation
import UIKit
import TelegramCore

public enum PresentationThemeColorDecodingError: Error {
    case generic
}

private func decodeColor<Key>(_ values: KeyedDecodingContainer<Key>, _ key: Key) throws -> UIColor {
    if let value = try? values.decode(String.self, forKey: key) {
        if value.lowercased() == "clear" {
            return UIColor.clear
        } else if let color = UIColor(hexString: value) {
            return color
        }
    }
    throw PresentationThemeColorDecodingError.generic
}

private func encodeColor<Key>(_ values: inout KeyedEncodingContainer<Key>, _ value: UIColor, _ key: Key) throws {
    if value == UIColor.clear {
        try values.encode("clear", forKey: key)
    } else if value.alpha < 1.0 {
        try values.encode(String(format: "%08x", value.argb), forKey: key)
    } else {
        try values.encode(String(format: "%06x", value.rgb), forKey: key)
    }
}

extension TelegramWallpaper: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        if let value = try? values.decode(String.self) {
            switch value.lowercased() {
                case "builtin":
                    self = .builtin(WallpaperSettings())
                default:
                    if let color = UIColor(hexString: value) {
                        self = .color(Int32(bitPattern: color.rgb))
                    } else {
                        throw PresentationThemeColorDecodingError.generic
                    }
            }
        }
        throw PresentationThemeColorDecodingError.generic
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .builtin:
                try container.encode("builtin")
            case let .color(value):
                try container.encode(String(format: "%06x", value))
            default:
                break
        }
    }
}

extension PresentationThemeStatusBarStyle: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        if let value = try? values.decode(String.self) {
            switch value.lowercased() {
                case "black":
                    self = .black
                case "white":
                    self = .white
                default:
                    self = .black
            }
        } else {
            self = .black
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .black:
                try container.encode("black")
            case .white:
                try container.encode("white")
        }
    }
}

extension PresentationThemeActionSheetBackgroundType: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        if let value = try? values.decode(String.self) {
            switch value.lowercased() {
                case "light":
                    self = .light
                case "dark":
                    self = .dark
                default:
                    self = .light
            }
        } else {
            self = .light
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .light:
                try container.encode("light")
            case .dark:
                try container.encode("dark")
        }
    }
}

extension PresentationThemeKeyboardColor: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        if let value = try? values.decode(String.self) {
            switch value.lowercased() {
                case "light":
                    self = .light
                case "dark":
                    self = .dark
                default:
                    self = .light
            }
        } else {
            self = .light
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
            switch self {
                case .light:
                    try container.encode("light")
                case .dark:
                    try container.encode("dark")
        }
    }
}

extension PresentationThemeExpandedNotificationBackgroundType: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .light:
                try container.encode("light")
            case .dark:
                try container.encode("dark")
        }
    }
}

extension PresentationThemeGradientColors: Codable {
    enum CodingKeys: String, CodingKey {
        case top
        case bottom
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(topColor: try decodeColor(values, .top),
                  bottomColor: try decodeColor(values, .bottom))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.topColor, .top)
        try encodeColor(&values, self.bottomColor, .bottom)
    }
}

extension PresentationThemeIntro: Codable {
    enum CodingKeys: String, CodingKey {
        case startButton
        case dot
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(startButtonColor: try decodeColor(values, .startButton),
                  dotColor: try decodeColor(values, .dot))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.startButtonColor, .startButton)
        try encodeColor(&values, self.dotColor, .dot)
    }
}

extension PresentationThemePasscode: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case button
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColors: try values.decode(PresentationThemeGradientColors.self, forKey: .bg),
                  buttonColor: try decodeColor(values, .button))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.backgroundColors, forKey: .bg)
        try encodeColor(&values, self.buttonColor, .button)
    }
}

extension PresentationThemeRootTabBar: Codable {
    enum CodingKeys: String, CodingKey {
        case background
        case separator
        case icon
        case selectedIcon
        case text
        case selectedText
        case badgeBackground
        case badgeStroke
        case badgeText
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColor: try decodeColor(values, .background),
                  separatorColor: try decodeColor(values, .separator),
                  iconColor: try decodeColor(values, .icon),
                  selectedIconColor: try decodeColor(values, .selectedIcon),
                  textColor: try decodeColor(values, .text),
                  selectedTextColor: try decodeColor(values, .selectedText),
                  badgeBackgroundColor: try decodeColor(values, .badgeBackground),
                  badgeStrokeColor: try decodeColor(values, .badgeStroke),
                  badgeTextColor: try decodeColor(values, .badgeText))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.backgroundColor, .background)
        try encodeColor(&values, self.separatorColor, .separator)
        try encodeColor(&values, self.iconColor, .icon)
        try encodeColor(&values, self.selectedIconColor, .selectedIcon)
        try encodeColor(&values, self.textColor, .text)
        try encodeColor(&values, self.selectedTextColor, .selectedText)
        try encodeColor(&values, self.badgeBackgroundColor, .badgeBackground)
        try encodeColor(&values, self.badgeStrokeColor, .badgeStroke)
        try encodeColor(&values, self.badgeTextColor, .badgeText)
    }
}

extension PresentationThemeRootNavigationBar: Codable {
    enum CodingKeys: String, CodingKey {
        case button
        case disabledButton
        case primaryText
        case secondaryText
        case control
        case accentText
        case background
        case separator
        case badgeFill
        case badgeStroke
        case badgeText
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(buttonColor: try decodeColor(values, .button),
                  disabledButtonColor: try decodeColor(values, .disabledButton),
                  primaryTextColor: try decodeColor(values, .primaryText),
                  secondaryTextColor: try decodeColor(values, .secondaryText),
                  controlColor: try decodeColor(values, .control),
                  accentTextColor: try decodeColor(values, .accentText),
                  backgroundColor: try decodeColor(values, .background),
                  separatorColor: try decodeColor(values, .separator),
                  badgeBackgroundColor: try decodeColor(values, .badgeFill),
                  badgeStrokeColor: try decodeColor(values, .badgeStroke),
                  badgeTextColor: try decodeColor(values, .badgeText))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.buttonColor, .button)
        try encodeColor(&values, self.disabledButtonColor, .disabledButton)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try encodeColor(&values, self.secondaryTextColor, .secondaryText)
        try encodeColor(&values, self.controlColor, .control)
        try encodeColor(&values, self.accentTextColor, .accentText)
        try encodeColor(&values, self.backgroundColor, .background)
        try encodeColor(&values, self.separatorColor, .separator)
        try encodeColor(&values, self.badgeBackgroundColor, .badgeFill)
        try encodeColor(&values, self.badgeStrokeColor, .badgeStroke)
        try encodeColor(&values, self.badgeTextColor, .badgeText)
    }
}

extension PresentationThemeNavigationSearchBar: Codable {
    enum CodingKeys: String, CodingKey {
        case background
        case accent
        case inputFill
        case inputText
        case inputPlaceholderText
        case inputIcon
        case inputClearButton
        case separator
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColor: try decodeColor(values, .background),
                  accentColor: try decodeColor(values, .accent),
                  inputFillColor: try decodeColor(values, .inputFill),
                  inputTextColor: try decodeColor(values, .inputText),
                  inputPlaceholderTextColor: try decodeColor(values, .inputPlaceholderText),
                  inputIconColor: try decodeColor(values, .inputIcon),
                  inputClearButtonColor: try decodeColor(values, .inputClearButton),
                  separatorColor: try decodeColor(values, .separator))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.backgroundColor, .background)
        try encodeColor(&values, self.accentColor, .accent)
        try encodeColor(&values, self.inputFillColor, .inputFill)
        try encodeColor(&values, self.inputTextColor, .inputText)
        try encodeColor(&values, self.inputPlaceholderTextColor, .inputPlaceholderText)
        try encodeColor(&values, self.inputIconColor, .inputIcon)
        try encodeColor(&values, self.inputClearButtonColor, .inputClearButton)
        try encodeColor(&values, self.separatorColor, .separator)
    }
}

extension PresentationThemeRootController: Codable {
    enum CodingKeys: String, CodingKey {
        case statusBar
        case tabBar
        case navBar
        case searchBar
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(statusBarStyle: try values.decode(PresentationThemeStatusBarStyle.self, forKey: .statusBar),
                  tabBar: try values.decode(PresentationThemeRootTabBar.self, forKey: .tabBar),
                  navigationBar: try values.decode(PresentationThemeRootNavigationBar.self, forKey: .navBar),
                  navigationSearchBar: try values.decode(PresentationThemeNavigationSearchBar.self, forKey: .searchBar))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.statusBarStyle, forKey: .statusBar)
        try values.encode(self.tabBar, forKey: .tabBar)
        try values.encode(self.navigationBar, forKey: .navBar)
        try values.encode(self.navigationSearchBar, forKey: .searchBar)
    }
}

extension PresentationThemeActionSheet: Codable {
    enum CodingKeys: String, CodingKey {
        case dim
        case bgType
        case opaqueItemBg
        case itemBg
        case opaqueItemHighlightedBg
        case itemHighlightedBg
        case opaqueItemSeparator
        case standardActionText
        case destructiveActionText
        case disabledActionText
        case primaryText
        case secondaryText
        case controlAccent
        case inputBg
        case inputHollowBg
        case inputBorder
        case inputPlaceholder
        case inputText
        case inputClearButton
        case checkContent
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(dimColor: try decodeColor(values, .dim),
                  backgroundType: try values.decode(PresentationThemeActionSheetBackgroundType.self, forKey: .bgType),
                  opaqueItemBackgroundColor: try decodeColor(values, .opaqueItemBg),
                  itemBackgroundColor: try decodeColor(values, .itemBg),
                  opaqueItemHighlightedBackgroundColor: try decodeColor(values, .opaqueItemHighlightedBg),
                  itemHighlightedBackgroundColor: try decodeColor(values, .itemHighlightedBg),
                  opaqueItemSeparatorColor: try decodeColor(values, .opaqueItemSeparator),
                  standardActionTextColor: try decodeColor(values, .standardActionText),
                  destructiveActionTextColor: try decodeColor(values, .destructiveActionText),
                  disabledActionTextColor: try decodeColor(values, .disabledActionText),
                  primaryTextColor: try decodeColor(values, .primaryText),
                  secondaryTextColor: try decodeColor(values, .secondaryText),
                  controlAccentColor: try decodeColor(values, .controlAccent),
                  inputBackgroundColor: try decodeColor(values, .inputBg),
                  inputHollowBackgroundColor: try decodeColor(values, .inputHollowBg),
                  inputBorderColor: try decodeColor(values, .inputBorder),
                  inputPlaceholderColor: try decodeColor(values, .inputPlaceholder),
                  inputTextColor: try decodeColor(values, .inputText),
                  inputClearButtonColor: try decodeColor(values, .inputClearButton),
                  checkContentColor: try decodeColor(values, .checkContent))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.dimColor, .dim)
        try values.encode(self.backgroundType, forKey: .bgType)
        try encodeColor(&values, self.opaqueItemBackgroundColor, .opaqueItemBg)
        try encodeColor(&values, self.itemBackgroundColor, .itemBg)
        try encodeColor(&values, self.opaqueItemHighlightedBackgroundColor, .opaqueItemHighlightedBg)
        try encodeColor(&values, self.opaqueItemSeparatorColor, .opaqueItemSeparator)
        try encodeColor(&values, self.standardActionTextColor, .standardActionText)
        try encodeColor(&values, self.destructiveActionTextColor, .destructiveActionText)
        try encodeColor(&values, self.disabledActionTextColor, .disabledActionText)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try encodeColor(&values, self.secondaryTextColor, .secondaryText)
        try encodeColor(&values, self.controlAccentColor, .controlAccent)
        try encodeColor(&values, self.inputBackgroundColor, .inputBg)
        try encodeColor(&values, self.inputHollowBackgroundColor, .inputHollowBg)
        try encodeColor(&values, self.inputBorderColor, .inputBorder)
        try encodeColor(&values, self.inputPlaceholderColor, .inputPlaceholder)
        try encodeColor(&values, self.inputTextColor, .inputText)
        try encodeColor(&values, self.inputClearButtonColor, .inputClearButton)
        try encodeColor(&values, self.checkContentColor, .checkContent)
    }
}

extension PresentationThemeSwitch: Codable {
    enum CodingKeys: String, CodingKey {
        case frame
        case handle
        case content
        case positive
        case negative
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(frameColor: try decodeColor(values, .frame),
                  handleColor: try decodeColor(values, .handle),
                  contentColor: try decodeColor(values, .content),
                  positiveColor: try decodeColor(values, .positive),
                  negativeColor: try decodeColor(values, .negative))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.frameColor, .frame)
        try encodeColor(&values, self.handleColor, .handle)
        try encodeColor(&values, self.contentColor, .content)
        try encodeColor(&values, self.positiveColor, .positive)
        try encodeColor(&values, self.negativeColor, .negative)
    }
}

extension PresentationThemeFillForeground: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case fg
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(fillColor: try decodeColor(values, .bg),
                  foregroundColor: try decodeColor(values, .fg))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.fillColor, .bg)
        try encodeColor(&values, self.foregroundColor, .fg)
    }
}

extension PresentationThemeItemDisclosureActions: Codable {
    enum CodingKeys: String, CodingKey {
        case neutral1
        case neutral2
        case destructive
        case constructive
        case accent
        case warning
        case inactive
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(neutral1: try values.decode(PresentationThemeFillForeground.self, forKey: .neutral1),
                  neutral2: try values.decode(PresentationThemeFillForeground.self, forKey: .neutral2),
                  destructive: try values.decode(PresentationThemeFillForeground.self, forKey: .destructive),
                  constructive: try values.decode(PresentationThemeFillForeground.self, forKey: .constructive),
                  accent: try values.decode(PresentationThemeFillForeground.self, forKey: .accent),
                  warning: try values.decode(PresentationThemeFillForeground.self, forKey: .warning),
                  inactive: try values.decode(PresentationThemeFillForeground.self, forKey: .inactive))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.neutral1, forKey: .neutral1)
        try values.encode(self.neutral2, forKey: .neutral2)
        try values.encode(self.destructive, forKey: .destructive)
        try values.encode(self.constructive, forKey: .constructive)
        try values.encode(self.accent, forKey: .accent)
        try values.encode(self.warning, forKey: .warning)
        try values.encode(self.inactive, forKey: .inactive)
    }
}

extension PresentationThemeFillStrokeForeground: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case stroke
        case fg
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(fillColor: try decodeColor(values, .bg),
                  strokeColor: try decodeColor(values, .stroke),
                  foregroundColor: try decodeColor(values, .fg))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.fillColor, .bg)
        try encodeColor(&values, self.strokeColor, .stroke)
        try encodeColor(&values, self.foregroundColor, .fg)
    }
}

extension PresentationInputFieldTheme: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case stroke
        case placeholder
        case primary
        case control
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColor: try decodeColor(values, .bg),
                  strokeColor: try decodeColor(values, .stroke),
                  placeholderColor: try decodeColor(values, .placeholder),
                  primaryColor: try decodeColor(values, .primary),
                  controlColor: try decodeColor(values, .control))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.backgroundColor, .bg)
        try encodeColor(&values, self.strokeColor, .stroke)
        try encodeColor(&values, self.placeholderColor, .placeholder)
        try encodeColor(&values, self.primaryColor, .primary)
        try encodeColor(&values, self.controlColor, .control)
    }
}

extension PresentationThemeList: Codable {
    enum CodingKeys: String, CodingKey {
        case blocksBg
        case plainBg
        case primaryText
        case secondaryText
        case disabledText
        case accent
        case highlighted
        case destructive
        case placeholderText
        case itemBlocksBg
        case itemHighlightedBg
        case blocksSeparator
        case plainSeparator
        case disclosureArrow
        case sectionHeaderText
        case freeText
        case freeTextError
        case freeTextSuccess
        case freeMonoIcon
        case `switch`
        case disclosureActions
        case check
        case controlSecondary
        case freeInputField
        case mediaPlaceholder
        case scrollIndicator
        case pageIndicatorInactive
        case inputClearButton
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(blocksBackgroundColor: try decodeColor(values, .blocksBg),
                  plainBackgroundColor: try decodeColor(values, .plainBg),
                  itemPrimaryTextColor: try decodeColor(values, .primaryText),
                  itemSecondaryTextColor: try decodeColor(values, .secondaryText),
                  itemDisabledTextColor: try decodeColor(values, .disabledText),
                  itemAccentColor: try decodeColor(values, .accent),
                  itemHighlightedColor: try decodeColor(values, .highlighted),
                  itemDestructiveColor: try decodeColor(values, .destructive),
                  itemPlaceholderTextColor: try decodeColor(values, .placeholderText),
                  itemBlocksBackgroundColor: try decodeColor(values, .itemBlocksBg),
                  itemHighlightedBackgroundColor: try decodeColor(values, .itemHighlightedBg),
                  itemBlocksSeparatorColor: try decodeColor(values, .blocksSeparator),
                  itemPlainSeparatorColor: try decodeColor(values, .plainSeparator),
                  disclosureArrowColor: try decodeColor(values, .disclosureArrow),
                  sectionHeaderTextColor: try decodeColor(values, .sectionHeaderText),
                  freeTextColor: try decodeColor(values, .freeText),
                  freeTextErrorColor: try decodeColor(values, .freeTextError),
                  freeTextSuccessColor: try decodeColor(values, .freeTextSuccess),
                  freeMonoIconColor: try decodeColor(values, .freeMonoIcon),
                  itemSwitchColors: try values.decode(PresentationThemeSwitch.self, forKey: .switch),
                  itemDisclosureActions: try values.decode(PresentationThemeItemDisclosureActions.self, forKey: .disclosureActions),
                  itemCheckColors: try values.decode(PresentationThemeFillStrokeForeground.self, forKey: .check),
                  controlSecondaryColor: try decodeColor(values, .controlSecondary),
                  freeInputField: try values.decode(PresentationInputFieldTheme.self, forKey: .freeInputField),
                  mediaPlaceholderColor: try decodeColor(values, .mediaPlaceholder),
                  scrollIndicatorColor: try decodeColor(values, .scrollIndicator),
                  pageIndicatorInactiveColor: try decodeColor(values, .pageIndicatorInactive),
                  inputClearButtonColor: try decodeColor(values, .inputClearButton))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.blocksBackgroundColor, .blocksBg)
        try encodeColor(&values, self.plainBackgroundColor, .plainBg)
        try encodeColor(&values, self.itemPrimaryTextColor, .primaryText)
        try encodeColor(&values, self.itemSecondaryTextColor, .secondaryText)
        try encodeColor(&values, self.itemDisabledTextColor, .disabledText)
        try encodeColor(&values, self.itemAccentColor, .accent)
        try encodeColor(&values, self.itemHighlightedColor, .highlighted)
        try encodeColor(&values, self.itemDestructiveColor, .destructive)
        try encodeColor(&values, self.itemPlaceholderTextColor, .placeholderText)
        try encodeColor(&values, self.itemBlocksBackgroundColor, .itemBlocksBg)
        try encodeColor(&values, self.itemHighlightedBackgroundColor, .itemHighlightedBg)
        try encodeColor(&values, self.itemBlocksSeparatorColor, .blocksSeparator)
        try encodeColor(&values, self.itemPlainSeparatorColor, .plainSeparator)
        try encodeColor(&values, self.disclosureArrowColor, .disclosureArrow)
        try encodeColor(&values, self.sectionHeaderTextColor, .sectionHeaderText)
        try encodeColor(&values, self.freeTextColor, .freeText)
        try encodeColor(&values, self.freeTextErrorColor, .freeTextError)
        try encodeColor(&values, self.freeTextSuccessColor, .freeTextSuccess)
        try encodeColor(&values, self.freeMonoIconColor, .freeMonoIcon)
        try values.encode(self.itemSwitchColors, forKey: .`switch`)
        try values.encode(self.itemDisclosureActions, forKey: .disclosureActions)
        try values.encode(self.itemCheckColors, forKey: .check)
        try encodeColor(&values, self.controlSecondaryColor, .controlSecondary)
        try values.encode(self.freeInputField, forKey: .freeInputField)
        try encodeColor(&values, self.mediaPlaceholderColor, .mediaPlaceholder)
        try encodeColor(&values, self.scrollIndicatorColor, .scrollIndicator)
        try encodeColor(&values, self.pageIndicatorInactiveColor, .pageIndicatorInactive)
        try encodeColor(&values, self.inputClearButtonColor, .inputClearButton)
    }
}

extension PresentationThemeArchiveAvatarColors: Codable {
    enum CodingKeys: String, CodingKey {
        case background
        case foreground
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColors: try values.decode(PresentationThemeGradientColors.self, forKey: .background),
                  foregroundColor: try decodeColor(values, .foreground))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.backgroundColors, forKey: .background)
        try encodeColor(&values, self.foregroundColor, .foreground)
    }
}

extension PresentationThemeChatList: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case itemSeparator
        case itemBg
        case pinnedItemBg
        case itemHighlightedBg
        case itemSelectedBg
        case title
        case secretTitle
        case dateText
        case authorName
        case messageText
        case messageDraftText
        case checkmark
        case pendingIndicator
        case failedFill
        case failedFg
        case muteIcon
        case unreadBadgeActiveBg
        case unreadBadgeActiveText
        case unreadBadgeInactiveBg
        case unreadBadgeInactiveText
        case pinnedBadge
        case pinnedSearchBar
        case regularSearchBar
        case sectionHeaderBg
        case sectionHeaderText
        case searchBarKeyboard
        case verifiedIconBg
        case verifiedIconFg
        case secretIcon
        case pinnedArchiveAvatar
        case unpinnedArchiveAvatar
        case onlineDot
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColor: try decodeColor(values, .bg),
                  itemSeparatorColor: try decodeColor(values, .itemSeparator),
                  itemBackgroundColor: try decodeColor(values, .itemBg),
                  pinnedItemBackgroundColor: try decodeColor(values, .pinnedItemBg),
                  itemHighlightedBackgroundColor: try decodeColor(values, .itemHighlightedBg),
                  itemSelectedBackgroundColor: try decodeColor(values, .itemSelectedBg),
                  titleColor: try decodeColor(values, .title),
                  secretTitleColor: try decodeColor(values, .secretTitle),
                  dateTextColor: try decodeColor(values, .dateText),
                  authorNameColor: try decodeColor(values, .authorName),
                  messageTextColor: try decodeColor(values, .messageText),
                  messageDraftTextColor: try decodeColor(values, .messageDraftText),
                  checkmarkColor: try decodeColor(values, .checkmark),
                  pendingIndicatorColor: try decodeColor(values, .pendingIndicator),
                  failedFillColor: try decodeColor(values, .failedFill),
                  failedForegroundColor: try decodeColor(values, .failedFg),
                  muteIconColor: try decodeColor(values, .muteIcon),
                  unreadBadgeActiveBackgroundColor: try decodeColor(values, .unreadBadgeActiveBg),
                  unreadBadgeActiveTextColor: try decodeColor(values, .unreadBadgeActiveText),
                  unreadBadgeInactiveBackgroundColor: try decodeColor(values, .unreadBadgeInactiveBg),
                  unreadBadgeInactiveTextColor: try decodeColor(values, .unreadBadgeInactiveText),
                  pinnedBadgeColor: try decodeColor(values, .pinnedBadge),
                  pinnedSearchBarColor: try decodeColor(values, .pinnedSearchBar),
                  regularSearchBarColor: try decodeColor(values, .regularSearchBar),
                  sectionHeaderFillColor: try decodeColor(values, .sectionHeaderBg),
                  sectionHeaderTextColor: try decodeColor(values, .sectionHeaderText),
                  searchBarKeyboardColor: try values.decode(PresentationThemeKeyboardColor.self, forKey: .searchBarKeyboard),
                  verifiedIconFillColor: try decodeColor(values, .verifiedIconBg),
                  verifiedIconForegroundColor: try decodeColor(values, .verifiedIconFg),
                  secretIconColor: try decodeColor(values, .secretIcon),
                  pinnedArchiveAvatarColor: try values.decode(PresentationThemeArchiveAvatarColors.self, forKey: .pinnedArchiveAvatar),
                  unpinnedArchiveAvatarColor: try values.decode(PresentationThemeArchiveAvatarColors.self, forKey: .unpinnedArchiveAvatar),
                  onlineDotColor: try decodeColor(values, .onlineDot))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.backgroundColor, .bg)
        try encodeColor(&values, self.itemSeparatorColor, .itemSeparator)
        try encodeColor(&values, self.itemBackgroundColor, .itemBg)
        try encodeColor(&values, self.pinnedItemBackgroundColor, .pinnedItemBg)
        try encodeColor(&values, self.itemHighlightedBackgroundColor, .itemHighlightedBg)
        try encodeColor(&values, self.itemSelectedBackgroundColor, .itemSelectedBg)
        try encodeColor(&values, self.titleColor, .title)
        try encodeColor(&values, self.secretTitleColor, .secretTitle)
        try encodeColor(&values, self.dateTextColor, .dateText)
        try encodeColor(&values, self.authorNameColor, .authorName)
        try encodeColor(&values, self.messageTextColor, .messageText)
        try encodeColor(&values, self.messageDraftTextColor, .messageDraftText)
        try encodeColor(&values, self.checkmarkColor, .checkmark)
        try encodeColor(&values, self.pendingIndicatorColor, .pendingIndicator)
        try encodeColor(&values, self.failedFillColor, .failedFill)
        try encodeColor(&values, self.failedForegroundColor, .failedFg)
        try encodeColor(&values, self.muteIconColor, .muteIcon)
        try encodeColor(&values, self.unreadBadgeActiveBackgroundColor, .unreadBadgeActiveBg)
        try encodeColor(&values, self.unreadBadgeActiveTextColor, .unreadBadgeActiveText)
        try encodeColor(&values, self.unreadBadgeInactiveBackgroundColor, .unreadBadgeInactiveBg)
        try encodeColor(&values, self.unreadBadgeInactiveTextColor, .unreadBadgeInactiveText)
        try encodeColor(&values, self.pinnedBadgeColor, .pinnedBadge)
        try encodeColor(&values, self.pinnedSearchBarColor, .pinnedSearchBar)
        try encodeColor(&values, self.regularSearchBarColor, .regularSearchBar)
        try encodeColor(&values, self.sectionHeaderFillColor, .sectionHeaderBg)
        try encodeColor(&values, self.sectionHeaderTextColor, .sectionHeaderText)
        try values.encode(self.searchBarKeyboardColor, forKey: .searchBarKeyboard)
        try encodeColor(&values, self.verifiedIconFillColor, .verifiedIconBg)
        try encodeColor(&values, self.verifiedIconForegroundColor, .verifiedIconFg)
        try encodeColor(&values, self.secretIconColor, .secretIcon)
        try values.encode(self.pinnedArchiveAvatarColor, forKey: .pinnedArchiveAvatar)
        try values.encode(self.unpinnedArchiveAvatarColor, forKey: .unpinnedArchiveAvatar)
        try encodeColor(&values, self.onlineDotColor, .onlineDot)
    }
}

extension PresentationThemeBubbleColorComponents: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case highlightedBg
        case stroke
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(fill: try decodeColor(values, .bg),
                  highlightedFill: try decodeColor(values, .highlightedBg),
                  stroke: try decodeColor(values, .stroke))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.fill, .bg)
        try encodeColor(&values, self.highlightedFill, .highlightedBg)
        try encodeColor(&values, self.stroke, .stroke)
    }
}

extension PresentationThemeBubbleColor: Codable {
    enum CodingKeys: String, CodingKey {
        case withWp
        case withoutWp
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(withWallpaper: try values.decode(PresentationThemeBubbleColorComponents.self, forKey: .withWp),
                  withoutWallpaper: try values.decode(PresentationThemeBubbleColorComponents.self, forKey: .withoutWp))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.withWallpaper, forKey: .withWp)
        try values.encode(self.withoutWallpaper, forKey: .withoutWp)
    }
}

extension PresentationThemeVariableColor: Codable {
    enum CodingKeys: String, CodingKey {
        case withWp
        case withoutWp
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(withWallpaper: try decodeColor(values, .withWp),
                  withoutWallpaper: try decodeColor(values, .withoutWp))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.withWallpaper, .withWp)
        try encodeColor(&values, self.withoutWallpaper, .withoutWp)
    }
}

extension PresentationThemeChatBubblePolls: Codable {
    enum CodingKeys: String, CodingKey {
        case radioButton
        case radioProgress
        case highlight
        case separator
        case bar
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(radioButton: try decodeColor(values, .radioButton),
                  radioProgress: try decodeColor(values, .radioProgress),
                  highlight: try decodeColor(values, .highlight),
                  separator: try decodeColor(values, .separator),
                  bar: try decodeColor(values, .bar))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.radioButton, .radioButton)
        try encodeColor(&values, self.radioProgress, .radioProgress)
        try encodeColor(&values, self.highlight, .highlight)
        try encodeColor(&values, self.separator, .separator)
        try encodeColor(&values, self.bar, .bar)
    }
}

extension PresentationThemePartedColors: Codable {
    enum CodingKeys: String, CodingKey {
        case bubble
        case primaryText
        case secondaryText
        case linkText
        case linkHighlight
        case scam
        case textHighlight
        case accentText
        case accentControl
        case mediaActiveControl
        case mediaInactiveControl
        case pendingActivity
        case fileTitle
        case fileDescription
        case fileDuration
        case mediaPlaceholder
        case polls
        case actionButtonsBg
        case actionButtonsStroke
        case actionButtonsText
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(bubble: try values.decode(PresentationThemeBubbleColor.self, forKey: .bubble),
                  primaryTextColor: try decodeColor(values, .primaryText),
                  secondaryTextColor: try decodeColor(values, .secondaryText),
                  linkTextColor: try decodeColor(values, .linkText),
                  linkHighlightColor: try decodeColor(values, .linkHighlight),
                  scamColor: try decodeColor(values, .scam),
                  textHighlightColor: try decodeColor(values, .textHighlight),
                  accentTextColor: try decodeColor(values, .accentText),
                  accentControlColor: try decodeColor(values, .accentControl),
                  mediaActiveControlColor: try decodeColor(values, .mediaActiveControl),
                  mediaInactiveControlColor: try decodeColor(values, .mediaInactiveControl),
                  pendingActivityColor: try decodeColor(values, .pendingActivity),
                  fileTitleColor: try decodeColor(values, .fileTitle),
                  fileDescriptionColor: try decodeColor(values, .fileDescription),
                  fileDurationColor: try decodeColor(values, .fileDuration),
                  mediaPlaceholderColor: try decodeColor(values, .mediaPlaceholder),
                  polls: try values.decode(PresentationThemeChatBubblePolls.self, forKey: .polls),
                  actionButtonsFillColor: try values.decode(PresentationThemeVariableColor.self, forKey: .actionButtonsBg),
                  actionButtonsStrokeColor: try values.decode(PresentationThemeVariableColor.self, forKey: .actionButtonsStroke),
                  actionButtonsTextColor: try values.decode(PresentationThemeVariableColor.self, forKey: .actionButtonsText))
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.bubble, forKey: .bubble)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try encodeColor(&values, self.secondaryTextColor, .secondaryText)
        try encodeColor(&values, self.linkTextColor, .linkText)
        try encodeColor(&values, self.linkHighlightColor, .linkHighlight)
        try encodeColor(&values, self.scamColor, .scam)
        try encodeColor(&values, self.textHighlightColor, .textHighlight)
        try encodeColor(&values, self.accentTextColor, .accentText)
        try encodeColor(&values, self.accentControlColor, .accentControl)
        try encodeColor(&values, self.mediaActiveControlColor, .mediaActiveControl)
        try encodeColor(&values, self.mediaInactiveControlColor, .mediaInactiveControl)
        try encodeColor(&values, self.pendingActivityColor, .pendingActivity)
        try encodeColor(&values, self.fileTitleColor, .fileTitle)
        try encodeColor(&values, self.fileDescriptionColor, .fileDescription)
        try encodeColor(&values, self.fileDurationColor, .fileDuration)
        try encodeColor(&values, self.mediaPlaceholderColor, .mediaPlaceholder)
        try values.encode(self.polls, forKey: .polls)
        try values.encode(self.actionButtonsFillColor, forKey: .actionButtonsBg)
        try values.encode(self.actionButtonsStrokeColor, forKey: .actionButtonsStroke)
        try values.encode(self.actionButtonsTextColor, forKey: .actionButtonsText)
    }
}

extension PresentationThemeChatMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case incoming
        case outgoing
        case freeform
        case infoPrimaryText
        case infoLinkText
        case outgoingCheck
        case mediaDateAndStatusBg
        case mediaDateAndStatusText
        case shareButtonBg
        case shareButtonStroke
        case shareButtonFg
        case mediaOverlayControl
        case selectionControl
        case deliveryFailed
        case mediaHighlightOverlay
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(incoming: try values.decode(PresentationThemePartedColors.self, forKey: .incoming),
                  outgoing: try values.decode(PresentationThemePartedColors.self, forKey: .outgoing),
                  freeform: try values.decode(PresentationThemeBubbleColor.self, forKey: .freeform),
                  infoPrimaryTextColor: try decodeColor(values, .infoPrimaryText),
                  infoLinkTextColor: try decodeColor(values, .infoLinkText),
                  outgoingCheckColor: try decodeColor(values, .outgoingCheck),
                  mediaDateAndStatusFillColor: try decodeColor(values, .mediaDateAndStatusBg),
                  mediaDateAndStatusTextColor: try decodeColor(values, .mediaDateAndStatusText),
                  shareButtonFillColor: try values.decode(PresentationThemeVariableColor.self, forKey: .shareButtonBg),
                  shareButtonStrokeColor: try values.decode(PresentationThemeVariableColor.self, forKey: .shareButtonStroke),
                  shareButtonForegroundColor: try values.decode(PresentationThemeVariableColor.self, forKey: .shareButtonFg),
                  mediaOverlayControlColors: try values.decode(PresentationThemeFillForeground.self, forKey: .mediaOverlayControl),
                  selectionControlColors: try values.decode(PresentationThemeFillStrokeForeground.self, forKey: .selectionControl),
                  deliveryFailedColors: try values.decode(PresentationThemeFillForeground.self, forKey: .deliveryFailed),
                  mediaHighlightOverlayColor: try decodeColor(values, .mediaHighlightOverlay))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.incoming, forKey: .incoming)
        try values.encode(self.outgoing, forKey: .outgoing)
        try values.encode(self.freeform, forKey: .freeform)
        try encodeColor(&values, self.infoPrimaryTextColor, .infoPrimaryText)
        try encodeColor(&values, self.infoLinkTextColor, .infoLinkText)
        try encodeColor(&values, self.outgoingCheckColor, .outgoingCheck)
        try encodeColor(&values, self.mediaDateAndStatusFillColor, .mediaDateAndStatusBg)
        try encodeColor(&values, self.mediaDateAndStatusTextColor, .mediaDateAndStatusText)
        try values.encode(self.shareButtonFillColor, forKey: .shareButtonBg)
        try values.encode(self.shareButtonStrokeColor, forKey: .shareButtonStroke)
        try values.encode(self.shareButtonForegroundColor, forKey: .shareButtonFg)
        try values.encode(self.mediaOverlayControlColors, forKey: .mediaOverlayControl)
        try values.encode(self.selectionControlColors, forKey: .selectionControl)
        try values.encode(self.deliveryFailedColors, forKey: .deliveryFailed)
        try encodeColor(&values, self.mediaHighlightOverlayColor, .mediaHighlightOverlay)
    }
}

extension PresentationThemeServiceMessageColorComponents: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case primaryText
        case linkHighlight
        case scam
        case dateFillStatic
        case dateFillFloat
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(fill: try decodeColor(values, .bg),
                  primaryText: try decodeColor(values, .primaryText),
                  linkHighlight: try decodeColor(values, .linkHighlight),
                  scam: try decodeColor(values, .scam),
                  dateFillStatic: try decodeColor(values, .dateFillStatic),
                  dateFillFloating: try decodeColor(values, .dateFillFloat))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.fill, .bg)
        try encodeColor(&values, self.primaryText, .primaryText)
        try encodeColor(&values, self.linkHighlight, .linkHighlight)
        try encodeColor(&values, self.scam, .scam)
        try encodeColor(&values, self.dateFillStatic, .dateFillStatic)
        try encodeColor(&values, self.dateFillFloating, .dateFillFloat)
    }
}

extension PresentationThemeServiceMessageColor: Codable {
    enum CodingKeys: String, CodingKey {
        case withDefaultWp
        case withCustomWp
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(withDefaultWallpaper: try values.decode(PresentationThemeServiceMessageColorComponents.self, forKey: .withDefaultWp),
                  withCustomWallpaper: try values.decode(PresentationThemeServiceMessageColorComponents.self, forKey: .withCustomWp))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.withDefaultWallpaper, forKey: .withDefaultWp)
        try values.encode(self.withCustomWallpaper, forKey: .withCustomWp)
    }
}

extension PresentationThemeServiceMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case components
        case unreadBarBg
        case unreadBarStroke
        case unreadBarText
        case dateText
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(components: try values.decode(PresentationThemeServiceMessageColor.self, forKey: .components),
                  unreadBarFillColor: try decodeColor(values, .unreadBarBg),
                  unreadBarStrokeColor: try decodeColor(values, .unreadBarStroke),
                  unreadBarTextColor: try decodeColor(values, .unreadBarText),
                  dateTextColor: try values.decode(PresentationThemeVariableColor.self, forKey: .dateText))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.components, forKey: .components)
        try encodeColor(&values, self.unreadBarFillColor, .unreadBarBg)
        try encodeColor(&values, self.unreadBarStrokeColor, .unreadBarStroke)
        try encodeColor(&values, self.unreadBarTextColor, .unreadBarText)
        try values.encode(self.dateTextColor, forKey: .dateText)
    }
}

extension PresentationThemeChatInputPanelMediaRecordingControl: Codable {
    enum CodingKeys: String, CodingKey {
        case button
        case micLevel
        case activeIcon
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(buttonColor: try decodeColor(values, .button),
                  micLevelColor: try decodeColor(values, .micLevel),
                  activeIconColor: try decodeColor(values, .activeIcon))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.buttonColor, .button)
        try encodeColor(&values, self.micLevelColor, .micLevel)
        try encodeColor(&values, self.activeIconColor, .activeIcon)
    }
}

extension PresentationThemeChatInputPanel: Codable {
    enum CodingKeys: String, CodingKey {
        case panelBg
        case panelSeparator
        case panelControlAccent
        case panelControl
        case panelControlDisabled
        case panelControlDestructive
        case inputBg
        case inputStroke
        case inputPlaceholder
        case inputText
        case inputControl
        case actionControlBg
        case actionControlFg
        case primaryText
        case secondaryText
        case mediaRecordDot
        case keyboard
        case mediaRecordControl
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(panelBackgroundColor: try decodeColor(values, .panelBg),
                  panelSeparatorColor: try decodeColor(values, .panelSeparator),
                  panelControlAccentColor: try decodeColor(values, .panelControlAccent),
                  panelControlColor: try decodeColor(values, .panelControl),
                  panelControlDisabledColor: try decodeColor(values, .panelControlDisabled),
                  panelControlDestructiveColor: try decodeColor(values, .panelControlDestructive),
                  inputBackgroundColor: try decodeColor(values, .inputBg),
                  inputStrokeColor: try decodeColor(values, .inputStroke),
                  inputPlaceholderColor: try decodeColor(values, .inputPlaceholder),
                  inputTextColor: try decodeColor(values, .inputText),
                  inputControlColor: try decodeColor(values, .inputControl),
                  actionControlFillColor: try decodeColor(values, .actionControlBg),
                  actionControlForegroundColor: try decodeColor(values, .actionControlFg),
                  primaryTextColor: try decodeColor(values, .primaryText),
                  secondaryTextColor: try decodeColor(values, .secondaryText),
                  mediaRecordingDotColor: try decodeColor(values, .mediaRecordDot),
                  keyboardColor: try values.decode(PresentationThemeKeyboardColor.self, forKey: .keyboard),
                  mediaRecordingControl: try values.decode(PresentationThemeChatInputPanelMediaRecordingControl.self, forKey: .mediaRecordControl))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.panelBackgroundColor, .panelBg)
        try encodeColor(&values, self.panelSeparatorColor, .panelSeparator)
        try encodeColor(&values, self.panelControlAccentColor, .panelControlAccent)
        try encodeColor(&values, self.panelControlColor, .panelControl)
        try encodeColor(&values, self.panelControlDisabledColor, .panelControlDisabled)
        try encodeColor(&values, self.panelControlDestructiveColor, .panelControlDestructive)
        try encodeColor(&values, self.inputBackgroundColor, .inputBg)
        try encodeColor(&values, self.inputStrokeColor, .inputStroke)
        try encodeColor(&values, self.inputPlaceholderColor, .inputPlaceholder)
        try encodeColor(&values, self.inputTextColor, .inputText)
        try encodeColor(&values, self.inputControlColor, .inputControl)
        try encodeColor(&values, self.actionControlFillColor, .actionControlBg)
        try encodeColor(&values, self.actionControlForegroundColor, .actionControlFg)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try encodeColor(&values, self.secondaryTextColor, .secondaryText)
        try encodeColor(&values, self.mediaRecordingDotColor, .mediaRecordDot)
        try values.encode(self.keyboardColor, forKey: .keyboard)
        try values.encode(self.mediaRecordingControl, forKey: .mediaRecordControl)
    }
}

extension PresentationThemeInputMediaPanel: Codable {
    enum CodingKeys: String, CodingKey {
        case panelSeparator
        case panelIcon
        case panelHighlightedIconBg
        case stickersBg
        case stickersSectionText
        case stickersSearchBg
        case stickersSearchPlaceholder
        case stickersSearchPrimary
        case stickersSearchControl
        case gifsBg
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(panelSeparatorColor: try decodeColor(values, .panelSeparator),
                  panelIconColor: try decodeColor(values, .panelIcon),
                  panelHighlightedIconBackgroundColor: try decodeColor(values, .panelHighlightedIconBg),
                  stickersBackgroundColor: try decodeColor(values, .stickersBg),
                  stickersSectionTextColor: try decodeColor(values, .stickersSectionText),
                  stickersSearchBackgroundColor: try decodeColor(values, .stickersSearchBg),
                  stickersSearchPlaceholderColor: try decodeColor(values, .stickersSearchPlaceholder),
                  stickersSearchPrimaryColor: try decodeColor(values, .stickersSearchPrimary),
                  stickersSearchControlColor: try decodeColor(values, .stickersSearchControl),
                  gifsBackgroundColor: try decodeColor(values, .gifsBg))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.panelSeparatorColor, .panelSeparator)
        try encodeColor(&values, self.panelIconColor, .panelIcon)
        try encodeColor(&values, self.panelHighlightedIconBackgroundColor, .panelHighlightedIconBg)
        try encodeColor(&values, self.stickersBackgroundColor, .stickersBg)
        try encodeColor(&values, self.stickersSectionTextColor, .stickersSectionText)
        try encodeColor(&values, self.stickersSearchBackgroundColor, .stickersSearchBg)
        try encodeColor(&values, self.stickersSearchPlaceholderColor, .stickersSearchPlaceholder)
        try encodeColor(&values, self.stickersSearchPrimaryColor, .stickersSearchPrimary)
        try encodeColor(&values, self.stickersSearchControlColor, .stickersSearchControl)
        try encodeColor(&values, self.gifsBackgroundColor, .gifsBg)
    }
}

extension PresentationThemeInputButtonPanel: Codable {
    enum CodingKeys: String, CodingKey {
        case panelBg
        case panelSeparator
        case buttonBg
        case buttonStroke
        case buttonHighlightedBg
        case buttonHighlightedStroke
        case buttonText
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(panelSeparatorColor: try decodeColor(values, .panelSeparator),
                  panelBackgroundColor: try decodeColor(values, .panelBg),
                  buttonFillColor: try decodeColor(values, .buttonBg),
                  buttonStrokeColor: try decodeColor(values, .buttonStroke),
                  buttonHighlightedFillColor: try decodeColor(values, .buttonHighlightedBg),
                  buttonHighlightedStrokeColor: try decodeColor(values, .buttonHighlightedStroke),
                  buttonTextColor: try decodeColor(values, .buttonText))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.panelBackgroundColor, .panelBg)
        try encodeColor(&values, self.panelSeparatorColor, .panelSeparator)
        try encodeColor(&values, self.buttonFillColor, .buttonBg)
        try encodeColor(&values, self.buttonStrokeColor, .buttonStroke)
        try encodeColor(&values, self.buttonHighlightedFillColor, .buttonHighlightedBg)
        try encodeColor(&values, self.buttonHighlightedStrokeColor, .buttonHighlightedStroke)
        try encodeColor(&values, self.buttonTextColor, .buttonText)
    }
}

extension PresentationThemeChatHistoryNavigation: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case stroke
        case fg
        case badgeBg
        case badgeStroke
        case badgeText
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(fillColor: try decodeColor(values, .bg),
                  strokeColor: try decodeColor(values, .stroke),
                  foregroundColor: try decodeColor(values, .fg),
                  badgeBackgroundColor: try decodeColor(values, .badgeBg),
                  badgeStrokeColor: try decodeColor(values, .badgeStroke),
                  badgeTextColor: try decodeColor(values, .badgeText))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.fillColor, .bg)
        try encodeColor(&values, self.strokeColor, .stroke)
        try encodeColor(&values, self.foregroundColor, .fg)
        try encodeColor(&values, self.badgeBackgroundColor, .badgeBg)
        try encodeColor(&values, self.badgeStrokeColor, .badgeStroke)
        try encodeColor(&values, self.badgeTextColor, .badgeText)
    }
}

extension PresentationThemeChat: Codable {
    enum CodingKeys: String, CodingKey {
        case defaultWallpaper
        case message
        case serviceMessage
        case inputPanel
        case inputMediaPanel
        case inputButtonPanel
        case historyNav
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(defaultWallpaper: try values.decode(TelegramWallpaper.self, forKey: .defaultWallpaper),
                  message: try values.decode(PresentationThemeChatMessage.self, forKey: .message),
                  serviceMessage: try values.decode(PresentationThemeServiceMessage.self, forKey: .serviceMessage),
                  inputPanel: try values.decode(PresentationThemeChatInputPanel.self, forKey: .inputPanel),
                  inputMediaPanel: try values.decode(PresentationThemeInputMediaPanel.self, forKey: .inputMediaPanel),
                  inputButtonPanel: try values.decode(PresentationThemeInputButtonPanel.self, forKey: .inputButtonPanel),
                  historyNavigation: try values.decode(PresentationThemeChatHistoryNavigation.self, forKey: .historyNav))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.defaultWallpaper, forKey: .defaultWallpaper)
        try values.encode(self.message, forKey: .message)
        try values.encode(self.serviceMessage, forKey: .serviceMessage)
        try values.encode(self.inputPanel, forKey: .inputPanel)
        try values.encode(self.inputMediaPanel, forKey: .inputMediaPanel)
        try values.encode(self.inputButtonPanel, forKey: .inputButtonPanel)
        try values.encode(self.historyNavigation, forKey: .historyNav)
    }
}

extension PresentationThemeExpandedNotificationNavigationBar: Codable {
    enum CodingKeys: String, CodingKey {
        case background
        case primaryText
        case control
        case separator
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundColor: try decodeColor(values, .background),
                  primaryTextColor: try decodeColor(values, .primaryText),
                  controlColor: try decodeColor(values, .control),
                  separatorColor: try decodeColor(values, .separator))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.backgroundColor, .background)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try encodeColor(&values, self.controlColor, .control)
        try encodeColor(&values, self.separatorColor, .separator)
    }
}

extension PresentationThemeExpandedNotification: Codable {
    enum CodingKeys: String, CodingKey {
        case bgType
        case navBar
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(backgroundType: try values.decode(PresentationThemeExpandedNotificationBackgroundType.self, forKey: .bgType),
                  navigationBar: try values.decode(PresentationThemeExpandedNotificationNavigationBar.self, forKey: .navBar))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(self.backgroundType, forKey: .bgType)
        try values.encode(self.navigationBar, forKey: .navBar)
    }
}

extension PresentationThemeInAppNotification: Codable {
    enum CodingKeys: String, CodingKey {
        case bg
        case primaryText
        case expanded
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(fillColor: try decodeColor(values, .bg),
                  primaryTextColor: try decodeColor(values, .primaryText),
                  expandedNotification: try values.decode(PresentationThemeExpandedNotification.self, forKey: .expanded))
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try encodeColor(&values, self.fillColor, .bg)
        try encodeColor(&values, self.primaryTextColor, .primaryText)
        try values.encode(self.expandedNotification, forKey: .expanded)
    }
}

extension PresentationThemeName: Codable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        self = .custom(try value.decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case let .builtin(name):
                switch name {
                    case .day:
                        try container.encode("Day")
                    case .dayClassic:
                        try container.encode("Classic")
                    case .nightAccent:
                        try container.encode("Night Tinted")
                    case .night:
                        try container.encode("Night")
                }
            case let .custom(name):
                try container.encode(name)
        }
    }
}

extension PresentationTheme: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case author
        case dark
        case intro
        case passcode
        case root
        case list
        case chatList
        case chat
        case actionSheet
        case notification
    }
    
    public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(name: try values.decode(PresentationThemeName.self, forKey: .name),
                  author: (try? values.decode(String.self, forKey: .author)) ?? nil,
                  overallDarkAppearance: (try? values.decode(Bool.self, forKey: .dark)) ?? false,
                  intro: try values.decode(PresentationThemeIntro.self, forKey: .intro),
                  passcode: try values.decode(PresentationThemePasscode.self, forKey: .passcode),
                  rootController: try values.decode(PresentationThemeRootController.self, forKey: .root),
                  list: try values.decode(PresentationThemeList.self, forKey: .list),
                  chatList: try values.decode(PresentationThemeChatList.self, forKey: .chatList),
                  chat: try values.decode(PresentationThemeChat.self, forKey: .chat),
                  actionSheet: try values.decode(PresentationThemeActionSheet.self, forKey: .actionSheet),
                  inAppNotification: try values.decode(PresentationThemeInAppNotification.self, forKey: .notification))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.author, forKey: .author)
        try container.encode(self.overallDarkAppearance, forKey: .dark)
        try container.encode(self.intro, forKey: .intro)
        try container.encode(self.passcode, forKey: .passcode)
        try container.encode(self.rootController, forKey: .root)
        try container.encode(self.list, forKey: .list)
        try container.encode(self.chatList, forKey: .chatList)
        try container.encode(self.chat, forKey: .chat)
        try container.encode(self.actionSheet, forKey: .actionSheet)
        try container.encode(self.inAppNotification, forKey: .notification)
    }
}
