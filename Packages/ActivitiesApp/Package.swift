// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "ActivitiesApp",
  platforms: [
    .iOS(.v18)
  ],
  products: PackageTarget.allProducts,
  dependencies: [
//    PackageDependency.KaizenShared.packageDependency,
    PackageDependency.ElixirShared.packageDependency,
//    PackageDependency.ElixirUI.packageDependency,

    // MARK: - Remote
//    PackageDependency.SwiftLint.packageDependency,
    PackageDependency.ComposableArchitecture.packageDependency,
    PackageDependency.SwiftTagged.packageDependency,
    PackageDependency.XCTestDynamicOverlay.packageDependency,
//    PackageDependency.Overture.packageDependency,
//    PackageDependency.Prelude.packageDependency,
//    PackageDependency.CombineCocoa.packageDependency,
//    PackageDependency.CombineExt.packageDependency,
//    PackageDependency.SFSafeSymbols.packageDependency,
//    PackageDependency.Quick.packageDependency,
//    PackageDependency.Nimble.packageDependency,
//    PackageDependency.SwiftCustomDump.packageDependency,
    PackageDependency.IdentifiedCollections.packageDependency,
//    PackageDependency.SwiftWhisper.packageDependency,
//    PackageDependency.AudioKit.packageDependency,
//    PackageDependency.RealmSwift.packageDependency,
//    PackageDependency.SwiftyJSON.packageDependency,
//    PackageDependency.Firebase.packageDependency,
//    PackageDependency.Lottie.packageDependency,
//    PackageDependency.Facebook.packageDependency,
//    PackageDependency.AppsFlyer.packageDependency,
//    PackageDependency.Superwall.packageDependency,
//    PackageDependency.Mixpanel.packageDependency,
//    PackageDependency.RevenueCat.packageDependency,
//    PackageDependency.OneSignal.packageDependency,
    PackageDependency.SwiftCustomDump.packageDependency,
    PackageDependency.GRDB.packageDependency
  ],
  targets: PackageTarget.allTargets
)



// MARK: - PackageTarget
enum PackageTarget: String, CaseIterable {

  private static let testCases: [Self] = [
    .ActivitiesStreakEvaluationClientTests,

    .ActivityGoalModelTests,

    .DatabaseClientGRDBTests,
    
    .GoalCreationClientTests,
    
    .GoalEvaluationClientTests
  ]

  static var allProducts: [Product] {
    allCases.filter { !testCases.contains($0) }
      .map(\.product)
  }

  static var allTargets: [Target] {
    allCases.map(\.target)
  }

  // MARK: Cases

  case ActivitiesListFeature
  case ActivitiesListFeatureiOS

  case ActivitiesListFeatureOld

  case ActivitiesListFeatureUIKitOld
  
  case ActivityCreationFeature
  case ActivityCreationFeatureiOS

  case DaysOfWeekGoalCreationFeature
  case DaysOfWeekGoalCreationFeatureiOS
  
  case EveryXDaysGoalCreationFeature
  case EveryXDaysGoalCreationFeatureiOS
  
  case WeeksPeriodGoalCreationFeature
  case WeeksPeriodGoalCreationFeatureiOS
  
  case CreateSessionFeature
  case CreateSessionFeatureiOS

  case ActivityDetailFeature
  case ActivityDetailFeatureiOS
  
  case ActivityGeneralTabFeature
  case ActivityGeneralTabFeatureiOS
  
  case ActivityGoalsTabFeature
  case ActivityGoalsTabFeatureiOS
  
  case ActivitySessionsTabFeature
  case ActivitySessionsTabFeatureiOS
  
  case TagsListFeature
  case TagsListFeatureiOS

  case ActivitiesStreakEvaluationClient

  case DatabaseClient
  case DatabaseClientGRDB

  case GoalEvaluationClient
  case GoalCreationClient

  case Shared
  
  case SharedModels

  case SharedUI

  case AppDependenciesLive

  // Tests

  case ActivitiesStreakEvaluationClientTests

  case ActivityGoalModelTests

  case DatabaseClientGRDBTests

  case GoalCreationClientTests

  case GoalEvaluationClientTests

  private var name: String {
    let packagePrefix = "ACT"
    return packagePrefix + "." + self.rawValue
  }

  var product: Product {
    .library(name: name, targets: [name])
  }

  var targetDependency: Target.Dependency {
    .init(stringLiteral: name)
  }

  // MARK: Target
  var target: Target {
    switch self {

    case .ActivitiesListFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .CreateSessionFeature,
          .ActivityCreationFeature,
          .ActivityDetailFeature,
          .SharedModels,
          .DatabaseClient
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency,
          PackageDependency.IdentifiedCollections.Product.identifiedCollections.targetDependency
        ]
      )

    case .ActivitiesListFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .ActivitiesListFeature,
          .SharedUI,
          .ActivityCreationFeatureiOS,
          .CreateSessionFeatureiOS,
          .ActivityDetailFeatureiOS,
          .GoalEvaluationClient
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivitiesListFeatureOld:
      return createPackageTarget(
        dependencies: createTargetDependencies(

        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivitiesListFeatureUIKitOld:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .ActivitiesListFeatureOld
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivityCreationFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .SharedModels,
          .DatabaseClient,
          .DaysOfWeekGoalCreationFeature,
          .EveryXDaysGoalCreationFeature,
          .WeeksPeriodGoalCreationFeature
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivityCreationFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .ActivityCreationFeature,
          .DatabaseClient,
          .DaysOfWeekGoalCreationFeature,
          .DaysOfWeekGoalCreationFeatureiOS,
          .EveryXDaysGoalCreationFeature,
          .EveryXDaysGoalCreationFeatureiOS,
          .WeeksPeriodGoalCreationFeature,
          .WeeksPeriodGoalCreationFeatureiOS
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .DaysOfWeekGoalCreationFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .DatabaseClient,
          .SharedModels,
          .SharedUI
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .DaysOfWeekGoalCreationFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .DaysOfWeekGoalCreationFeature,
          .SharedUI,
          .Shared
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .EveryXDaysGoalCreationFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .DatabaseClient,
          .SharedModels,
          .SharedUI
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .EveryXDaysGoalCreationFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .EveryXDaysGoalCreationFeature,
          .SharedUI,
          .Shared
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .WeeksPeriodGoalCreationFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .DatabaseClient,
          .SharedModels,
          .SharedUI
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .WeeksPeriodGoalCreationFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .WeeksPeriodGoalCreationFeature,
          .SharedUI,
          .Shared
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )
      
    case .CreateSessionFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .DatabaseClient,
          .SharedModels
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )
      
    case .CreateSessionFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .CreateSessionFeature,
          .SharedUI,
          .SharedModels
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivityDetailFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .ActivityGeneralTabFeature,
          .ActivityGoalsTabFeature,
          .ActivitySessionsTabFeature,
          .DatabaseClient,
          .SharedModels
        ) + [
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivityDetailFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .ActivityDetailFeature,
          .ActivityGeneralTabFeatureiOS,
          .ActivityGoalsTabFeatureiOS,
          .ActivitySessionsTabFeatureiOS,
          .SharedModels
        ) + [
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivityGeneralTabFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .DatabaseClient,
          .SharedModels,
          .TagsListFeature
        ) + [
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivityGeneralTabFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .ActivityGeneralTabFeature,
          .SharedModels,
          .SharedUI,
          .TagsListFeature,
          .TagsListFeatureiOS
        ) + [
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivityGoalsTabFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .DatabaseClient,
          .SharedModels
        ) + [
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivityGoalsTabFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .ActivityGoalsTabFeature,
          .SharedModels,
          .SharedUI
        ) + [
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency,
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency
        ]
      )

    case .ActivitySessionsTabFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .SharedModels
        ) + [
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivitySessionsTabFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .ActivitySessionsTabFeature,
          .SharedModels
        ) + [
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )
      
    case .TagsListFeature:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .DatabaseClient,
          .SharedModels
        ) + [
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )
      
    case .TagsListFeatureiOS:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .SharedUI,
          .TagsListFeature,
          .SharedModels
        ) + [
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency
        ]
      )

    case .ActivitiesStreakEvaluationClient:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .DatabaseClient,
          .GoalEvaluationClient,
          .SharedModels
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency
        ]
      )

    case .DatabaseClient:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .SharedModels
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency
        ]
      )

    case .DatabaseClientGRDB:
      /*
       Leaving this code here... I added GRDB and it wasn't showing up, I switched to this, and now it works.
       Then I switched back to my createPackageTarget and it stays working. So no idea!
       */
//      return .target(
//        name: "DatabaseClientGRDB",
//        dependencies: [
//          "DatabaseClient",
//          .product(name: "GRDB", package: "GRDB.swift")
//        ]
//      )
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .DatabaseClient,
          .SharedModels
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.GRDB.Product.GRDB.targetDependency
        ]
      )

    case .GoalEvaluationClient:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .SharedModels
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency
        ]
      )

    case .GoalCreationClient:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .SharedModels
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency
        ]
      )

    case .Shared:
      return createPackageTarget(
        dependencies: createTargetDependencies(

        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency
        ]
      )

    case .SharedModels:
      return createPackageTarget(
        dependencies: createTargetDependencies(

        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.SwiftTagged.Product.tagged.targetDependency
        ]
      )

    case .SharedUI:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          .SharedModels
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency,
          PackageDependency.XCTestDynamicOverlay.Product.xcTestDynamicOverlay.targetDependency
        ],
        resources: [
          .process("Resources")
        ]
      )

    case .AppDependenciesLive:
      return createPackageTarget(
        dependencies: createTargetDependencies(
          // All Client targets
          .ActivitiesStreakEvaluationClient,
          .DatabaseClient,
          .DatabaseClientGRDB,
          .GoalEvaluationClient,
          .GoalCreationClient,
          
          // Shared modules
          .SharedModels,
          .Shared,
          .SharedUI
        ) + [
          PackageDependency.ElixirShared.Product.ElixirShared.targetDependency,
          PackageDependency.ComposableArchitecture.Product.composableArchitecture.targetDependency,
          PackageDependency.GRDB.Product.GRDB.targetDependency
        ]
      )

      // MARK: - Tests

    case .ActivitiesStreakEvaluationClientTests:
      return createPackageTestTarget(
        dependencies: createTargetDependencies(
          .ActivitiesStreakEvaluationClient,
          .DatabaseClientGRDB
        ) + [

        ]
      )

    case .ActivityGoalModelTests:
      return createPackageTestTarget(
        dependencies: createTargetDependencies(
          .SharedModels
        ) + [

        ]
      )

    case .DatabaseClientGRDBTests:
      return createPackageTestTarget(
        dependencies: createTargetDependencies(
          .DatabaseClientGRDB
        ) + [

        ]
      )

    case .GoalCreationClientTests:
      return createPackageTestTarget(
        dependencies: createTargetDependencies(
          .GoalCreationClient
        ) + [

        ]
      )

    case .GoalEvaluationClientTests:
      return createPackageTestTarget(
        dependencies: createTargetDependencies(
          .GoalEvaluationClient
        ) + [

        ]
      )


    }
  }

  // MARK: Helpers

  private func createTargetDependencies(
    _ packageTargets: PackageTarget...
  ) -> [Target.Dependency] {
    packageTargets.map(\.targetDependency)
  }

  private func createPackageTarget(
    dependencies: [Target.Dependency] = [],
    resources: [Resource]? = nil,
    plugins: [Target.PluginUsage] = []
  ) -> Target {

    return Target.target(
      name: self.name,
      dependencies: dependencies,
      resources: resources,
      swiftSettings: [
        .unsafeFlags([
          "-driver-time-compilation",
          "-Xfrontend",
          "-debug-time-function-bodies",
          "-Xfrontend",
          "-debug-time-expression-type-checking",
          "-Xfrontend",
          "-warn-long-function-bodies=100",
          "-Xfrontend",
          "-warn-long-expression-type-checking=100",
          "-Xfrontend",
          "-enable-experimental-concurrency"
        ])
      ],
      plugins: []
    )
  }

  private func createPackageTestTarget(
    dependencies: [Target.Dependency]
  ) -> Target {
    var dependencies = dependencies
    dependencies += [
//      PackageDependency.Quick.Product.quick.targetDependency,
//      PackageDependency.Nimble.Product.nimble.targetDependency,
      PackageDependency.SwiftCustomDump.Product.customDump.targetDependency
    ]

    return .testTarget(
      name: self.name,
      dependencies: dependencies
    )
  }

}

// MARK: - PackageDependency
enum PackageDependency {

  // MARK: Helper
  static func localPackageDependency(_ name: String) -> Package.Dependency {
    .package(name: name, path: "../\(name)")
  }

}

// MARK: - ComposableArchitecture
extension PackageDependency {

  enum ComposableArchitecture {
    static let package = "swift-composable-architecture"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/pointfreeco/swift-composable-architecture",
        exact: "1.20.2"
      )
    }

    enum Product: String {
      case composableArchitecture = "ComposableArchitecture"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - ElixirUI
extension PackageDependency {

  enum ElixirUI {
    static let package = "ElixirUI"

    static var packageDependency: Package.Dependency {
      localPackageDependency(package)
    }

    enum Product: String {
      case elixirUI = "ElixirUI"
      case elixirDatePicker = "ElixirDatePicker"
      case editEventRecurrenceRule = "EditEventRecurrenceRule"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - ElixirShared
extension PackageDependency {

  enum ElixirShared {
    static let package = "ElixirShared"

    static var packageDependency: Package.Dependency {
      .package(
        url: "file:///Users/annguyen/Documents/2. Areas/Xcode Projects/Genesis/Packages/ElixirShared",
        branch: "main"
      )
    }

    enum Product: String {
      case ElixirShared
      case YouTubeDLWorker
      case YouTubeDLWorkerLive

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }

  }

}


// MARK: - SwiftLint
extension PackageDependency {

  enum SwiftLint {
    static let package = "SwiftLint"

    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/realm/SwiftLint",
        from: "0.51.0"
      )
    }

    enum Plugin: String {
      case swiftLintPlugin = "SwiftLintPlugin"

      var plugin: Target.PluginUsage {
        .plugin(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - SwiftTagged
extension PackageDependency {

  enum SwiftTagged {
    static let package = "swift-tagged"

    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/pointfreeco/swift-tagged",
        exact: "0.10.0"
      )
    }

    enum Product: String {
      case tagged = "Tagged"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - XCTestDynamicOverlay
extension PackageDependency {

  enum XCTestDynamicOverlay {
    static let package = "xctest-dynamic-overlay"

    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/pointfreeco/xctest-dynamic-overlay",
        from: "1.0.2"
      )
    }

    enum Product: String {
      case xcTestDynamicOverlay = "XCTestDynamicOverlay"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Overture
extension PackageDependency {

  enum Overture {
    static let package = "swift-overture"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/pointfreeco/swift-overture",
        from: "0.5.0"
      )
    }

    enum Product: String {
      case overture = "Overture"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Prelude
extension PackageDependency {

  enum Prelude {
    static let package = "swift-prelude"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/pointfreeco/swift-prelude",
        branch: "main"
      )
    }

    enum Product: String {
      case prelude = "Prelude"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - CombineCocoa
extension PackageDependency {

  enum CombineCocoa {
    static let package = "CombineCocoa"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/CombineCommunity/CombineCocoa",
        from: "0.4.1"
      )
    }

    enum Product: String {
      case combineCocoa = "CombineCocoa"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - CombineExt
extension PackageDependency {

  enum CombineExt {
    static let package = "CombineExt"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/CombineCommunity/CombineExt",
        from: "1.8.1"
      )
    }

    enum Product: String {
      case combineExt = "CombineExt"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - SFSafeSymbols
extension PackageDependency {

  enum SFSafeSymbols {
    static let package = "SFSafeSymbols"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/SFSafeSymbols/SFSafeSymbols",
        from: "4.1.1"
      )
    }

    enum Product: String {
      case sfSafeSymbols = "SFSafeSymbols"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Quick
extension PackageDependency {

  enum Quick {
    static let package = "Quick"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/Quick/Quick",
        from: "6.0.0"
      )
    }

    enum Product: String {
      case quick = "Quick"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Nimble
extension PackageDependency {

  enum Nimble {
    static let package = "Nimble"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/Quick/Nimble",
        from: "12.0.0"
      )
    }

    enum Product: String {
      case nimble = "Nimble"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - SwiftCustomDump
extension PackageDependency {

  enum SwiftCustomDump {
    static let package = "swift-custom-dump"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/pointfreeco/swift-custom-dump",
        exact: "1.3.3"
      )
    }

    enum Product: String {
      case customDump = "CustomDump"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - IdentifiedCollections
extension PackageDependency {

  enum IdentifiedCollections {
    static let package = "swift-identified-collections"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/pointfreeco/swift-identified-collections",
        exact: "1.1.1"
      )
    }

    enum Product: String {
      case identifiedCollections = "IdentifiedCollections"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - SwiftWhisper
extension PackageDependency {

  enum SwiftWhisper {
    static let package = "SwiftWhisper"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/exPHAT/SwiftWhisper",
//        from: "1.2.0"
        /// Use fast branch when testing on non-production
        branch: "fast"
      )
    }

    enum Product: String {
      case swiftWhisper = "SwiftWhisper"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - AudioKit
extension PackageDependency {

  enum AudioKit {
    static let package = "AudioKit"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/AudioKit/AudioKit",
        from: "5.6.0"
      )
    }

    enum Product: String {
      case AudioKit

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - RealmSwift
extension PackageDependency {

  enum RealmSwift {
    static let package = "realm-swift"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/realm/realm-swift.git",
        from: "10.39.1"
      )
    }

    enum Product: String {
      case realm = "Realm"
      case realmSwift = "RealmSwift"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}


// MARK: - SwiftyJSON
extension PackageDependency {

  enum SwiftyJSON {
    static let package = "SwiftyJSON"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/SwiftyJSON/SwiftyJSON",
        from: "5.0.0"
      )
    }

    enum Product: String {
      case SwiftyJSON

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Firebase
extension PackageDependency {

  enum Firebase {
    static let package = "firebase-ios-sdk"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/firebase/firebase-ios-sdk",
        from: "10.21.0"
      )
    }

    enum Product: String {
      case FirebaseAnalytics
      case FirebaseAuth
      case FirebaseRemoteConfig
      case FirebaseCrashlytics
      case FirebasePerformance
      case FirebaseFirestore
      case FirebaseStorage
      case FirebaseFunctions

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Firebase
extension PackageDependency {

  enum GoogleMobileAds {
    static let package = "swift-package-manager-google-mobile-ads"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/googleads/swift-package-manager-google-mobile-ads",
        exact: "11.5.0"
      )
    }

    enum Product: String {
      case GoogleMobileAds

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Mantis
extension PackageDependency {

  enum Mantis {
    static let package = "Mantis"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/guoyingtao/Mantis",
        from: "2.21.0"
      )
    }

    enum Product: String {
      case Mantis

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - OpenAI
extension PackageDependency {

  enum OpenAI {
    static let package = "OpenAI"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/MacPaw/OpenAI",
        from: "0.2.8"
      )
    }

    enum Product: String {
      case OpenAI

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Shufle
extension PackageDependency {

  enum Shuffle {
    static let package = "Shuffle"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/an-nguyen-d/Shuffle",
        branch: "master"
//        from: "0.4.2"
      )
//      .package(url: <#T##String#>, branch: <#T##String#>)
    }

    enum Product: String {
      case shuffle = "Shuffle"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - KaizenShared
extension PackageDependency {

  enum KaizenShared {
    static let package = "KaizenShared"

    static var packageDependency: Package.Dependency {
      localPackageDependency(package)
    }

    enum Product: String {

      case ActivitiesClient

      case ActivitiesListWorker

      case ActivityDateStatusCalculator

      case ActivityDateStatusWorker

      case ActivityGoalsClient
      case ActivityGoalsClientLive

      case ActivityLogClient
      case ActivityLogClientLive

      case ActivitySessionModelEditFeature

      case ActivitySessionModelsClient
      case ActivitySessionModelsClientLive

      case AudioPlayerFeature

      case CameraClient
      case CameraClientLive

      case ConcurrentRequestWorker

      case DatabaseClient
      case DatabaseClientLive

      case EnvVars

      case LoginFeature

      case NotionClient

      case Models

      case ProfileClient

      case RealmClient

      case RemoteFileStorageClient
      case RemoteFileStorageClientLive

      case SettingsFeature

      case Shared

      var targetDependency: Target.Dependency {
        .product(name: "KZN.SHARED." + self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Lottie
extension PackageDependency {

  enum Lottie {
    static let package = "lottie-ios"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/airbnb/lottie-ios",
        from: "4.4.3"
      )
    }

    enum Product: String {
      case lottie = "Lottie"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - AppsFlyer
extension PackageDependency {

  enum AppsFlyer {
    static let package = "AppsFlyerFramework"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework",
        from: "6.13.0"
      )
    }

    enum Product: String {
      case AppsFlyerLib

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Mixpanel
extension PackageDependency {

  enum Mixpanel {
    static let package = "mixpanel-swift"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/mixpanel/mixpanel-swift",
        from: "4.2.0"
      )
    }

    enum Product: String {
      case Mixpanel

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - OneSignal
extension PackageDependency {

  enum OneSignal {
    static let package = "OneSignal-XCFramework"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/OneSignal/OneSignal-XCFramework",
        /**
         We are intentionally not using 5.0.0 and afterwards because RevenueCat integration is not updated yet:
         https://www.revenuecat.com/docs/integrations/third-party-integrations/onesignal#1-send-device-data-to-revenuecat
         */
        from: "3.12.6"
      )
    }

    enum Product: String {
      case OneSignal
      /*
      case OneSignalFramework
      case OneSignalInAppMessages
      */

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - RevenueCat
extension PackageDependency {

  enum RevenueCat {
    static let package = "purchases-ios"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/RevenueCat/purchases-ios",
        from: "4.36.3"
      )
    }

    enum Product: String {
      case RevenueCat

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - Superwall
extension PackageDependency {

  enum Superwall {
    static let package = "Superwall-iOS"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/superwall/Superwall-iOS",
        from: "3.6.6"
      )
    }

    enum Product: String {
      case SuperwallKit

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}




// MARK: - Facebook
extension PackageDependency {

  enum Facebook {
    static let package = "facebook-ios-sdk"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/facebook/facebook-ios-sdk",
        from: "17.0.2"
      )
    }

    enum Product: String {
      case FacebookCore

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}

// MARK: - GRDB
extension PackageDependency {

  enum GRDB {
    static let package = "GRDB.swift"
    static var packageDependency: Package.Dependency {
      .package(
        url: "https://github.com/groue/GRDB.swift",
        exact: "7.5.0"
      )
    }

    enum Product: String {
      case GRDB
      case GRDBDynamic = "GRDB-dynamic"

      var targetDependency: Target.Dependency {
        .product(name: self.rawValue, package: package)
      }
    }
  }

}
