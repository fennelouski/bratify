import Foundation

extension Date {
    static let spelledOutDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    func spelledOutTimeLowercase() -> String? {
        let spelledOutDateFormatter = Date.spelledOutDateFormatter
        
        let timeString = spelledOutDateFormatter.string(from: self)
        
        let zeroes = [
            NSLocalizedString("zero", comment: "Word for the digit 0"),
            NSLocalizedString("ø", comment: "Alternative symbol for the digit 0"),
            NSLocalizedString("zerØ", comment: "Stylized version of the word zero")
        ]

        let ams = [
            NSLocalizedString("am", comment: "Abbreviation for ante meridiem (before noon)"),
            NSLocalizedString("am", comment: "Duplicate for variation"),
            NSLocalizedString("am", comment: "Duplicate for variation"),
            NSLocalizedString("am", comment: "Duplicate for variation"),
            NSLocalizedString("a", comment: "Short form for am"),
            NSLocalizedString("a.m", comment: "Abbreviation for ante meridiem with period"),
            NSLocalizedString("a.m.", comment: "Abbreviation for ante meridiem with full stop")
        ]

        let pms = [
            NSLocalizedString("pm", comment: "Abbreviation for post meridiem (after noon)"),
            NSLocalizedString("pm", comment: "Duplicate for variation"),
            NSLocalizedString("pm", comment: "Duplicate for variation"),
            NSLocalizedString("pm", comment: "Duplicate for variation"),
            NSLocalizedString("p", comment: "Short form for pm"),
            NSLocalizedString("p.m", comment: "Abbreviation for post meridiem with period"),
            NSLocalizedString("p.m.", comment: "Abbreviation for post meridiem with full stop"),
            NSLocalizedString("p.", comment: "Shortened form for post meridiem"),
            NSLocalizedString("P", comment: "Capitalized version of post meridiem abbreviation")
        ]

        // Dictionary to map each character to its spelled-out lowercase form
        let numberWords: [Character: String] = [
            "0": zeroes.randomElement() ?? NSLocalizedString("zero", comment: "Fallback word for digit 0"),
            "1": NSLocalizedString("one", comment: "Word for the digit 1"),
            "2": NSLocalizedString("two", comment: "Word for the digit 2"),
            "3": NSLocalizedString("three", comment: "Word for the digit 3"),
            "4": NSLocalizedString("four", comment: "Word for the digit 4"),
            "5": NSLocalizedString("five", comment: "Word for the digit 5"),
            "6": NSLocalizedString("six", comment: "Word for the digit 6"),
            "7": NSLocalizedString("seven", comment: "Word for the digit 7"),
            "8": NSLocalizedString("eight", comment: "Word for the digit 8"),
            "9": NSLocalizedString("nine", comment: "Word for the digit 9"),
            ":": NSLocalizedString(":", comment: "Colon symbol"),
            " ": NSLocalizedString("space", comment: "The word for a space character"),
            "a": NSLocalizedString("a.m.", comment: "Abbreviation for ante meridiem"),
            "p": NSLocalizedString("p.m.", comment: "Abbreviation for post meridiem"),
            "A": ams.randomElement() ?? NSLocalizedString("a.m.", comment: "Fallback for ante meridiem"),
            "P": pms.randomElement() ?? NSLocalizedString("p.m.", comment: "Fallback for post meridiem"),
            "M": NSLocalizedString("", comment: "Empty string for the character M"),
            "m": NSLocalizedString("", comment: "Empty string for the character m")
        ]
        
        // Function to spell out each character
        func spellOutCharacter(_ char: Character) -> String {
            return numberWords[char, default: String(char).lowercased()]
        }
        
        // Spell out each character in the time string
        let spelledOutTime = timeString.map { spellOutCharacter($0) }.joined(separator: " ")
        
        return spelledOutTime
    }
}
