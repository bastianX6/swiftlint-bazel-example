import SwiftLintCore
import SwiftSyntax

@SwiftSyntaxRule(optIn: true)
struct NoAbbreviationsRule: Rule {
    var configuration = NoAbbreviationsConfiguration()

    static let description = RuleDescription(
        identifier: "no_abbreviations",
        name: "No Abbreviations",
        description: "Class and variable names should not contain abbreviations; use full words.",
        kind: .lint,
        nonTriggeringExamples: [
            Example("class Configuration {}"),
            Example("let accessibilityLabel = \"foo\"")
        ],
        triggeringExamples: [
            Example("class Config {}"),
            Example("let a11yLabel = \"foo\"")
        ]
    )
}

private extension NoAbbreviationsRule {
    final class Visitor: ViolationsSyntaxVisitor<ConfigurationType> {
        override func visitPost(_ node: ClassDeclSyntax) {
            checkIdentifier(node.name.text, position: node.name.positionAfterSkippingLeadingTrivia)
        }

        override func visitPost(_ node: IdentifierPatternSyntax) {
            checkIdentifier(node.identifier.text, position: node.identifier.positionAfterSkippingLeadingTrivia)
        }

        private func checkIdentifier(_ name: String, position: AbsolutePosition) {
            let words = splitWords(name)
            let forbiddenSet = Set(configuration.forbiddenAbbreviations.map { $0.lowercased() })

            for word in words {
                if forbiddenSet.contains(word) {
                    violations.append(position)
                    return
                }
            }
        }

        private func splitWords(_ identifier: String) -> [String] {
            var words: [String] = []
            var current = ""

            for character in identifier {
                if character == "_" || character == "-" || character.isWhitespace {
                    if !current.isEmpty {
                        words.append(current)
                        current.removeAll(keepingCapacity: true)
                    }
                    continue
                }

                if character.isLetter || character.isNumber {
                    if character.isLetter,
                       String(character) == String(character).uppercased(),
                       String(character) != String(character).lowercased(),
                       !current.isEmpty {
                        words.append(current)
                        current = String(character).lowercased()
                    } else {
                        current.append(String(character).lowercased())
                    }
                } else if !current.isEmpty {
                    words.append(current)
                    current.removeAll(keepingCapacity: true)
                }
            }

            if !current.isEmpty {
                words.append(current)
            }

            return words
        }
    }
}

@AutoConfigParser
struct NoAbbreviationsConfiguration: SeverityBasedRuleConfiguration {
    @ConfigurationElement(key: "severity")
    private(set) var severityConfiguration = SeverityConfiguration<Parent>(.warning)

    @ConfigurationElement(key: "forbidden_abbreviations")
    var forbiddenAbbreviations: [String] = ["config", "a11y", "mgr", "svc"]
}
