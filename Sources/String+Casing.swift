import Foundation

public extension String {
    /// Returns a sentance cased version of the string.
    ///
    /// This is a mixed-case style in which the first word of the sentence is capitalized.
    /// The following example transforms a string to sentence-cased letters:
    /// ```
    /// let value = "The Fox Eats The Chicken."
    /// print(value.sentenceCased())
    /// // Prints "The fox eats the chicken."
    /// ```
    ///
    /// - parameter fragmentHandler: Allows caller to override fragment lower-casing (index > 0)
    /// - returns: A sentence-cased copy of the string.
    func sentenceCased(with locale: Locale? = nil, fragmentHandler: ((_ fragment: String) -> Bool)? = nil) -> String {
        return mixedCase(capitalizeFragments: false, locale: locale, fragmentHandler: fragmentHandler)
    }
    
    /// Returns a title cased version of the string.
    ///
    /// This is a mixed-case style with all words capitalized (except some articles, prepositions, and conjunctions)
    /// The following example transforms a string to sentence-cased letters:
    /// ```
    /// let value = "The fox eats the chicken."
    /// print(value.titleCased())
    /// // Prints "The Fox Eats The Chicken."
    /// ```
    ///
    /// - parameter fragmentHandler: Allows caller to override fragment capitalization (index > 0)
    /// - returns: A title-cased copy of the string.
    func titleCased(with locale: Locale? = nil, fragmentHandler: ((_ fragment: String) -> Bool)? = nil) -> String {
        return mixedCase(capitalizeFragments: true, locale: locale, fragmentHandler: fragmentHandler)
    }
    
    /// Returns a camel cased version of the string.
    ///
    /// Punctuation & spaces are removed and the first character of each word is capitalized.
    /// The following example transforms a string to sentence-cased letters:
    /// ```
    /// let value = "The fox eats the chicken."
    /// print(value.upperCamelCased())
    /// // Prints "TheFoxEatsTheChicken"
    /// ```
    ///
    /// - returns: A camel-cased copy of the string.
    func upperCamelCased(with locale: Locale? = nil) -> String {
        return camel(upperFirst: true, locale: locale)
    }
    
    /// Returns a camel cased version of the string.
    ///
    /// Punctuation & spaces are removed and the first character of each word is capitalized (except the first).
    /// The following example transforms a string to sentence-cased letters:
    /// ```
    /// let value = "The fox eats the chicken."
    /// print(value.lowerCamelCased())
    /// // Prints "theFoxEatsTheChicken"
    /// ```
    ///
    /// - returns: A camel-cased copy of the string.
    func lowerCamelCased(with locale: Locale? = nil) -> String {
        return camel(upperFirst: false, locale: locale)
    }
    
    /// Returns a snake cased version of the string.
    ///
    /// Punctuation & spaces are removed and replaced by underscores.
    /// The following example transforms a string to sentence-cased letters:
    /// ```
    /// let value = "The fox eats the chicken."
    /// print(value.snakeCased())
    /// // Prints "The_fox_eats_the_chicken"
    /// ```
    ///
    /// - returns: A snake-cased copy of the string.
    func snakeCased(with locale: Locale? = nil) -> String {
        return alphanumericsSeparated(separator: "_", locale: locale)
    }
    
    /// Returns a snake cased version of the string.
    ///
    /// Punctuation & spaces are removed and replaced by hyphens.
    /// The following example transforms a string to sentence-cased letters:
    /// ```
    /// let value = "The fox eats the chicken."
    /// print(value.snakeCased())
    /// // Prints "The-fox-eats-the-chicken"
    /// ```
    ///
    /// - returns: A kebab-cased copy of the string.
    func kebabCased(with locale: Locale? = nil) -> String {
        return alphanumericsSeparated(separator: "-", locale: locale)
    }
}

private extension String {
    /// Produce a mixed-case string (sentance, title)
    /// - parameter capitalizedFragments: Force all fragments to be capitalized.
    /// - parameter fragmentHandler: A function block to execute with all fragments (index > 0) to dertermine capitalization.
    func mixedCase(capitalizeFragments: Bool, locale: Locale? = nil, fragmentHandler: ((_ fragment: String) -> Bool)? = nil) -> String {
        let fragments = self.splitBefore { (character) -> Bool in
            return (character.isPunctuation || character.isWhitespace || character.isNewline)
        }
        
        let outputFragments: [String]
        
        switch capitalizeFragments {
        case true:
            var collection: [String] = []
            
            for (index, fragment) in fragments.enumerated() {
                let string = String(fragment).lowercased(with: locale)
                
                if index > 0 {
                    if let handler = fragmentHandler, !handler(string) {
                        collection.append(string)
                        continue
                    }
                }
                
                collection.append(string.capitalized(with: locale))
            }
            
            outputFragments = collection
        case false:
            var collection: [String] = []
            
            for (index, fragment) in fragments.enumerated() {
                let string = String(fragment).lowercased(with: locale)
                
                if index > 0 {
                    if let handler = fragmentHandler, handler(string) {
                        // capitalize
                    } else {
                        collection.append(string)
                        continue
                    }
                }
                
                collection.append(string.capitalized(with: locale))
            }
            
            outputFragments = collection
        }
        
        return outputFragments.joined()
    }
    
    /// Produces a camel-cased string containg only alphanumeric characters.
    /// - parameter upperFirst: Controls wether the first character in the resulting string is 'capitalized'.
    func camel(upperFirst: Bool, locale: Locale? = nil) -> String {
        let nonLetters = CharacterSet.alphanumerics.inverted
        
        let fragments = self.splitBefore { (character) -> Bool in
            guard let scalar = character.unicodeScalars.first else {
                return false
            }
            
            return nonLetters.contains(scalar)
        }
        
        var stringFragments = fragments.map({ String($0) })
        for (index, fragment) in stringFragments.enumerated() {
            let cleanFragment = fragment.replacingCharacters(in: nonLetters, with: "")
            stringFragments[index] = cleanFragment
        }
        
        stringFragments.removeAll(where: { $0 == "" })
        
        let outputFragments: [String]
        
        if upperFirst {
            outputFragments = stringFragments.map({ $0.capitalized(with: locale) })
        } else {
            var collection: [String] = []
            for (index, fragment) in stringFragments.enumerated() {
                if index == 0 {
                    collection.append(fragment.lowercased(with: locale))
                } else {
                    collection.append(fragment.capitalized(with: locale))
                }
            }
            outputFragments = collection
        }
        
        return outputFragments.joined()
    }
    
    /// Produces a string that removes all non-alphanumeric characters, joining the
    /// resulting fragments with the provided `separator`.
    /// - parameter separator: String to use when joining cleaned fragments.
    func alphanumericsSeparated(separator: String, locale: Locale? = nil) -> String {
        let nonLetters = CharacterSet.alphanumerics.inverted
        
        let fragments = self.splitBefore { (character) -> Bool in
            guard let scalar = character.unicodeScalars.first else {
                return false
            }
            
            return nonLetters.contains(scalar)
        }
        
        var stringFragments = fragments.map({ String($0) })
        for (index, fragment) in stringFragments.enumerated() {
            let cleanFragment = fragment.replacingCharacters(in: nonLetters, with: "")
            stringFragments[index] = cleanFragment
        }
        
        stringFragments.removeAll(where: { $0 == "" })
        
        return stringFragments.joined(separator: separator)
    }
}
