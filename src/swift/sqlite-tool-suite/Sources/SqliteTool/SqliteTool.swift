//
//  SqliteTool.swift
//
//  Created by Markus Schmid on 17.07.22.
//

import SqliteUtil
import Foundation
import ArgumentParser

@main
struct SqliteTool: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A tool for Core Data sqlite creation and performing simple queries.",
        version: "1.0.0",
        subcommands: [New.self, Query.self],
        defaultSubcommand: New.self)
}

extension SqliteTool {
    struct New: ParsableCommand {
        static var configuration =
            CommandConfiguration(abstract: "Create a new Core Data SQLite file.")

        @Argument(help: "The path to the Core Data model dir e.g. `../datamodel/Example.momd`.")
        var momd: String

        @Argument(help: "The target where the new SQLite file should be written e.g. `./data/Example.sqlite`.")
        var sqlitefile: String

        @Argument(help: "The Core Data model configuration name e.g. `EXAMPLE`.")
        var configname: String

        mutating func run() {
            let configuration = configname
            let momdURL = URL(fileURLWithPath: momd, isDirectory: true)
            let sqliteFileURL  = URL(fileURLWithPath: sqlitefile, isDirectory: false)
            let util = SqliteUtil()
            do {
                try util.new(config: configuration, momd: momdURL, target: sqliteFileURL)
            } catch {
                print(" An error occurred: \(error)")
            }
        }
    }
}

extension SqliteTool {
    struct Query: ParsableCommand {
        static var configuration =
            CommandConfiguration(
                abstract: "Simple queries on the Taxa Core Data SQLite data base.",
                subcommands: [CountSpecies.self, SpeciesInfo.self],
                defaultSubcommand: CountSpecies.self)
    }
}

extension SqliteTool.Query {
    struct CountSpecies: ParsableCommand {
        static var configuration =
            CommandConfiguration(
                abstract: "Returns the total number of species stored in this database.")

        @Argument(help: "The source SQLite file e.g. `./data/Example.sqlite`.")
        var sqlitefile: String

        @Argument(help: "The path to the Core Data model dir e.g. `../datamodel/Example.momd`.")
        var model: String

        mutating func run() {
            let sqliteFileURL  = URL(fileURLWithPath: sqlitefile, isDirectory: false)
            let momdURL = URL(fileURLWithPath: model, isDirectory: true)
            let util = SqliteUtil()
            do {
                try util.printCountSpecies(source: sqliteFileURL, model: momdURL)
            } catch {
                print(" An error occurred: \(error)")
            }
        }
    }
}

extension SqliteTool.Query {
    struct SpeciesInfo: ParsableCommand {
        static var configuration =
            CommandConfiguration(
                abstract: "Returns info about a species stored in this database.")

        @Argument(help: "The source SQLite file e.g. `./data/Example.sqlite`.")
        var sqlitefile: String
        
        @Argument(help: "The path to the Core Data model dir e.g. `../datamodel/Example.momd`.")
        var model: String

        @Argument(help: "The species name e.g. `Bellis perennis`.")
        var specname: String

        mutating func run() {
            let sqliteFileURL  = URL(fileURLWithPath: sqlitefile, isDirectory: false)
            let momdURL = URL(fileURLWithPath: model, isDirectory: true)
            let util = SqliteUtil()
            do {
                try util.printSpeciesInfo(source: sqliteFileURL, name: specname, model: momdURL)
            } catch {
                print(" An error occurred: \(error)")
            }
        }
    }
}