//
//  RulerZoomWrapper.swift
//  Slide Rule
//
//  Created by Rowan on 11/24/24.
//

import SwiftUI

struct RulerZoomWrapper <Content: View>: View {
    @Binding var posData: PosData
    let content: Content
    
    let maxZoom = 3.0
    let minZoom = 0.5
    
    @EnvironmentObject var settings: SettingsManager
    
    @State var internalZoomLevel: CGFloat = 1.0
    @State var lastRawZoomValue: CGFloat = 1.0
    @State var lastZoomValue: CGFloat = 1.0
    @State var zoomAnchor: CGPoint = .zero
    @State var isZooming: Bool = false
    @State var isZoomed: Bool = false
    @State var isDraggingUp: Bool = false
    @State var lastZoomAnchor: CGPoint = .zero
    
    @State var startX: CGFloat = 0
    @State var startY: CGFloat = 0
    
    @State var sensoryTrigger: Bool = false
    
    
    
    init(posData: Binding<PosData>, @ViewBuilder content: ()->Content){
        self._posData = posData
        self.content = content()
    }
    
    var body: some View {
        content
            .sensoryFeedback(.impact, trigger: isZoomed)
            .offset(x:-zoomAnchor.x, y:-zoomAnchor.y)
            .scaleEffect(posData.zoomLevel, anchor: .top)
            .offset(x:zoomAnchor.x, y:zoomAnchor.y)
            .defersSystemGestures(on: .all)
            .simultaneousGesture(rulerMagnificationGesture)
            .simultaneousGesture(rulerMagTapGesture)
            .simultaneousGesture(rulerVerticalMoveGesture)
            .offset(y:-(zoomAnchor.y-202/2)*(posData.zoomLevel-1)/3)
            .onChange(of:posData.zoomLevel){
                updateMovementSpeed()
            }
            .onChange(of: settings.slowZoom){
                updateMovementSpeed()
            }
            .sensoryFeedback(.impact, trigger:sensoryTrigger)
            .onChange(of:zoomAnchor){
                posData.zoomAnchor = zoomAnchor
            }
    }
    
    func updateMovementSpeed() -> Void{
        if settings.slowZoom {
            let factor = (posData.zoomLevel-1)*1/2 + 1
            posData.movementSpeed = 1.0/factor
        }else{
            posData.movementSpeed = 1.0
        }
    }
}


extension RulerZoomWrapper{
    private var rulerMagTapGesture: some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded{value in
                let val = 2.0
                
                let shouldZoomIn = posData.zoomLevel <= 1.1
                
                var newScale = shouldZoomIn ? val : 1.0
                
                newScale = min(3,max(1,newScale))
                
                let start = value.location
                
                withAnimation(.smooth){
                    let y = start.y
                    zoomAnchor = CGPoint(x:0, y:y)
                    
                    
                    let dz = newScale/posData.zoomLevel
                    let x = (start.x-1600/2)/posData.zoomLevel*(1-dz)
                    posData.framePos = posData.framePos0 + x
                    posData.framePos0 = posData.framePos
                    
                    
                    posData.zoomLevel = newScale
                }
            }
    }
    
    private var rulerMagnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                posData.isLocked = true
                
                let val = value.magnification
                let delta = val / self.lastRawZoomValue
                
                var newScale = internalZoomLevel * delta
                
                newScale = min(maxZoom, max(minZoom, newScale))
                
                
                internalZoomLevel = newScale
                
                if internalZoomLevel > 0.9 && internalZoomLevel < 1.1 {
                    posData.zoomLevel = 1.0
                    isZoomed = false
                }else{
                    posData.zoomLevel = internalZoomLevel
                    isZoomed = true
                }
                
                let dz = posData.zoomLevel/lastZoomValue
                
                
                
                let start = value.startLocation
                if(!isZooming){
                    startX = start.x
                    startY = start.y
                }
                
                let y = (startY-zoomAnchor.y)/max(1, posData.zoomLevel)+zoomAnchor.y
                zoomAnchor = CGPoint(x:0, y:y)
                
                
                let x = (startX-1600/2)/posData.zoomLevel*(1-dz)
                posData.framePos = posData.framePos0 + x
                posData.framePos0 = posData.framePos
                
                
                isZooming = true
                lastRawZoomValue = val
                lastZoomValue = posData.zoomLevel
                posData.canDragToFlip = posData.zoomLevel <= 1.25
                
                
            }.onEnded { value in
                isZooming = false
                posData.isLocked = false
                self.lastRawZoomValue = 1.0
                
                posData.framePos0 = posData.framePos
                
                if internalZoomLevel != posData.zoomLevel && posData.zoomLevel == 1{
                    internalZoomLevel = 1
                }
            }
        
    }
    
    private var rulerVerticalMoveGesture: some Gesture{
        DragGesture(minimumDistance: 5)
            .onChanged({value in
                if(posData.canDragToFlip || posData.isDragging){return}
                if isDraggingUp || abs(value.translation.height) >= 2*abs(value.translation.width) {
                    isDraggingUp = true
                    posData.isLocked = true
                    
                    let yprime = lastZoomAnchor.y - value.translation.height*posData.movementSpeed/2
                    zoomAnchor = CGPoint(x:zoomAnchor.x, y: yprime)
                }
            })
            .onEnded({value in
                isDraggingUp = false
                posData.isLocked = false
                lastZoomAnchor = zoomAnchor
            })
    }
}
