//
//  UIStepper+CustomStepperProtocol.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/18/24.
//

import UIKit

extension UIStepper: CustomStepperProtocol {
    // CustomStepperProtocol methods
    public func increment() {
        self.value += self.stepValue
        if self.value > self.maximumValue {
            self.value = self.wraps ? self.minimumValue : self.maximumValue
        }
    }

    public func decrement() {
        self.value -= self.stepValue
        if self.value < self.minimumValue {
            self.value = self.wraps ? self.maximumValue : self.minimumValue
        }
    }

    public func setValue(_ newValue: Double) {
        if newValue < self.minimumValue {
            self.value = self.wraps ? self.maximumValue : self.minimumValue
        } else if newValue > self.maximumValue {
            self.value = self.wraps ? self.minimumValue : self.maximumValue
        } else {
            self.value = newValue
        }
    }

    public func reset() {
        self.value = self.minimumValue
    }
}
