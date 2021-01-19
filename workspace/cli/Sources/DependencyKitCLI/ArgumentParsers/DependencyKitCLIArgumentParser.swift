import ArgumentParser

struct DepGen: ParsableArguments {
    @Option(name: [.customShort("c"), .long], help: "A YAML config file")
    var config = ""
}
