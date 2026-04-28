//
//  CustomStepperProtocol.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/18/24.
//

import UIKit

protocol CustomStepperProtocol: UIControl {
    // Properties to represent the current value, minimum value, maximum value, and step value.
    var value: Double { get set }
    var minimumValue: Double { get set }
    var maximumValue: Double { get set }
    var stepValue: Double { get set }
    
    // Property to determine if the stepper should repeat the increment/decrement actions while the user holds the button.
    var isContinuous: Bool { get set }
    
    // Property to determine if the stepper wraps the value when it reaches the minimum or maximum.
    var wraps: Bool { get set }
    
    // Property to determine if the stepper should autorepeat.
    var autorepeat: Bool { get set }
    
    // Method to increment the value.
    func increment()
    
    // Method to decrement the value.
    func decrement()
    
    // Method to set the value programmatically, ensuring it respects the minimum and maximum limits.
    func setValue(_ newValue: Double)
    
    // Method to reset the stepper to its initial value.
    func reset()
}

extension CustomStepperProtocol {
    // Default implementation for setting the value, ensuring it respects the limits.
    func setValue(_ newValue: Double) {
        if newValue < minimumValue {
            value = wraps ? maximumValue : minimumValue
        } else if newValue > maximumValue {
            value = wraps ? minimumValue : maximumValue
        } else {
            value = newValue
        }
    }
    
    // Default implementation for resetting the stepper.
    func reset() {
        value = minimumValue
    }
}
