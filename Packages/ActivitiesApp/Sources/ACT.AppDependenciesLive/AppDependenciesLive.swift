import Foundation
import ElixirShared
import ComposableArchitecture

// All Client protocols
import ACT_GoalEvaluationClient
import ACT_GoalCreationClient

import ACT_DatabaseClient

import ACT_ActivitiesStreakEvaluationClient

// Client implementations  
import ACT_DatabaseClientGRDB

// Shared modules
import ACT_SharedModels
import ACT_Shared
import ACT_SharedUI

// External dependencies needed by GRDB
import GRDB

public struct AppDependenciesLive:
                                    
  Sendable,

HasGoalEvaluationClient,
HasGoalCreationClient,

HasDatabaseClient,

HasActivitiesStreakEvaluationClient,

HasDateMaker,
HasTimeZone
{
  
  // Dependencies are grouped, with base dependencies (dependencies that have no dependencies) at the top, with each layer introducing another dependency in the previous layer.
  
  public var dateMaker: DateMaker
  public var timeZone: TimeZone
  
  public var goalEvaluationClient: GoalEvaluationClient
  public var goalCreationClient: GoalCreationClient
  
  //
  
  public var databaseClient: DatabaseClient
  
  //
  
  public var activitiesStreakEvaluationClient: ActivitiesStreakEvaluationClient
  
  public init() async {
    self.dateMaker = .liveValue
    self.timeZone = .autoupdatingCurrent
    
    self.goalEvaluationClient = .liveValue()
    self.goalCreationClient = .liveValue()
    
    self.databaseClient = .grdbValue(
      dateMaker: self.dateMaker,
      timeZone: self.timeZone,
      configuration: .file(
        path: Self.databasePath()
      ) 
    )
    
    self.activitiesStreakEvaluationClient = await .liveValue(
      dateMaker: self.dateMaker,
      timeZone: self.timeZone,
      databaseClient: self.databaseClient,
      goalEvaluationClient: self.goalEvaluationClient
    )
  }
  
}

// MARK: - Database Path Logic

extension AppDependenciesLive {
  
  private static func databasePath() -> String {
    let fileManager = FileManager.default
    
    // Check iCloud availability
    print("🔍 iCloud identity token: \(fileManager.ubiquityIdentityToken != nil ? "Present" : "Nil")")
    
    // Try with explicit container ID
    let containerID = "iCloud.com.elixirapps.Activities"  // Replace with your actual ID
    
    if let iCloudContainerURL = fileManager.url(forUbiquityContainerIdentifier: containerID) {
      // Create database directory in iCloud container
      let databaseDirectory = iCloudContainerURL.appendingPathComponent("Database", isDirectory: true)
      
      // Ensure directory exists
      if !fileManager.fileExists(atPath: databaseDirectory.path) {
        try? fileManager.createDirectory(at: databaseDirectory, withIntermediateDirectories: true)
      }
      
      // Return iCloud database path
      let databaseURL = databaseDirectory.appendingPathComponent("activities.sqlite")
      checkiCloudSyncStatus(for: databaseURL)
      print("🔵 Using iCloud database at: \(databaseURL.path)")
      return databaseURL.path
    } else {
      print("❌ Failed to get iCloud container for ID: \(containerID ?? "default")")
      // Check if it's a capability issue or user issue
      if fileManager.ubiquityIdentityToken == nil {
        print("❌ Reason: User not signed into iCloud")
      } else {
        print("❌ Reason: Container not configured or capability missing")
      }
      
      return localDatabasePath().path
    }
  }

  private static func checkiCloudSyncStatus(for url: URL) {
      do {
          let resourceValues = try url.resourceValues(forKeys: [
//              .ubiquitousItemIsDownloadedKey,
              .ubiquitousItemIsDownloadingKey,
              .ubiquitousItemIsUploadedKey,
              .ubiquitousItemIsUploadingKey,
              .ubiquitousItemDownloadingStatusKey
          ])

          print("📊 iCloud Status for \(url.lastPathComponent):")
//          print("  Downloaded: \(resourceValues.ubiquitousItemIsDownloaded ?? false)")
          print("  Downloading: \(resourceValues.ubiquitousItemIsDownloading ?? false)")
          print("  Uploaded: \(resourceValues.ubiquitousItemIsUploaded ?? false)")
          print("  Uploading: \(resourceValues.ubiquitousItemIsUploading ?? false)")
          print("  Status: \(resourceValues.ubiquitousItemDownloadingStatus?.rawValue ?? "unknown")")
      } catch {
          print("❌ Error checking sync status: \(error)")
      }
  }

  private static func localDatabasePath() -> URL {
    let fileManager = FileManager.default
    
    // Get application support directory
    guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, 
                                               in: .userDomainMask).first else {
      fatalError("Could not find Application Support directory")
    }
    
    // Create app-specific directory using bundle identifier or fallback
    let bundleID = Bundle.main.bundleIdentifier ?? "com.activities.app"
    let appDirectory = appSupportURL.appendingPathComponent(bundleID, isDirectory: true)
    
    // Ensure directory exists
    if !fileManager.fileExists(atPath: appDirectory.path) {
      try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
    }
    
    // Return local database path
    return appDirectory.appendingPathComponent("activities.sqlite")
  }
}
