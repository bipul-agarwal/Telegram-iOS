import Foundation
import UIKit
import Display
import AsyncDisplayKit
import Postbox
import TelegramCore
import SwiftSignalKit

final class InstantPageReferenceController: ViewController {
    private var controllerNode: InstantPageReferenceControllerNode {
        return self.displayNode as! InstantPageReferenceControllerNode
    }
    
    private var animatedIn = false
    
    private let context: AccountContext
    private let theme: InstantPageTheme
    private let webPage: TelegramMediaWebpage
    private let anchorText: NSAttributedString
    private let openUrl: (InstantPageUrlItem) -> Void
    private let openUrlIn: (InstantPageUrlItem) -> Void
    private let present: (ViewController, Any?) -> Void
    
    init(context: AccountContext, theme: InstantPageTheme, webPage: TelegramMediaWebpage, anchorText: NSAttributedString, openUrl: @escaping (InstantPageUrlItem) -> Void, openUrlIn: @escaping (InstantPageUrlItem) -> Void, present: @escaping (ViewController, Any?) -> Void) {
        self.context = context
        self.theme = theme
        self.webPage = webPage
        self.anchorText = anchorText
        self.openUrl = openUrl
        self.openUrlIn = openUrlIn
        self.present = present
        
        super.init(navigationBarPresentationData: nil)
        
        self.statusBar.statusBarStyle = .Ignore
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadDisplayNode() {
        self.displayNode = InstantPageReferenceControllerNode(context: self.context, theme: self.theme, webPage: self.webPage, anchorText: self.anchorText, openUrl: self.openUrl, openUrlIn: self.openUrlIn, present: self.present)
        self.controllerNode.dismiss = { [weak self] in
            self?.presentingViewController?.dismiss(animated: false, completion: nil)
        }
        self.controllerNode.close = { [weak self] in
            self?.dismiss()
        }
    }
    
    override public func loadView() {
        super.loadView()
        
        self.statusBar.removeFromSupernode()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.animatedIn {
            self.animatedIn = true
            self.controllerNode.animateIn()
        }
    }
    
    override public func dismiss(completion: (() -> Void)? = nil) {
        self.controllerNode.animateOut(completion: completion)
    }
    
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.controllerNode.containerLayoutUpdated(layout, navigationBarHeight: self.navigationHeight, transition: transition)
    }
}
