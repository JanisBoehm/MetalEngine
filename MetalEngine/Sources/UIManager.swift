//
//  UIManager.swift
//  Metal2DRasterTest
//
//  Created by Janis Böhm on 09.11.18.
//  Copyright © 2018 Company At The End Of The Universe. All rights reserved.
//

import Foundation
import Carbon
import Cocoa
import simd

class UIManager: NSResponder {
    
    var keyboard: KeyboardState!
    
    override init() {
        keyboard = KeyboardState()
        super.init()
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown, handler: {event -> NSEvent in
            self.keyDown(with: event)
            return NSEvent.init()})
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyUp, handler: {event -> NSEvent in
            self.keyUp(with: event)
            return NSEvent.init()})
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_ANSI_A:
            keyboard.keyStateA = .down
        case kVK_ANSI_B:
            keyboard.keyStateB = .down
        case kVK_ANSI_C:
            keyboard.keyStateC = .down
        case kVK_ANSI_D:
            keyboard.keyStateD = .down
        case kVK_ANSI_E:
            keyboard.keyStateE = .down
        case kVK_ANSI_F:
            keyboard.keyStateF = .down
        case kVK_ANSI_G:
            keyboard.keyStateG = .down
        case kVK_ANSI_H:
            keyboard.keyStateH = .down
        case kVK_ANSI_I:
            keyboard.keyStateI = .down
        case kVK_ANSI_J:
            keyboard.keyStateJ = .down
        case kVK_ANSI_K:
            keyboard.keyStateK = .down
        case kVK_ANSI_L:
            keyboard.keyStateL = .down
        case kVK_ANSI_M:
            keyboard.keyStateM = .down
        case kVK_ANSI_N:
            keyboard.keyStateN = .down
        case kVK_ANSI_O:
            keyboard.keyStateO = .down
        case kVK_ANSI_P:
            keyboard.keyStateP = .down
        case kVK_ANSI_Q:
            keyboard.keyStateQ = .down
        case kVK_ANSI_R:
            keyboard.keyStateR = .down
        case kVK_ANSI_S:
            keyboard.keyStateS = .down
        case kVK_ANSI_T:
            keyboard.keyStateT = .down
        case kVK_ANSI_U:
            keyboard.keyStateU = .down
        case kVK_ANSI_V:
            keyboard.keyStateV = .down
        case kVK_ANSI_W:
            keyboard.keyStateW = .down
        case kVK_ANSI_X:
            keyboard.keyStateX = .down
        case kVK_ANSI_Y:
            keyboard.keyStateY = .down
        case kVK_ANSI_Z:
            keyboard.keyStateZ = .down
            
        case kVK_ANSI_0:
            keyboard.keyState0 = .down
        case kVK_ANSI_1:
            keyboard.keyState1 = .down
        case kVK_ANSI_2:
            keyboard.keyState2 = .down
        case kVK_ANSI_3:
            keyboard.keyState3 = .down
        case kVK_ANSI_4:
            keyboard.keyState4 = .down
        case kVK_ANSI_5:
            keyboard.keyState5 = .down
        case kVK_ANSI_6:
            keyboard.keyState6 = .down
        case kVK_ANSI_7:
            keyboard.keyState7 = .down
        case kVK_ANSI_8:
            keyboard.keyState8 = .down
        case kVK_ANSI_9:
            keyboard.keyState9 = .down
        default:
            return
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_ANSI_A:
            keyboard.keyStateA = .up
        case kVK_ANSI_B:
            keyboard.keyStateB = .up
        case kVK_ANSI_C:
            keyboard.keyStateC = .up
        case kVK_ANSI_D:
            keyboard.keyStateD = .up
        case kVK_ANSI_E:
            keyboard.keyStateE = .up
        case kVK_ANSI_F:
            keyboard.keyStateF = .up
        case kVK_ANSI_G:
            keyboard.keyStateG = .up
        case kVK_ANSI_H:
            keyboard.keyStateH = .up
        case kVK_ANSI_I:
            keyboard.keyStateI = .up
        case kVK_ANSI_J:
            keyboard.keyStateJ = .up
        case kVK_ANSI_K:
            keyboard.keyStateK = .up
        case kVK_ANSI_L:
            keyboard.keyStateL = .up
        case kVK_ANSI_M:
            keyboard.keyStateM = .up
        case kVK_ANSI_N:
            keyboard.keyStateN = .up
        case kVK_ANSI_O:
            keyboard.keyStateO = .up
        case kVK_ANSI_P:
            keyboard.keyStateP = .up
        case kVK_ANSI_Q:
            keyboard.keyStateQ = .up
        case kVK_ANSI_R:
            keyboard.keyStateR = .up
        case kVK_ANSI_S:
            keyboard.keyStateS = .up
        case kVK_ANSI_T:
            keyboard.keyStateT = .up
        case kVK_ANSI_U:
            keyboard.keyStateU = .up
        case kVK_ANSI_V:
            keyboard.keyStateV = .up
        case kVK_ANSI_W:
            keyboard.keyStateW = .up
        case kVK_ANSI_X:
            keyboard.keyStateX = .up
        case kVK_ANSI_Y:
            keyboard.keyStateY = .up
        case kVK_ANSI_Z:
            keyboard.keyStateZ = .up
            
        case kVK_ANSI_0:
            keyboard.keyState0 = .up
        case kVK_ANSI_1:
            keyboard.keyState1 = .up
        case kVK_ANSI_2:
            keyboard.keyState2 = .up
        case kVK_ANSI_3:
            keyboard.keyState3 = .up
        case kVK_ANSI_4:
            keyboard.keyState4 = .up
        case kVK_ANSI_5:
            keyboard.keyState5 = .up
        case kVK_ANSI_6:
            keyboard.keyState6 = .up
        case kVK_ANSI_7:
            keyboard.keyState7 = .up
        case kVK_ANSI_8:
            keyboard.keyState8 = .up
        case kVK_ANSI_9:
            keyboard.keyState9 = .up
        default:
            return
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    
    
}
