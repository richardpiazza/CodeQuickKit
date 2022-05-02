public extension Sequence {
    /// Splits a sequence at each instance of the supplied separator.
    /// [Stack Overflow](https://stackoverflow.com/questions/39592563/split-string-in-swift-by-their-capital-letters)
    func splitBefore(separator isSeparator: (Iterator.Element) throws -> Bool) rethrows -> [AnySequence<Iterator.Element>] {
        var result: [AnySequence<Iterator.Element>] = []
        var subSequence: [Iterator.Element] = []
        
        var iterator = self.makeIterator()
        while let element = iterator.next() {
            if try isSeparator(element) {
                if !subSequence.isEmpty {
                    result.append(AnySequence(subSequence))
                }
                subSequence = [element]
            } else {
                subSequence.append(element)
            }
        }
        
        result.append(AnySequence(subSequence))
        
        return result
    }
}
