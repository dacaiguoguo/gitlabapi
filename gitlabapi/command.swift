//
//  command.swift
//  gitlabapi
//
//  Created by yanguo sun on 09/10/2016.
//  Copyright © 2016 Lvmama. All rights reserved.
//
import Foundation
class TestCommand: NSObject {
    var configDic: [String:String] = ["":""]
    var httphostUrl:String = ""
    var username:String = ""
    var userpassword:String = ""

    init(aconfigDic:[String:String]) {
        configDic = aconfigDic;
        httphostUrl = configDic["httphostUrl"]!
        username = configDic["username"]!
        userpassword = configDic["userpassword"]!
        let topath = NSString(string: "~/Library/Logs/gitlabapi/").standardizingPath
        if !FileManager.default.fileExists(atPath:topath) {
            try! FileManager.default.createDirectory(atPath:topath, withIntermediateDirectories:false, attributes:nil)
        }
    }
    func toolCommand(launchPath:String, currentDirectoryPath:String, arguments: [String]) -> (Data,Data) {
        let errorPipe = Pipe()
        let outputPipe = Pipe()
        let task = Process()
        task.standardError = errorPipe
        task.standardOutput = outputPipe
        task.launchPath = launchPath
        task.currentDirectoryPath = currentDirectoryPath
        task.arguments = arguments
        task.launch()
        task.waitUntilExit()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        return (outputData, errorData)
    }
    
    func toolCommandOne(launchPath:String, currentDirectoryPath:String, arguments: [String]) -> Data {
        let errorPipe = Pipe()
        let outputPipe = Pipe()
        let task = Process()
        task.standardError = errorPipe
        task.standardOutput = outputPipe
        task.launchPath = launchPath
        task.currentDirectoryPath = currentDirectoryPath
        task.arguments = arguments
        task.launch()
        task.waitUntilExit()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = String(data: outputData, encoding: .utf8)
        print("output:\n\(outputString)");
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let errorString = String(data: errorData, encoding: .utf8)
        print("error:\n\(errorString)");
        return outputData
    }
    
    func cpCommand(fromPath:String, toPath:String) -> Void {
        let workPath = NSString(string: "~/Library/Logs/gitlabapi/").standardizingPath
        let arguments = [fromPath, toPath]
        let (outputData, errorData) =  self.toolCommand(launchPath: "/bin/cp", currentDirectoryPath: workPath, arguments: arguments)
        let outputString = String(data: outputData, encoding: .utf8)
        print("output:\n\(outputString)");
        let errorString = String(data: errorData, encoding: .utf8)
        print("error:\n\(errorString)");
    }
    
    func mkdirCommand(topath:String) -> Void {
        if !FileManager.default.fileExists(atPath:topath) {
            try! FileManager.default.createDirectory(atPath:topath, withIntermediateDirectories:false, attributes:nil)
        }
    }
    
    func gitCloneCommand(workPath:String,urlPath:String) -> Void {
        let launchPath = "/usr/bin/git"
        let arguments = ["clone",urlPath]
        let (outputData, errorData) =  self.toolCommand(launchPath: launchPath, currentDirectoryPath: workPath, arguments: arguments)
        let outputString = String(data: outputData, encoding: .utf8)
        print("output:\n\(outputString)");
        let errorString = String(data: errorData, encoding: .utf8)
        print("error:\n\(errorString)");
    }
    
    func sessionCommand() -> [String:Any] {
        let launchPath = "/usr/bin/curl"
        let workPath = NSString(string: "~/Library/Logs/gitlabapi/").standardizingPath
        let arguments = ["-X","POST","\(httphostUrl)/api/v3/session?login=\(username)&password=\(userpassword)"]
        let (outputData, _) =  self.toolCommand(launchPath: launchPath, currentDirectoryPath: workPath, arguments: arguments)
        let json = try? JSONSerialization.jsonObject(with: outputData) as! [String:Any]
        return json!
    }
    
    func groupidGet(token:String) -> NSArray {
        let launchPath = "/usr/bin/curl"
        let workPath = NSString(string: "~/Library/Logs/gitlabapi/").standardizingPath
        let arguments = ["\(httphostUrl)/api/v3/groups/?private_token=\(token)"]
        let (outputData, _) =  self.toolCommand(launchPath: launchPath, currentDirectoryPath: workPath, arguments: arguments)
        let outputString = String(data: outputData, encoding: .utf8)
        try? outputString?.write(toFile: "\(workPath)/group.log", atomically: true, encoding: .utf8)
        let json = try? JSONSerialization.jsonObject(with: outputData) as! NSArray
        return json!
    }
    
    func projectGet(groupid:String, token:String) -> [String:Any] {
        let launchPath = "/usr/bin/curl"
        let workPath = NSString(string: "~/Library/Logs/gitlabapi/").standardizingPath
        let arguments = ["\(httphostUrl)/api/v3/groups/\(groupid)?private_token=\(token)"]
        let (outputData, _) =  self.toolCommand(launchPath: launchPath, currentDirectoryPath: workPath, arguments: arguments)
        let outputString = String(data: outputData, encoding: .utf8)
        try? outputString?.write(toFile: "\(workPath)/group\(groupid).log", atomically: true, encoding: .utf8)
        let json = try? JSONSerialization.jsonObject(with: outputData) as! [String:Any]
        return json!
    }
    
}
