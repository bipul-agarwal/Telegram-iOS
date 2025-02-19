import Foundation
import UIKit
import Display
import SwiftSignalKit
import Postbox
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences

private final class VoiceCallDataSavingControllerArguments {
    let updateSelection: (VoiceCallDataSaving) -> Void
    
    init(updateSelection: @escaping (VoiceCallDataSaving) -> Void) {
        self.updateSelection = updateSelection
    }
}

private enum VoiceCallDataSavingSection: Int32 {
    case dataSaving
}

private enum VoiceCallDataSavingEntry: ItemListNodeEntry {
    case never(PresentationTheme, String, Bool)
    case cellular(PresentationTheme, String, Bool)
    case always(PresentationTheme, String, Bool)
    case info(PresentationTheme, String)
    
    var section: ItemListSectionId {
        return VoiceCallDataSavingSection.dataSaving.rawValue
    }
    
    var stableId: Int32 {
        switch self {
            case .never:
                return 0
            case .cellular:
                return 1
            case .always:
                return 2
            case .info:
                return 3
        }
    }
    
    static func ==(lhs: VoiceCallDataSavingEntry, rhs: VoiceCallDataSavingEntry) -> Bool {
        switch lhs {
            case let .never(lhsTheme, lhsText, lhsValue):
                if case let .never(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                    return true
                } else {
                    return false
                }
            case let .cellular(lhsTheme, lhsText, lhsValue):
                if case let .cellular(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                    return true
                } else {
                    return false
                }
            case let .always(lhsTheme, lhsText, lhsValue):
                if case let .always(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                    return true
                } else {
                    return false
                }
            case let .info(lhsTheme, lhsText):
                if case let .info(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                    return true
                } else {
                    return false
                }
        }
    }
    
    static func <(lhs: VoiceCallDataSavingEntry, rhs: VoiceCallDataSavingEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(_ arguments: VoiceCallDataSavingControllerArguments) -> ListViewItem {
        switch self {
            case let .never(theme, text, value):
                return ItemListCheckboxItem(theme: theme, title: text, style: .left, checked: value, zeroSeparatorInsets: false, sectionId: self.section, action: {
                    arguments.updateSelection(.never)
                })
            case let .cellular(theme, text, value):
                return ItemListCheckboxItem(theme: theme, title: text, style: .left, checked: value, zeroSeparatorInsets: false, sectionId: self.section, action: {
                    arguments.updateSelection(.cellular)
                })
            case let .always(theme, text, value):
                return ItemListCheckboxItem(theme: theme, title: text, style: .left, checked: value, zeroSeparatorInsets: false, sectionId: self.section, action: {
                    arguments.updateSelection(.always)
                })
            case let .info(theme, text):
                return ItemListTextItem(theme: theme, text: .plain(text), sectionId: self.section)
        }
    }
}

private func stringForDataSavingOption(_ option: VoiceCallDataSaving, strings: PresentationStrings) -> String {
    switch option {
        case .never:
            return strings.CallSettings_Never
        case .cellular:
            return strings.CallSettings_OnMobile
        case .always:
            return strings.CallSettings_Always
        default:
            return ""
    }
}

private func voiceCallDataSavingControllerEntries(presentationData: PresentationData, dataSaving: VoiceCallDataSaving) -> [VoiceCallDataSavingEntry] {
    var entries: [VoiceCallDataSavingEntry] = []
    entries.append(.never(presentationData.theme, stringForDataSavingOption(.never, strings: presentationData.strings), dataSaving == .never))
    entries.append(.cellular(presentationData.theme, stringForDataSavingOption(.cellular, strings: presentationData.strings), dataSaving == .cellular))
    entries.append(.always(presentationData.theme, stringForDataSavingOption(.always, strings: presentationData.strings), dataSaving == .always))
    entries.append(.info(presentationData.theme, presentationData.strings.CallSettings_UseLessDataLongDescription))
    return entries
}

func voiceCallDataSavingController(context: AccountContext) -> ViewController {
    let sharedSettings = context.sharedContext.accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.voiceCallSettings])
    |> map { sharedData -> (VoiceCallSettings, AutodownloadSettings) in
        let voiceCallSettings: VoiceCallSettings
        if let value = sharedData.entries[ApplicationSpecificSharedDataKeys.voiceCallSettings] as? VoiceCallSettings {
            voiceCallSettings = value
        } else {
            voiceCallSettings = VoiceCallSettings.defaultSettings
        }
        
        let autodownloadSettings: AutodownloadSettings
        if let value = sharedData.entries[SharedDataKeys.autodownloadSettings] as? AutodownloadSettings {
            autodownloadSettings = value
        } else {
            autodownloadSettings = AutodownloadSettings.defaultSettings
        }
        
        return (voiceCallSettings, autodownloadSettings)
    }
    
    let arguments = VoiceCallDataSavingControllerArguments(updateSelection: { option in
        let _ = updateVoiceCallSettingsSettingsInteractively(accountManager: context.sharedContext.accountManager, { current in
            var current = current
            current.dataSaving = option
            return current
        }).start()
    })
    
    let signal = combineLatest(context.sharedContext.presentationData, sharedSettings) |> deliverOnMainQueue
        |> map { presentationData, sharedSettings -> (ItemListControllerState, (ItemListNodeState<VoiceCallDataSavingEntry>, VoiceCallDataSavingEntry.ItemGenerationArguments)) in
            
            let dataSaving = effectiveDataSaving(for: sharedSettings.0, autodownloadSettings: sharedSettings.1)
            
            let controllerState = ItemListControllerState(theme: presentationData.theme, title: .text(presentationData.strings.CallSettings_Title), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back), animateChanges: false)
            let listState = ItemListNodeState(entries: voiceCallDataSavingControllerEntries(presentationData: presentationData, dataSaving: dataSaving), style: .blocks, emptyStateItem: nil, animateChanges: false)
            
            return (controllerState, (listState, arguments))
        }
    
    let controller = ItemListController(context: context, state: signal)
    return controller
}
