import Foundation
import UIKit
import Display
import TelegramCore
import TelegramPresentationData

private func generateCheckImage(partial: Bool, color: UIColor) -> UIImage? {
    return generateImage(CGSize(width: 11.0, height: 9.0), rotatedContext: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        context.translateBy(x: 1.0, y: 1.0)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(0.99)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        if partial {
            let _ = try? drawSvgPath(context, path: "M0.5,7 L7,0 S ")
        } else {
            let _ = try? drawSvgPath(context, path: "M0,4 L2.95157047,6.95157047 L2.95157047,6.95157047 C2.97734507,6.97734507 3.01913396,6.97734507 3.04490857,6.95157047 C3.04548448,6.95099456 3.04604969,6.95040803 3.04660389,6.9498112 L9.5,0 S ")
        }
    })
}

private func generateClockFrameImage(color: UIColor) -> UIImage? {
    return generateImage(CGSize(width: 11.0, height: 11.0), contextGenerator: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        context.setStrokeColor(color.cgColor)
        context.setFillColor(color.cgColor)
        let strokeWidth: CGFloat = 1.0
        context.setLineWidth(strokeWidth)
        context.strokeEllipse(in: CGRect(x: strokeWidth / 2.0, y: strokeWidth / 2.0, width: size.width - strokeWidth, height: size.height - strokeWidth))
        context.fill(CGRect(x: (11.0 - strokeWidth) / 2.0, y: strokeWidth * 3.0, width: strokeWidth, height: 11.0 / 2.0 - strokeWidth * 3.0))
    })
}

private func generateClockMinImage(color: UIColor) -> UIImage? {
    return generateImage(CGSize(width: 11.0, height: 11.0), contextGenerator: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        context.setFillColor(color.cgColor)
        let strokeWidth: CGFloat = 1.0
        context.fill(CGRect(x: (11.0 - strokeWidth) / 2.0, y: (11.0 - strokeWidth) / 2.0, width: 11.0 / 2.0 - strokeWidth, height: strokeWidth))
    })
}

private func chatBubbleActionButtonImage(fillColor: UIColor, strokeColor: UIColor, foregroundColor: UIColor, image: UIImage?, iconOffset: CGPoint = CGPoint()) -> UIImage? {
    return generateImage(CGSize(width: 29.0, height: 29.0), rotatedContext: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        context.setFillColor(fillColor.cgColor)
        context.fillEllipse(in: CGRect(origin: CGPoint(), size: size))
        let lineWidth: CGFloat = 1.0
        let halfLineWidth = lineWidth / 2.0
        var strokeAlpha: CGFloat = 0.0
        strokeColor.getRed(nil, green: nil, blue: nil, alpha: &strokeAlpha)
        if !strokeAlpha.isZero {
            context.setStrokeColor(strokeColor.cgColor)
            context.setLineWidth(lineWidth)
            context.strokeEllipse(in: CGRect(origin: CGPoint(x: halfLineWidth, y: halfLineWidth), size: CGSize(width: size.width - lineWidth, height: size.width - lineWidth)))
        }
        
        if let image = image {
            let imageRect = CGRect(origin: CGPoint(x: floor((size.width - image.size.width) / 2.0) + iconOffset.x, y: floor((size.height - image.size.height) / 2.0) + iconOffset.y), size: image.size)
            
            context.translateBy(x: imageRect.midX, y: imageRect.midY)
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: -imageRect.midX, y: -imageRect.midY)
            context.clip(to: imageRect, mask: image.cgImage!)
            context.setFillColor(foregroundColor.cgColor)
            context.fill(imageRect)
        }
    })
}

public final class PrincipalThemeEssentialGraphics {
    public let chatMessageBackgroundIncomingImage: UIImage
    public let chatMessageBackgroundIncomingHighlightedImage: UIImage
    public let chatMessageBackgroundIncomingMergedTopImage: UIImage
    public let chatMessageBackgroundIncomingMergedTopHighlightedImage: UIImage
    public let chatMessageBackgroundIncomingMergedTopSideImage: UIImage
    public let chatMessageBackgroundIncomingMergedTopSideHighlightedImage: UIImage
    public let chatMessageBackgroundIncomingMergedBottomImage: UIImage
    public let chatMessageBackgroundIncomingMergedBottomHighlightedImage: UIImage
    public let chatMessageBackgroundIncomingMergedBothImage: UIImage
    public let chatMessageBackgroundIncomingMergedBothHighlightedImage: UIImage
    public let chatMessageBackgroundIncomingMergedSideImage: UIImage
    public let chatMessageBackgroundIncomingMergedSideHighlightedImage: UIImage
    
    public let chatMessageBackgroundOutgoingImage: UIImage
    public let chatMessageBackgroundOutgoingHighlightedImage: UIImage
    public let chatMessageBackgroundOutgoingMergedTopImage: UIImage
    public let chatMessageBackgroundOutgoingMergedTopHighlightedImage: UIImage
    public let chatMessageBackgroundOutgoingMergedTopSideImage: UIImage
    public let chatMessageBackgroundOutgoingMergedTopSideHighlightedImage: UIImage
    public let chatMessageBackgroundOutgoingMergedBottomImage: UIImage
    public let chatMessageBackgroundOutgoingMergedBottomHighlightedImage: UIImage
    public let chatMessageBackgroundOutgoingMergedBothImage: UIImage
    public let chatMessageBackgroundOutgoingMergedBothHighlightedImage: UIImage
    public let chatMessageBackgroundOutgoingMergedSideImage: UIImage
    public let chatMessageBackgroundOutgoingMergedSideHighlightedImage: UIImage
    
    public let checkBubbleFullImage: UIImage
    public let checkBubblePartialImage: UIImage
    
    public let checkMediaFullImage: UIImage
    public let checkMediaPartialImage: UIImage
    
    public let checkFreeFullImage: UIImage
    public let checkFreePartialImage: UIImage
    
    public let clockBubbleIncomingFrameImage: UIImage
    public let clockBubbleIncomingMinImage: UIImage
    public let clockBubbleOutgoingFrameImage: UIImage
    public let clockBubbleOutgoingMinImage: UIImage
    public let clockMediaFrameImage: UIImage
    public let clockMediaMinImage: UIImage
    public let clockFreeFrameImage: UIImage
    public let clockFreeMinImage: UIImage
    
    public let dateAndStatusMediaBackground: UIImage
    public let dateAndStatusFreeBackground: UIImage
    public let incomingDateAndStatusImpressionIcon: UIImage
    public let outgoingDateAndStatusImpressionIcon: UIImage
    public let mediaImpressionIcon: UIImage
    public let freeImpressionIcon: UIImage
    
    public let dateStaticBackground: UIImage
    public let dateFloatingBackground: UIImage
    
    public let radialIndicatorFileIconIncoming: UIImage
    public let radialIndicatorFileIconOutgoing: UIImage
    
    init(_ theme: PresentationThemeChat, wallpaper: TelegramWallpaper, preview: Bool = false) {
        let incoming: PresentationThemeBubbleColorComponents = wallpaper.isEmpty ? theme.message.incoming.bubble.withoutWallpaper : theme.message.incoming.bubble.withWallpaper
        let outgoing: PresentationThemeBubbleColorComponents = wallpaper.isEmpty ? theme.message.outgoing.bubble.withoutWallpaper : theme.message.outgoing.bubble.withWallpaper
        
        let emptyImage = UIImage()
        if preview {
            self.chatMessageBackgroundIncomingImage = messageBubbleImage(incoming: true, fillColor: incoming.fill, strokeColor: incoming.stroke, neighbors: .none)
            self.chatMessageBackgroundOutgoingImage = messageBubbleImage(incoming: false, fillColor: outgoing.fill, strokeColor: outgoing.stroke, neighbors: .none)
            self.checkBubbleFullImage = generateCheckImage(partial: false, color: theme.message.outgoingCheckColor)!
            self.checkBubblePartialImage = generateCheckImage(partial: true, color: theme.message.outgoingCheckColor)!
            self.chatMessageBackgroundIncomingHighlightedImage = emptyImage
            self.chatMessageBackgroundIncomingMergedTopImage = emptyImage
            self.chatMessageBackgroundIncomingMergedTopHighlightedImage = emptyImage
            self.chatMessageBackgroundIncomingMergedTopSideImage = emptyImage
            self.chatMessageBackgroundIncomingMergedTopSideHighlightedImage = emptyImage
            self.chatMessageBackgroundIncomingMergedBottomImage = emptyImage
            self.chatMessageBackgroundIncomingMergedBottomHighlightedImage = emptyImage
            self.chatMessageBackgroundIncomingMergedBothImage = emptyImage
            self.chatMessageBackgroundIncomingMergedBothHighlightedImage = emptyImage
            self.chatMessageBackgroundIncomingMergedSideImage = emptyImage
            self.chatMessageBackgroundIncomingMergedSideHighlightedImage = emptyImage
            self.chatMessageBackgroundOutgoingHighlightedImage = emptyImage
            self.chatMessageBackgroundOutgoingMergedTopImage = emptyImage
            self.chatMessageBackgroundOutgoingMergedTopHighlightedImage = emptyImage
            self.chatMessageBackgroundOutgoingMergedTopSideImage = emptyImage
            self.chatMessageBackgroundOutgoingMergedTopSideHighlightedImage = emptyImage
            self.chatMessageBackgroundOutgoingMergedBottomImage = emptyImage
            self.chatMessageBackgroundOutgoingMergedBottomHighlightedImage = emptyImage
            self.chatMessageBackgroundOutgoingMergedBothImage = emptyImage
            self.chatMessageBackgroundOutgoingMergedBothHighlightedImage = emptyImage
            self.chatMessageBackgroundOutgoingMergedSideImage = emptyImage
            self.chatMessageBackgroundOutgoingMergedSideHighlightedImage = emptyImage
            self.checkMediaFullImage = emptyImage
            self.checkMediaPartialImage = emptyImage
            self.checkFreeFullImage = emptyImage
            self.checkFreePartialImage = emptyImage
            self.clockBubbleIncomingFrameImage = emptyImage
            self.clockBubbleIncomingMinImage = emptyImage
            self.clockBubbleOutgoingFrameImage = emptyImage
            self.clockBubbleOutgoingMinImage = emptyImage
            self.clockMediaFrameImage = emptyImage
            self.clockMediaMinImage = emptyImage
            self.clockFreeFrameImage = emptyImage
            self.clockFreeMinImage = emptyImage
            self.dateAndStatusMediaBackground = emptyImage
            self.dateAndStatusFreeBackground = emptyImage
            self.incomingDateAndStatusImpressionIcon = emptyImage
            self.outgoingDateAndStatusImpressionIcon = emptyImage
            self.mediaImpressionIcon = emptyImage
            self.freeImpressionIcon = emptyImage
            self.dateStaticBackground = emptyImage
            self.dateFloatingBackground = emptyImage
            self.radialIndicatorFileIconIncoming = emptyImage
            self.radialIndicatorFileIconOutgoing = emptyImage
        } else {
            self.chatMessageBackgroundIncomingImage = messageBubbleImage(incoming: true, fillColor: incoming.fill, strokeColor: incoming.stroke, neighbors: .none)
            self.chatMessageBackgroundIncomingHighlightedImage = messageBubbleImage(incoming: true, fillColor: incoming.highlightedFill, strokeColor: incoming.stroke, neighbors: .none)
            self.chatMessageBackgroundIncomingMergedTopImage = messageBubbleImage(incoming: true, fillColor: incoming.fill, strokeColor: incoming.stroke, neighbors: .top(side: false))
            self.chatMessageBackgroundIncomingMergedTopHighlightedImage = messageBubbleImage(incoming: true, fillColor: incoming.highlightedFill, strokeColor: incoming.stroke, neighbors: .top(side: false))
            self.chatMessageBackgroundIncomingMergedTopSideImage = messageBubbleImage(incoming: true, fillColor: incoming.fill, strokeColor: incoming.stroke, neighbors: .top(side: true))
            self.chatMessageBackgroundIncomingMergedTopSideHighlightedImage = messageBubbleImage(incoming: true, fillColor: incoming.highlightedFill, strokeColor: incoming.stroke, neighbors: .top(side: true))
            self.chatMessageBackgroundIncomingMergedBottomImage = messageBubbleImage(incoming: true, fillColor: incoming.fill, strokeColor: incoming.stroke, neighbors: .bottom)
            self.chatMessageBackgroundIncomingMergedBottomHighlightedImage = messageBubbleImage(incoming: true, fillColor: incoming.highlightedFill, strokeColor: incoming.stroke, neighbors: .bottom)
            self.chatMessageBackgroundIncomingMergedBothImage = messageBubbleImage(incoming: true, fillColor: incoming.fill, strokeColor: incoming.stroke, neighbors: .both)
            self.chatMessageBackgroundIncomingMergedBothHighlightedImage = messageBubbleImage(incoming: true, fillColor: incoming.highlightedFill, strokeColor: incoming.stroke, neighbors: .both)
            
            self.chatMessageBackgroundOutgoingImage = messageBubbleImage(incoming: false, fillColor: outgoing.fill, strokeColor: outgoing.stroke, neighbors: .none)
            self.chatMessageBackgroundOutgoingHighlightedImage = messageBubbleImage(incoming: false, fillColor: outgoing.highlightedFill, strokeColor: outgoing.stroke, neighbors: .none)
            self.chatMessageBackgroundOutgoingMergedTopImage = messageBubbleImage(incoming: false, fillColor: outgoing.fill, strokeColor: outgoing.stroke, neighbors: .top(side: false))
            self.chatMessageBackgroundOutgoingMergedTopHighlightedImage = messageBubbleImage(incoming: false, fillColor: outgoing.highlightedFill, strokeColor: outgoing.stroke, neighbors: .top(side: false))
            self.chatMessageBackgroundOutgoingMergedTopSideImage = messageBubbleImage(incoming: false, fillColor: outgoing.fill, strokeColor: outgoing.stroke, neighbors: .top(side: true))
            self.chatMessageBackgroundOutgoingMergedTopSideHighlightedImage = messageBubbleImage(incoming: false, fillColor: outgoing.highlightedFill, strokeColor: outgoing.stroke, neighbors: .top(side: true))
            self.chatMessageBackgroundOutgoingMergedBottomImage = messageBubbleImage(incoming: false, fillColor: outgoing.fill, strokeColor: outgoing.stroke, neighbors: .bottom)
            self.chatMessageBackgroundOutgoingMergedBottomHighlightedImage = messageBubbleImage(incoming: false, fillColor: outgoing.highlightedFill, strokeColor: outgoing.stroke, neighbors: .bottom)
            self.chatMessageBackgroundOutgoingMergedBothImage = messageBubbleImage(incoming: false, fillColor: outgoing.fill, strokeColor: outgoing.stroke, neighbors: .both)
            self.chatMessageBackgroundOutgoingMergedBothHighlightedImage = messageBubbleImage(incoming: false, fillColor: outgoing.highlightedFill, strokeColor: outgoing.stroke, neighbors: .both)

            self.chatMessageBackgroundIncomingMergedSideImage = messageBubbleImage(incoming: true, fillColor: incoming.fill, strokeColor: incoming.stroke, neighbors: .side)
            self.chatMessageBackgroundOutgoingMergedSideImage = messageBubbleImage(incoming: false, fillColor: outgoing.fill, strokeColor: outgoing.stroke, neighbors: .side)
            self.chatMessageBackgroundIncomingMergedSideHighlightedImage = messageBubbleImage(incoming: true, fillColor: incoming.highlightedFill, strokeColor: incoming.stroke, neighbors: .side)
            self.chatMessageBackgroundOutgoingMergedSideHighlightedImage = messageBubbleImage(incoming: false, fillColor: outgoing.highlightedFill, strokeColor: outgoing.stroke, neighbors: .side)
            
            self.checkBubbleFullImage = generateCheckImage(partial: false, color: theme.message.outgoingCheckColor)!
            self.checkBubblePartialImage = generateCheckImage(partial: true, color: theme.message.outgoingCheckColor)!
            
            self.checkMediaFullImage = generateCheckImage(partial: false, color: .white)!
            self.checkMediaPartialImage = generateCheckImage(partial: true, color: .white)!
            
            let serviceColor = serviceMessageColorComponents(chatTheme: theme, wallpaper: wallpaper)
            self.checkFreeFullImage = generateCheckImage(partial: false, color: serviceColor.primaryText)!
            self.checkFreePartialImage = generateCheckImage(partial: true, color: serviceColor.primaryText)!
            
            self.clockBubbleIncomingFrameImage = generateClockFrameImage(color: theme.message.incoming.pendingActivityColor)!
            self.clockBubbleIncomingMinImage = generateClockMinImage(color: theme.message.incoming.pendingActivityColor)!
            self.clockBubbleOutgoingFrameImage = generateClockFrameImage(color: theme.message.outgoing.pendingActivityColor)!
            self.clockBubbleOutgoingMinImage = generateClockMinImage(color: theme.message.outgoing.pendingActivityColor)!
            
            self.clockMediaFrameImage = generateClockFrameImage(color: .white)!
            self.clockMediaMinImage = generateClockMinImage(color: .white)!
            
            self.clockFreeFrameImage = generateClockFrameImage(color: serviceColor.primaryText)!
            self.clockFreeMinImage = generateClockMinImage(color: serviceColor.primaryText)!
            
            self.dateAndStatusMediaBackground = generateStretchableFilledCircleImage(diameter: 18.0, color: theme.message.mediaDateAndStatusFillColor)!
            self.dateAndStatusFreeBackground = generateStretchableFilledCircleImage(diameter: 18.0, color: serviceColor.dateFillStatic)!
            
            let impressionCountImage = UIImage(bundleImageName: "Chat/Message/ImpressionCount")!
            self.incomingDateAndStatusImpressionIcon = generateTintedImage(image: impressionCountImage, color: theme.message.incoming.secondaryTextColor)!
            self.outgoingDateAndStatusImpressionIcon = generateTintedImage(image: impressionCountImage, color: theme.message.outgoing.secondaryTextColor)!
            self.mediaImpressionIcon = generateTintedImage(image: impressionCountImage, color: .white)!
            self.freeImpressionIcon = generateTintedImage(image: impressionCountImage, color: serviceColor.primaryText)!
            
            let chatDateSize: CGFloat = 20.0
            self.dateStaticBackground = generateImage(CGSize(width: chatDateSize, height: chatDateSize), contextGenerator: { size, context -> Void in
                context.clear(CGRect(origin: CGPoint(), size: size))
                context.setFillColor(serviceColor.dateFillStatic.cgColor)
                context.fillEllipse(in: CGRect(origin: CGPoint(), size: size))
            })!.stretchableImage(withLeftCapWidth: Int(chatDateSize) / 2, topCapHeight: Int(chatDateSize) / 2)
            
            self.dateFloatingBackground = generateImage(CGSize(width: chatDateSize, height: chatDateSize), contextGenerator: { size, context -> Void in
                context.clear(CGRect(origin: CGPoint(), size: size))
                context.setFillColor(serviceColor.dateFillFloating.cgColor)
                context.fillEllipse(in: CGRect(origin: CGPoint(), size: size))
            })!.stretchableImage(withLeftCapWidth: Int(chatDateSize) / 2, topCapHeight: Int(chatDateSize) / 2)
            
            self.radialIndicatorFileIconIncoming = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/RadialProgressIconDocumentIncoming"), color: incoming.fill)!
            self.radialIndicatorFileIconOutgoing = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/RadialProgressIconDocumentIncoming"), color: outgoing.fill)!
        }
    }
}

public final class PrincipalThemeAdditionalGraphics {
    public let chatServiceBubbleFillImage: UIImage
    public let chatServiceVerticalLineImage: UIImage
    public let chatFreeformContentAdditionalInfoBackgroundImage: UIImage
    public let chatEmptyItemBackgroundImage: UIImage
    public let chatLoadingIndicatorBackgroundImage: UIImage
    
    public let chatBubbleShareButtonImage: UIImage
    public let chatBubbleNavigateButtonImage: UIImage
    public let chatBubbleActionButtonIncomingMiddleImage: UIImage
    public let chatBubbleActionButtonIncomingBottomLeftImage: UIImage
    public let chatBubbleActionButtonIncomingBottomRightImage: UIImage
    public let chatBubbleActionButtonIncomingBottomSingleImage: UIImage
    public let chatBubbleActionButtonOutgoingMiddleImage: UIImage
    public let chatBubbleActionButtonOutgoingBottomLeftImage: UIImage
    public let chatBubbleActionButtonOutgoingBottomRightImage: UIImage
    public let chatBubbleActionButtonOutgoingBottomSingleImage: UIImage
    
    public let chatBubbleActionButtonIncomingMessageIconImage: UIImage
    public let chatBubbleActionButtonIncomingLinkIconImage: UIImage
    public let chatBubbleActionButtonIncomingShareIconImage: UIImage
    public let chatBubbleActionButtonIncomingPhoneIconImage: UIImage
    public let chatBubbleActionButtonIncomingLocationIconImage: UIImage
    
    public let chatBubbleActionButtonOutgoingMessageIconImage: UIImage
    public let chatBubbleActionButtonOutgoingLinkIconImage: UIImage
    public let chatBubbleActionButtonOutgoingShareIconImage: UIImage
    public let chatBubbleActionButtonOutgoingPhoneIconImage: UIImage
    public let chatBubbleActionButtonOutgoingLocationIconImage: UIImage
    
    public let chatEmptyItemLockIcon: UIImage
    public let emptyChatListCheckIcon: UIImage
    
    init(_ theme: PresentationThemeChat, wallpaper: TelegramWallpaper) {
        let serviceColor = serviceMessageColorComponents(chatTheme: theme, wallpaper: wallpaper)
        self.chatServiceBubbleFillImage = generateImage(CGSize(width: 20.0, height: 20.0), contextGenerator: { size, context -> Void in
            context.clear(CGRect(origin: CGPoint(), size: size))
            context.setFillColor(serviceColor.fill.cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(), size: size))
        })!.stretchableImage(withLeftCapWidth: 8, topCapHeight: 8)
        
        self.chatServiceVerticalLineImage = generateImage(CGSize(width: 2.0, height: 3.0), contextGenerator: { size, context in
            context.clear(CGRect(origin: CGPoint(), size: size))
            context.setFillColor(serviceColor.primaryText.cgColor)
            context.fillEllipse(in: CGRect(origin: CGPoint(), size: CGSize(width: 2.0, height: 2.0)))
            context.fillEllipse(in: CGRect(origin: CGPoint(x: 0.0, y: 1.0), size: CGSize(width: 2.0, height: 2.0)))
        })!.stretchableImage(withLeftCapWidth: 0, topCapHeight: 1)
        
        self.chatFreeformContentAdditionalInfoBackgroundImage = generateStretchableFilledCircleImage(radius: 10.0, color: serviceColor.fill)!
        self.chatEmptyItemBackgroundImage = generateStretchableFilledCircleImage(radius: 14.0, color: serviceColor.fill)!
        self.chatLoadingIndicatorBackgroundImage = generateStretchableFilledCircleImage(diameter: 30.0, color: serviceColor.fill)!
        
        self.chatBubbleShareButtonImage = chatBubbleActionButtonImage(fillColor: bubbleVariableColor(variableColor: theme.message.shareButtonFillColor, wallpaper: wallpaper), strokeColor: bubbleVariableColor(variableColor: theme.message.shareButtonStrokeColor, wallpaper: wallpaper), foregroundColor: bubbleVariableColor(variableColor: theme.message.shareButtonForegroundColor, wallpaper: wallpaper), image: UIImage(bundleImageName: "Chat/Message/ShareIcon"))!
        self.chatBubbleNavigateButtonImage = chatBubbleActionButtonImage(fillColor: bubbleVariableColor(variableColor: theme.message.shareButtonFillColor, wallpaper: wallpaper), strokeColor: bubbleVariableColor(variableColor: theme.message.shareButtonStrokeColor, wallpaper: wallpaper), foregroundColor: bubbleVariableColor(variableColor: theme.message.shareButtonForegroundColor, wallpaper: wallpaper), image: UIImage(bundleImageName: "Chat/Message/NavigateToMessageIcon"), iconOffset: CGPoint(x: 0.0, y: 1.0))!
        self.chatBubbleActionButtonIncomingMiddleImage = messageBubbleActionButtonImage(color: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsFillColor, wallpaper: wallpaper), strokeColor: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsStrokeColor, wallpaper: wallpaper), position: .middle)
        self.chatBubbleActionButtonIncomingBottomLeftImage = messageBubbleActionButtonImage(color: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsFillColor, wallpaper: wallpaper), strokeColor: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsStrokeColor, wallpaper: wallpaper), position: .bottomLeft)
        self.chatBubbleActionButtonIncomingBottomRightImage = messageBubbleActionButtonImage(color: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsFillColor, wallpaper: wallpaper), strokeColor: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsStrokeColor, wallpaper: wallpaper), position: .bottomRight)
        self.chatBubbleActionButtonIncomingBottomSingleImage = messageBubbleActionButtonImage(color: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsFillColor, wallpaper: wallpaper), strokeColor: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsStrokeColor, wallpaper: wallpaper), position: .bottomSingle)
        self.chatBubbleActionButtonOutgoingMiddleImage = messageBubbleActionButtonImage(color: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsFillColor, wallpaper: wallpaper), strokeColor: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsStrokeColor, wallpaper: wallpaper), position: .middle)
        self.chatBubbleActionButtonOutgoingBottomLeftImage = messageBubbleActionButtonImage(color: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsFillColor, wallpaper: wallpaper), strokeColor: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsStrokeColor, wallpaper: wallpaper), position: .bottomLeft)
        self.chatBubbleActionButtonOutgoingBottomRightImage = messageBubbleActionButtonImage(color: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsFillColor, wallpaper: wallpaper), strokeColor: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsStrokeColor, wallpaper: wallpaper), position: .bottomRight)
        self.chatBubbleActionButtonOutgoingBottomSingleImage = messageBubbleActionButtonImage(color: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsFillColor, wallpaper: wallpaper), strokeColor: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsStrokeColor, wallpaper: wallpaper), position: .bottomSingle)
        self.chatBubbleActionButtonIncomingMessageIconImage = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/BotMessage"), color: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsTextColor, wallpaper: wallpaper))!
        self.chatBubbleActionButtonIncomingLinkIconImage = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/BotLink"), color: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsTextColor, wallpaper: wallpaper))!
        self.chatBubbleActionButtonIncomingShareIconImage = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/BotShare"), color: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsTextColor, wallpaper: wallpaper))!
        self.chatBubbleActionButtonIncomingPhoneIconImage = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/BotPhone"), color: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsTextColor, wallpaper: wallpaper))!
        self.chatBubbleActionButtonIncomingLocationIconImage = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/BotLocation"), color: bubbleVariableColor(variableColor: theme.message.incoming.actionButtonsTextColor, wallpaper: wallpaper))!
        self.chatBubbleActionButtonOutgoingMessageIconImage = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/BotMessage"), color: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsTextColor, wallpaper: wallpaper))!
        self.chatBubbleActionButtonOutgoingLinkIconImage = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/BotLink"), color: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsTextColor, wallpaper: wallpaper))!
        self.chatBubbleActionButtonOutgoingShareIconImage = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/BotShare"), color: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsTextColor, wallpaper: wallpaper))!
        self.chatBubbleActionButtonOutgoingPhoneIconImage = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/BotPhone"), color: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsTextColor, wallpaper: wallpaper))!
        self.chatBubbleActionButtonOutgoingLocationIconImage = generateTintedImage(image: UIImage(bundleImageName: "Chat/Message/BotLocation"), color: bubbleVariableColor(variableColor: theme.message.outgoing.actionButtonsTextColor, wallpaper: wallpaper))!
        
        self.chatEmptyItemLockIcon = generateImage(CGSize(width: 9.0, height: 13.0), rotatedContext: { size, context in
            context.clear(CGRect(origin: CGPoint(), size: size))
            
            context.translateBy(x: 0.0, y: 1.0)
            
            context.setFillColor(serviceColor.primaryText.cgColor)
            context.setStrokeColor(serviceColor.primaryText.cgColor)
            context.setLineWidth(1.32)
            
            let _ = try? drawSvgPath(context, path: "M4.5,0.600000024 C5.88071187,0.600000024 7,1.88484952 7,3.46979169 L7,7.39687502 C7,8.9818172 5.88071187,10.2666667 4.5,10.2666667 C3.11928813,10.2666667 2,8.9818172 2,7.39687502 L2,3.46979169 C2,1.88484952 3.11928813,0.600000024 4.5,0.600000024 S ")
            let _ = try? drawSvgPath(context, path: "M1.32,5.65999985 L7.68,5.65999985 C8.40901587,5.65999985 9,6.25098398 9,6.97999985 L9,10.6733332 C9,11.4023491 8.40901587,11.9933332 7.68,11.9933332 L1.32,11.9933332 C0.59098413,11.9933332 1.11022302e-16,11.4023491 0,10.6733332 L2.22044605e-16,6.97999985 C1.11022302e-16,6.25098398 0.59098413,5.65999985 1.32,5.65999985 Z ")
        })!
        self.emptyChatListCheckIcon = generateTintedImage(image: UIImage(bundleImageName: "Chat/Empty Chat/ListCheckIcon"), color: serviceColor.primaryText)!
    }
}
