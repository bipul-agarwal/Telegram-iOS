import Foundation
import UIKit
import Display
import AsyncDisplayKit

class ZoomableContentGalleryItemNode: GalleryItemNode, UIScrollViewDelegate {
    let scrollNode: ASScrollNode
    
    private var containerLayout: ContainerViewLayout?
    
    private var ignoreZoom = false
    private var ignoreZoomTransition: ContainedViewLayoutTransition?
    
    var zoomableContent: (CGSize, ASDisplayNode)? {
        didSet {
            if oldValue?.1 !== self.zoomableContent?.1 {
                if let node = oldValue?.1 {
                    node.view.removeFromSuperview()
                }
                if let node = self.zoomableContent?.1 {
                    self.scrollNode.addSubnode(node)
                }
            }
            self.resetScrollViewContents(transition: .immediate)
            self.centerScrollViewContents(transition: .immediate)
        }
    }
    
    override init() {
        self.scrollNode = ASScrollNode()
        if #available(iOSApplicationExtension 11.0, iOS 11.0, *) {
            self.scrollNode.view.contentInsetAdjustmentBehavior = .never
        }
        
        super.init()
        
        self.scrollNode.view.delegate = self
        self.scrollNode.view.showsVerticalScrollIndicator = false
        self.scrollNode.view.showsHorizontalScrollIndicator = false
        self.scrollNode.view.clipsToBounds = false
        self.scrollNode.view.scrollsToTop = false
        self.scrollNode.view.delaysContentTouches = false
        
        let tapRecognizer = TapLongTapOrDoubleTapGestureRecognizer(target: self, action: #selector(self.contentTap(_:)))
        tapRecognizer.tapActionAtPoint = { _ in
            return .waitForDoubleTap
        }
        
        self.scrollNode.view.addGestureRecognizer(tapRecognizer)
        
        self.addSubnode(self.scrollNode)
    }
    
    @objc func contentTap(_ recognizer: TapLongTapOrDoubleTapGestureRecognizer) {
        if recognizer.state == .ended {
            if let (gesture, location) = recognizer.lastRecognizedGestureAndLocation {
                switch gesture {
                    case .tap:
                        self.toggleControlsVisibility()
                    case .doubleTap:
                        if let contentView = self.zoomableContent?.1.view, self.scrollNode.view.zoomScale.isLessThanOrEqualTo(self.scrollNode.view.minimumZoomScale) {
                            let pointInView = self.scrollNode.view.convert(location, to: contentView)
                            
                            let newZoomScale = self.scrollNode.view.maximumZoomScale
                            let scrollViewSize = self.scrollNode.view.bounds.size
                            
                            let w = scrollViewSize.width / newZoomScale
                            let h = scrollViewSize.height / newZoomScale
                            let x = pointInView.x - (w / 2.0)
                            let y = pointInView.y - (h / 2.0)
                            
                            let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
                            
                            self.scrollNode.view.zoom(to: rectToZoomTo, animated: true)
                        } else {
                            self.scrollNode.view.setZoomScale(self.scrollNode.view.minimumZoomScale, animated: true)
                        }
                    default:
                        break
                }
            }
        }
    }
    
    override func containerLayoutUpdated(_ layout: ContainerViewLayout, navigationBarHeight: CGFloat, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, navigationBarHeight: navigationBarHeight, transition: transition)
        
        var shouldResetContents = false
        if let containerLayout = self.containerLayout {
            shouldResetContents = !containerLayout.size.equalTo(layout.size)
        } else {
            shouldResetContents = true
        }
        self.containerLayout = layout
        
        if shouldResetContents {
            var previousFrame: CGRect?
            var previousScale: CGFloat?
            if let (_, contentNode) = self.zoomableContent {
                previousFrame = contentNode.view.frame
                let t = contentNode.layer.transform
                previousScale = sqrt((t.m11 * t.m11) + (t.m12 * t.m12) + (t.m13 * t.m13))
            }
            
            transition.updateFrame(node: self.scrollNode, frame: CGRect(origin: CGPoint(), size: layout.size))
            self.resetScrollViewContents(transition: .immediate)
            
            if let (_, contentNode) = self.zoomableContent, let previousFrame = previousFrame, let previousScale = previousScale {
                transition.animatePosition(node: contentNode, from: CGPoint(x: previousFrame.midX, y: previousFrame.midY))
                switch transition {
                    case .immediate:
                        break
                    case let .animated(duration, curve):
                        let t = contentNode.layer.transform
                        let currentScale = sqrt((t.m11 * t.m11) + (t.m12 * t.m12) + (t.m13 * t.m13))
                        
                        contentNode.layer.animateScale(from: previousScale, to: currentScale, duration: duration, timingFunction: curve.timingFunction)
                }
            }
        }
    }
    
    private func resetScrollViewContents(transition: ContainedViewLayoutTransition) {
        guard let (contentSize, contentNode) = self.zoomableContent else {
            return
        }
        
        self.ignoreZoom = true
        self.ignoreZoomTransition = transition
        self.scrollNode.view.minimumZoomScale = 1.0
        self.scrollNode.view.maximumZoomScale = 1.0
        //self.scrollView.normalZoomScale = 1.0
        self.scrollNode.view.zoomScale = 1.0
        self.scrollNode.view.contentSize = contentSize
        
        contentNode.transform = CATransform3DIdentity
        contentNode.frame = CGRect(origin: CGPoint(), size: contentSize)
        
        self.centerScrollViewContents(transition: transition)
        self.ignoreZoom = false
        
        self.scrollNode.view.zoomScale = self.scrollNode.view.minimumZoomScale
        self.ignoreZoomTransition = nil
    }
    
    private func centerScrollViewContents(transition: ContainedViewLayoutTransition) {
        guard let (contentSize, contentNode) = self.zoomableContent else {
            return
        }
        
        let boundsSize = self.scrollNode.view.bounds.size
        if contentSize.width.isLessThanOrEqualTo(0.0) || contentSize.height.isLessThanOrEqualTo(0.0) || boundsSize.width.isLessThanOrEqualTo(0.0) || boundsSize.height.isLessThanOrEqualTo(0.0) {
            return
        }
        
        let scaleWidth = boundsSize.width / contentSize.width
        let scaleHeight = boundsSize.height / contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        var maxScale = max(scaleWidth, scaleHeight)
        maxScale = max(maxScale, minScale * 3.0)
        
        if (abs(maxScale - minScale) < 0.01) {
            maxScale = minScale
        }
        
        if !self.scrollNode.view.minimumZoomScale.isEqual(to: minScale) {
            self.scrollNode.view.minimumZoomScale = minScale
        }
        
        /*if !self.scrollView.normalZoomScale.isEqual(to: minScale) {
         self.scrollView.normalZoomScale = minScale
         }*/
        
        if !self.scrollNode.view.maximumZoomScale.isEqual(to: maxScale) {
            self.scrollNode.view.maximumZoomScale = maxScale
        }
        
        var contentFrame = contentNode.view.frame
        
        if boundsSize.width > contentFrame.size.width {
            contentFrame.origin.x = (boundsSize.width - contentFrame.size.width) / 2.0
        } else {
            contentFrame.origin.x = 0.0
        }
        
        if boundsSize.height >= contentFrame.size.height {
            contentFrame.origin.y = (boundsSize.height - contentFrame.size.height) / 2.0
        } else {
            contentFrame.origin.y = 0.0
        }
        
        if !self.ignoreZoom {
            transition.updateFrame(view: contentNode.view, frame: contentFrame)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.zoomableContent?.1.view
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if !self.ignoreZoom {
            self.centerScrollViewContents(transition: self.ignoreZoomTransition ?? .immediate)
        }
        if self.scrollNode.view.zoomScale.isEqual(to: self.scrollNode.view.minimumZoomScale) {
            self.scrollNode.view.isScrollEnabled = false
        } else {
            self.scrollNode.view.isScrollEnabled = true
        }
    }
    
    override func contentSize() -> CGSize? {
        if let (_, contentNode) = self.zoomableContent {
            let size = contentNode.view.convert(contentNode.bounds, to: self.view).size
            return CGSize(width: floor(size.width), height: floor(size.height))
        }
        return nil
    }
}
