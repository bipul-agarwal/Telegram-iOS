import Foundation
import UIKit
import AsyncDisplayKit
import Display
import SwiftSignalKit
import Postbox
import TelegramCore
import TelegramPresentationData
import LegacyComponents
import TelegramUIPrivateModule

final class StickerPaneSearchInteraction {
    let open: (StickerPackCollectionInfo) -> Void
    let install: (StickerPackCollectionInfo) -> Void
    let sendSticker: (FileMediaReference, ASDisplayNode, CGRect) -> Void
    let getItemIsPreviewed: (StickerPackItem) -> Bool
    
    init(open: @escaping (StickerPackCollectionInfo) -> Void, install: @escaping (StickerPackCollectionInfo) -> Void, sendSticker: @escaping (FileMediaReference, ASDisplayNode, CGRect) -> Void, getItemIsPreviewed: @escaping (StickerPackItem) -> Bool) {
        self.open = open
        self.install = install
        self.sendSticker = sendSticker
        self.getItemIsPreviewed = getItemIsPreviewed
    }
}

private enum StickerSearchEntryId: Equatable, Hashable {
    case sticker(String?, Int64)
    case global(ItemCollectionId)
}

private enum StickerSearchEntry: Identifiable, Comparable {
    case sticker(index: Int, code: String?, stickerItem: FoundStickerItem, theme: PresentationTheme)
    case global(index: Int, info: StickerPackCollectionInfo, topItems: [StickerPackItem], installed: Bool)
    
    var stableId: StickerSearchEntryId {
        switch self {
        case let .sticker(_, code, stickerItem, _):
            return .sticker(code, stickerItem.file.fileId.id)
        case let .global(_, info, _, _):
            return .global(info.id)
        }
    }
    
    static func ==(lhs: StickerSearchEntry, rhs: StickerSearchEntry) -> Bool {
        switch lhs {
        case let .sticker(lhsIndex, lhsCode, lhsStickerItem, lhsTheme):
            if case let .sticker(rhsIndex, rhsCode, rhsStickerItem, rhsTheme) = rhs {
                if lhsIndex != rhsIndex {
                    return false
                }
                if lhsCode != rhsCode {
                    return false
                }
                if lhsStickerItem != rhsStickerItem {
                    return false
                }
                if lhsTheme !== rhsTheme {
                    return false
                }
                return true
            } else {
                return false
            }
        case let .global(index, info, topItems, installed):
            if case .global(index, info, topItems, installed) = rhs {
                return true
            } else {
                return false
            }
        }
    }
    
    static func <(lhs: StickerSearchEntry, rhs: StickerSearchEntry) -> Bool {
        switch lhs {
        case let .sticker(lhsIndex, _, _, _):
            switch rhs {
            case let .sticker(rhsIndex, _, _, _):
                return lhsIndex < rhsIndex
            default:
                return true
            }
        case let .global(lhsIndex, _, _, _):
            switch rhs {
            case .sticker:
                return false
            case let .global(rhsIndex, _, _, _):
                return lhsIndex < rhsIndex
            }
        }
    }
    
    func item(account: Account, theme: PresentationTheme, strings: PresentationStrings, interaction: StickerPaneSearchInteraction, inputNodeInteraction: ChatMediaInputNodeInteraction) -> GridItem {
        switch self {
        case let .sticker(_, code, stickerItem, theme):
            return StickerPaneSearchStickerItem(account: account, code: code, stickerItem: stickerItem, inputNodeInteraction: inputNodeInteraction, theme: theme, selected: { node, rect in
                interaction.sendSticker(.standalone(media: stickerItem.file), node, rect)
            })
        case let .global(_, info, topItems, installed):
            return StickerPaneSearchGlobalItem(account: account, theme: theme, strings: strings, info: info, topItems: topItems, installed: installed, unread: false, open: {
                interaction.open(info)
            }, install: {
                interaction.install(info)
            }, getItemIsPreviewed: { item in
                return interaction.getItemIsPreviewed(item)
            })
        }
    }
}

private struct StickerPaneSearchGridTransition {
    let deletions: [Int]
    let insertions: [GridNodeInsertItem]
    let updates: [GridNodeUpdateItem]
    let updateFirstIndexInSectionOffset: Int?
    let stationaryItems: GridNodeStationaryItems
    let scrollToItem: GridNodeScrollToItem?
    let animated: Bool
}

private func preparedChatMediaInputGridEntryTransition(account: Account, theme: PresentationTheme, strings: PresentationStrings, from fromEntries: [StickerSearchEntry], to toEntries: [StickerSearchEntry], interaction: StickerPaneSearchInteraction, inputNodeInteraction: ChatMediaInputNodeInteraction) -> StickerPaneSearchGridTransition {
    let stationaryItems: GridNodeStationaryItems = .none
    let scrollToItem: GridNodeScrollToItem? = nil
    var animated = false
    animated = true
    
    let (deleteIndices, indicesAndItems, updateIndices) = mergeListsStableWithUpdates(leftList: fromEntries, rightList: toEntries)
    
    let deletions = deleteIndices
    let insertions = indicesAndItems.map { GridNodeInsertItem(index: $0.0, item: $0.1.item(account: account, theme: theme, strings: strings, interaction: interaction, inputNodeInteraction: inputNodeInteraction), previousIndex: $0.2) }
    let updates = updateIndices.map { GridNodeUpdateItem(index: $0.0, previousIndex: $0.2, item: $0.1.item(account: account, theme: theme, strings: strings, interaction: interaction, inputNodeInteraction: inputNodeInteraction)) }
    
    let firstIndexInSectionOffset = 0
    
    return StickerPaneSearchGridTransition(deletions: deletions, insertions: insertions, updates: updates, updateFirstIndexInSectionOffset: firstIndexInSectionOffset, stationaryItems: stationaryItems, scrollToItem: scrollToItem, animated: animated)
}

final class StickerPaneSearchContentNode: ASDisplayNode, PaneSearchContentNode {
    private let context: AccountContext
    private let controllerInteraction: ChatControllerInteraction
    private let inputNodeInteraction: ChatMediaInputNodeInteraction
    private var interaction: StickerPaneSearchInteraction?
    
    private var theme: PresentationTheme
    private var strings: PresentationStrings
    
    private let trendingPane: ChatMediaInputTrendingPane
    private let gridNode: GridNode
    private let notFoundNode: ASImageNode
    private let notFoundLabel: ImmediateTextNode
    
    private var validLayout: CGSize?
    
    private var enqueuedTransitions: [StickerPaneSearchGridTransition] = []
    
    private let searchDisposable = MetaDisposable()
    
    private let queue = Queue()
    private let currentEntries = Atomic<[StickerSearchEntry]?>(value: nil)
    private let currentRemotePacks = Atomic<FoundStickerSets?>(value: nil)
    
    private let _ready = Promise<Void>()
    var ready: Signal<Void, NoError> {
        return self._ready.get()
    }
    
    var deactivateSearchBar: (() -> Void)?
    var updateActivity: ((Bool) -> Void)?
    
    init(context: AccountContext, theme: PresentationTheme, strings: PresentationStrings, controllerInteraction: ChatControllerInteraction, inputNodeInteraction: ChatMediaInputNodeInteraction) {
        self.context = context
        self.controllerInteraction = controllerInteraction
        self.inputNodeInteraction = inputNodeInteraction
        
        self.theme = theme
        self.strings = strings
        
        self.trendingPane = ChatMediaInputTrendingPane(context: context, controllerInteraction: controllerInteraction, getItemIsPreviewed: { [weak inputNodeInteraction] item in
            return inputNodeInteraction?.previewedStickerPackItem == .pack(item)
        })
        
        self.gridNode = GridNode()
        
        self.notFoundNode = ASImageNode()
        self.notFoundNode.displayWithoutProcessing = true
        self.notFoundNode.displaysAsynchronously = false
        self.notFoundNode.clipsToBounds = false
        
        self.notFoundLabel = ImmediateTextNode()
        self.notFoundLabel.displaysAsynchronously = false
        self.notFoundLabel.isUserInteractionEnabled = false
        self.notFoundNode.addSubnode(self.notFoundLabel)
        
        self.gridNode.isHidden = true
        self.trendingPane.isHidden = false
        self.notFoundNode.isHidden = true
        
        super.init()
        
        self.addSubnode(self.trendingPane)
        self.addSubnode(self.gridNode)
        self.addSubnode(self.notFoundNode)
        
        self.gridNode.scrollView.alwaysBounceVertical = true
        self.gridNode.scrollingInitiated = { [weak self] in
            self?.deactivateSearchBar?()
        }
        
        self.trendingPane.scrollingInitiated = { [weak self] in
            self?.deactivateSearchBar?()
        }
        
        self.interaction = StickerPaneSearchInteraction(open: { [weak self] info in
            if let strongSelf = self {
                strongSelf.view.window?.endEditing(true)
                
                let controller = StickerPackPreviewController(context: strongSelf.context, stickerPack: .id(id: info.id.id, accessHash: info.accessHash), parentNavigationController: strongSelf.controllerInteraction.navigationController())
                controller.sendSticker = { [weak self] fileReference, sourceNode, sourceRect in
                    if let strongSelf = self {
                        return strongSelf.controllerInteraction.sendSticker(fileReference, false, sourceNode, sourceRect)
                    } else {
                        return false
                    }
                }
                strongSelf.controllerInteraction.presentController(controller, ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
            }
        }, install: { [weak self] info in
            if let strongSelf = self {
                let _ = (loadedStickerPack(postbox: strongSelf.context.account.postbox, network: strongSelf.context.account.network, reference: .id(id: info.id.id, accessHash: info.accessHash), forceActualized: false)
                |> mapToSignal { result -> Signal<Void, NoError> in
                    switch result {
                    case let .result(info, items, installed):
                        if installed {
                            return .complete()
                        } else {
                            return addStickerPackInteractively(postbox: strongSelf.context.account.postbox, info: info, items: items)
                        }
                    case .fetching:
                        break
                    case .none:
                        break
                    }
                    return .complete()
                }).start()
            }
        }, sendSticker: { [weak self] file, sourceNode, sourceRect in
            if let strongSelf = self {
                strongSelf.controllerInteraction.sendSticker(file, false, sourceNode, sourceRect)
            }
        }, getItemIsPreviewed: { item in
            return inputNodeInteraction.previewedStickerPackItem == .pack(item)
        })
        
        self._ready.set(self.trendingPane.ready)
        self.trendingPane.activate()
    
        self.updateThemeAndStrings(theme: theme, strings: strings)
    }
    
    deinit {
        self.searchDisposable.dispose()
    }
    
    func updateText(_ text: String, languageCode: String?) {
        let signal: Signal<([(String?, FoundStickerItem)], FoundStickerSets, Bool, FoundStickerSets?)?, NoError>
        if !text.isEmpty {
            let account = self.context.account
            let stickers: Signal<[(String?, FoundStickerItem)], NoError> = Signal { subscriber in
                var signals: Signal<[Signal<(String?, [FoundStickerItem]), NoError>], NoError> = .single([])
                
                let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if query.isSingleEmoji {
                    signals = .single([searchStickers(account: account, query: text.basicEmoji.0)
                    |> map { (nil, $0) }])
                } else if query.count > 1, let languageCode = languageCode, !languageCode.isEmpty && languageCode != "emoji" {
                    var signal = searchEmojiKeywords(postbox: account.postbox, inputLanguageCode: languageCode, query: query.lowercased(), completeMatch: query.count < 3)
                    if !languageCode.lowercased().hasPrefix("en") {
                        signal = signal
                        |> mapToSignal { keywords in
                            return .single(keywords)
                            |> then(
                                searchEmojiKeywords(postbox: account.postbox, inputLanguageCode: "en-US", query: query.lowercased(), completeMatch: query.count < 3)
                                |> map { englishKeywords in
                                    return keywords + englishKeywords
                                }
                            )
                        }
                    }
                    
                    signals = signal
                    |> map { keywords -> [Signal<(String?, [FoundStickerItem]), NoError>] in
                        var signals: [Signal<(String?, [FoundStickerItem]), NoError>] = []
                        let emoticons = keywords.flatMap { $0.emoticons }
                        for emoji in emoticons {
                            signals.append(searchStickers(account: self.context.account, query: emoji.basicEmoji.0)
                            |> take(1)
                            |> map { (emoji, $0) })
                        }
                        return signals
                    }
                }
                
                return (signals
                |> mapToSignal { signals in
                    return combineLatest(signals)
                }).start(next: { results in
                    var result: [(String?, FoundStickerItem)] = []
                    for (emoji, stickers) in results {
                        for sticker in stickers {
                            result.append((emoji, sticker))
                        }
                    }
                    subscriber.putNext(result)
                }, completed: {
                    subscriber.putCompletion()
                })
            }
            
            let local = searchStickerSets(postbox: context.account.postbox, query: text)
            let remote = searchStickerSetsRemotely(network: context.account.network, query: text)
            |> delay(0.2, queue: Queue.mainQueue())
            let packs = local
            |> mapToSignal { result -> Signal<(FoundStickerSets, Bool, FoundStickerSets?), NoError> in
                var localResult = result
                if let currentRemote = self.currentRemotePacks.with ({ $0 }) {
                    localResult = localResult.merge(with: currentRemote)
                }
                return .single((localResult, false, nil))
                |> then(remote |> map { remote -> (FoundStickerSets, Bool, FoundStickerSets?) in
                    return (result.merge(with: remote), true, remote)
                })
            }
            signal = combineLatest(stickers, packs)
            |> map { stickers, packs -> ([(String?, FoundStickerItem)], FoundStickerSets, Bool, FoundStickerSets?)? in
                return (stickers, packs.0, packs.1, packs.2)
            }
            self.updateActivity?(true)
        } else {
            signal = .single(nil)
            self.updateActivity?(false)
        }
        
        self.searchDisposable.set((signal
        |> deliverOn(self.queue)).start(next: { [weak self] result in
            Queue.mainQueue().async {
                guard let strongSelf = self, let interaction = strongSelf.interaction else {
                    return
                }
                
                var entries: [StickerSearchEntry] = []
                if let (stickers, packs, final, remote) = result {
                    if let remote = remote {
                        let _ = strongSelf.currentRemotePacks.swap(remote)
                    }
                    strongSelf.gridNode.isHidden = false
                    strongSelf.trendingPane.isHidden = true
                    
                    if final {
                        strongSelf.updateActivity?(false)
                    }
                    
                    var index = 0
                    var existingStickerIds = Set<MediaId>()
                    var previousCode: String?
                    for (code, sticker) in stickers {
                        if let id = sticker.file.id, !existingStickerIds.contains(id) {
                            entries.append(.sticker(index: index, code: code != previousCode ? code : nil, stickerItem: sticker, theme: strongSelf.theme))
                            index += 1
                            
                            previousCode = code
                            existingStickerIds.insert(id)
                        }
                    }
                    for (collectionId, info, _, installed) in packs.infos {
                        if let info = info as? StickerPackCollectionInfo {
                            var topItems: [StickerPackItem] = []
                            for e in packs.entries {
                                if let item = e.item as? StickerPackItem {
                                    if e.index.collectionId == collectionId {
                                        topItems.append(item)
                                    }
                                }
                            }
                            entries.append(.global(index: index, info: info, topItems: topItems, installed: installed))
                            index += 1
                        }
                    }
                    
                    if final || !entries.isEmpty {
                        strongSelf.notFoundNode.isHidden = !entries.isEmpty
                    }
                } else {
                    let _ = strongSelf.currentRemotePacks.swap(nil)
                    strongSelf.updateActivity?(false)
                    strongSelf.gridNode.isHidden = true
                    strongSelf.notFoundNode.isHidden = true
                    strongSelf.trendingPane.isHidden = false
                }
                
                let previousEntries = strongSelf.currentEntries.swap(entries)
                let transition = preparedChatMediaInputGridEntryTransition(account: strongSelf.context.account, theme: strongSelf.theme, strings: strongSelf.strings, from: previousEntries ?? [], to: entries, interaction: interaction, inputNodeInteraction: strongSelf.inputNodeInteraction)
                strongSelf.enqueueTransition(transition)
            }
        }))
    }
    
    func updateThemeAndStrings(theme: PresentationTheme, strings: PresentationStrings) {
        self.notFoundNode.image = generateTintedImage(image: UIImage(bundleImageName: "Chat/Input/Media/StickersNotFoundIcon"), color: theme.list.freeMonoIconColor)
        self.notFoundLabel.attributedText = NSAttributedString(string: strings.Stickers_NoStickersFound, font: Font.medium(14.0), textColor: theme.list.freeTextColor)
    }
    
    private func enqueueTransition(_ transition: StickerPaneSearchGridTransition) {
        self.enqueuedTransitions.append(transition)
        
        if self.validLayout != nil {
            while !self.enqueuedTransitions.isEmpty {
                self.dequeueTransition()
            }
        }
    }
    
    private func dequeueTransition() {
        if let transition = self.enqueuedTransitions.first {
            self.enqueuedTransitions.remove(at: 0)
            
            let itemTransition: ContainedViewLayoutTransition = .immediate
            self.gridNode.transaction(GridNodeTransaction(deleteItems: transition.deletions, insertItems: transition.insertions, updateItems: transition.updates, scrollToItem: transition.scrollToItem, updateLayout: nil, itemTransition: itemTransition, stationaryItems: .none, updateFirstIndexInSectionOffset: transition.updateFirstIndexInSectionOffset), completion: { _ in })
        }
    }
    
    func updatePreviewing(animated: Bool) {
        self.gridNode.forEachItemNode { itemNode in
            if let itemNode = itemNode as? StickerPaneSearchStickerItemNode {
                itemNode.updatePreviewing(animated: animated)
            } else if let itemNode = itemNode as? StickerPaneSearchGlobalItemNode {
                itemNode.updatePreviewing(animated: animated)
            }
        }
        self.trendingPane.updatePreviewing(animated: animated)
    }
    
    func itemAt(point: CGPoint) -> (ASDisplayNode, Any)? {
        if !self.trendingPane.isHidden {
            if let (itemNode, item) = self.trendingPane.itemAt(point: self.view.convert(point, to: self.trendingPane.view)) {
                return (itemNode, StickerPreviewPeekItem.pack(item))
            }
        } else {
            if let itemNode = self.gridNode.itemNodeAtPoint(self.view.convert(point, to: self.gridNode.view)) {
                if let itemNode = itemNode as? StickerPaneSearchStickerItemNode, let stickerItem = itemNode.stickerItem {
                    return (itemNode, StickerPreviewPeekItem.found(stickerItem))
                } else if let itemNode = itemNode as? StickerPaneSearchGlobalItemNode {
                    if let (node, item) = itemNode.itemAt(point: self.view.convert(point, to: itemNode.view)) {
                        return (node, StickerPreviewPeekItem.pack(item))
                    }
                }
            }
        }
        return nil
    }
    
    func updateLayout(size: CGSize, leftInset: CGFloat, rightInset: CGFloat, bottomInset: CGFloat, inputHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        let firstLayout = self.validLayout == nil

        self.validLayout = size
        
        if let image = self.notFoundNode.image {
            let areaHeight = size.height - inputHeight
            
            let labelSize = self.notFoundLabel.updateLayout(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
            
            transition.updateFrame(node: self.notFoundNode, frame: CGRect(origin: CGPoint(x: floor((size.width - image.size.width) / 2.0), y: floor((areaHeight - image.size.height - labelSize.height) / 2.0)), size: image.size))
            transition.updateFrame(node: self.notFoundLabel, frame: CGRect(origin: CGPoint(x: floor((image.size.width - labelSize.width) / 2.0), y: image.size.height + 8.0), size: labelSize))
        }
        
        let contentFrame = CGRect(origin: CGPoint(), size: size)
        self.gridNode.transaction(GridNodeTransaction(deleteItems: [], insertItems: [], updateItems: [], scrollToItem: nil, updateLayout: GridNodeUpdateLayout(layout: GridNodeLayout(size: contentFrame.size, insets: UIEdgeInsets(top: 4.0, left: 0.0, bottom: 4.0 + bottomInset, right: 0.0), preloadSize: 300.0, type: .fixed(itemSize: CGSize(width: 75.0, height: 75.0), fillWidth: nil, lineSpacing: 0.0, itemSpacing: nil)), transition: transition), itemTransition: .immediate, stationaryItems: .none, updateFirstIndexInSectionOffset: nil), completion: { _ in })

        transition.updateFrame(node: self.trendingPane, frame: contentFrame)
        self.trendingPane.updateLayout(size: contentFrame.size, topInset: 0.0, bottomInset: bottomInset, isExpanded: false, isVisible: true, transition: transition)
        
        transition.updateFrame(node: self.gridNode, frame: contentFrame)
        if firstLayout {
            while !self.enqueuedTransitions.isEmpty {
                self.dequeueTransition()
            }
        }
    }
    
    func animateIn(additivePosition: CGFloat, transition: ContainedViewLayoutTransition) {
        self.gridNode.alpha = 0.0
        transition.updateAlpha(node: self.gridNode, alpha: 1.0, completion: { _ in
        })
        self.trendingPane.alpha = 0.0
        transition.updateAlpha(node: self.trendingPane, alpha: 1.0, completion: { _ in
        })
        
        if case let .animated(duration, curve) = transition {
            self.trendingPane.layer.animatePosition(from: CGPoint(x: 0.0, y: additivePosition), to: CGPoint(), duration: duration, timingFunction: curve.timingFunction, additive: true)
        }
    }
    
    func animateOut(transition: ContainedViewLayoutTransition) {
        transition.updateAlpha(node: self.gridNode, alpha: 0.0, completion: { _ in
        })
        transition.updateAlpha(node: self.trendingPane, alpha: 0.0, completion: { _ in
        })
        transition.updateAlpha(node: self.notFoundNode, alpha: 0.0, completion: { _ in
        })
    }
}
