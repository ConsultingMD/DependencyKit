import Foundation

/// The types with DependencyKit can manage provision of.
protocol DIStartupTime { var startupTime: Date { get } }
protocol DIName { var name: String { get } }
protocol DIRootName { var rootName: String { get } }
protocol DIMood { var mood: Bool { get } }
protocol DIFinalThoughts { var finalThoughts: String { get } }
