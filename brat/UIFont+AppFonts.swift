//
//  UIFont+AppFonts.swift
//  RestaurantReminder
//
//  Created by Nathan Fennel on 5/11/24.
//

import UIKit

extension UIFont {
    // Define a custom header font, typically larger for visibility.
    static var appHeaderFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .largeTitle)
    }
    
    // Define a custom title font.
    static var appTitleFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .title1)
    }
    
    // Define a custom subtitle font, usually slightly smaller than the title.
    static var appSubtitleFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .title3)
    }
    
    // Define a custom body font, used for primary content.
    static var appBodyFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .body)
    }
    
    // Define a custom detail font, typically smaller and perhaps for metadata.
    static var appDetailFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .caption1)
    }
    
    // Define a custom button font, which should be clear and readable.
    static var appButtonFont: UIFont {
        return UIFont.preferredFont(forTextStyle: .callout)
    }
}
