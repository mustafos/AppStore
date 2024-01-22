import Foundation

protocol MinecraftSkinManagerProtocol {
    typealias GetSkinCompletion = (URL) -> ()
    
    var completion: GetSkinCompletion? { get }
    
    func start(_ imagePath: URL, completion: @escaping GetSkinCompletion)
}

class MinecraftSkinManager: MinecraftSkinManagerProtocol {
    private(set) var completion: GetSkinCompletion?
    
    private let fileManager = FileManager.default
    private var urls: [URL] = []
    private var currentPathDirr: URL!
    private let name = "minecraft_skin"
    
    var errorInternal: NSError?
    
    func start(_ imagePath: URL, completion: @escaping GetSkinCompletion) {
        
        self.completion = completion
        
        let name = imagePath.lastPathComponent
        
        currentPathDirr = makeFolders()
        makeManifestJSON("\(name)skin")
        createJSONForSkins(name: "\(name)skin", texture: name)
        createLocalizeFile(name: "\(name)skin")
        appendSkinImage(imagePath)
        makeArchive(name.replacingOccurrences(of: ".png", with: "") )
    }
}

extension MinecraftSkinManager {
    
    private func makeFolders() -> URL {
        let fileUrl = fileManager.cachesDirectory.appendingPathComponent(name)
        var url = URL(fileURLWithPath: "")
        if !fileManager.fileExists(atPath: fileUrl.path) {
            do {
                try fileManager.secureCreateDirectory(at: fileUrl)
                urls.append(fileUrl)
                url = fileUrl
            } catch {
                AppDelegate.log(error.localizedDescription)
            }
        } else {
            do {
                try fileManager.removeItem(atPath: fileUrl.path)
                url = makeFolders()
            } catch {
                AppDelegate.log(error.localizedDescription)
            }
        }
        
        return url
    }
    
    private func makeManifestJSON(_ name: String) {
        let fileURL = currentPathDirr.appendingPathComponent("manifest.json")
        let dictionary : [String : Any] = ["format_version":1,
                                          "header":[
                                            "name":"\(name)",
                                            "uuid":"\(UUID().uuidString)",
                                            "version":[1, 0, 0]] as [String : Any],
                                          "modules":[
                                            ["type": "skin_pack",
                                             "uuid": "\(UUID().uuidString)",
                                             "version": [ 1, 0, 0]] as [String : Any]
                                          ]]
        
        do {
            let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .init(rawValue: 0))
            AppDelegate.log("\n", NSString(data: jsonData!, encoding: 1)!)
            
            try jsonData?.write(to: fileURL, options: [])
            urls.append(fileURL)
            
            AppDelegate.log("File saved: \(fileURL.absoluteURL)")
        } catch {
            AppDelegate.log(error.localizedDescription)
        }
    }
    
    private func createJSONForSkins(name: String, texture: String) {
        let fileUrl = currentPathDirr.appendingPathComponent("skins.json")
        let dictonary: [String : Any] = ["skins":[["localization_name":"\(name)",
                                                   "geometry":"geometry.\(name).\(name)",
                                                   "texture":"\(texture)",
                                                   "type":"free"]],
                                         "serialize_name":"\(name)",
                                         "localization_name":"\(name)"]
        do {
            let jsonData = try? JSONSerialization.data(withJSONObject: dictonary, options: .init(rawValue: 0))
            AppDelegate.log("\n",NSString(data: jsonData!, encoding: 1)!)
            
            try jsonData?.write(to: fileUrl, options: [])
            urls.append(fileUrl)
        } catch {
            AppDelegate.log(error.localizedDescription)
        }
    }
    
    private func createLocalizeFile(name: String) {
        let fileName = "en_US.lang"
        let text: String = "skinpack.\(name)=\(name) \n skin.\(name).\(name)=\(name)"
        let localizeDirection = makeFolderForLocalizeFile()
        let fileURL = localizeDirection.appendingPathComponent(fileName)
        
        do {
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
            urls.append(fileURL)
        } catch {
            AppDelegate.log(error.localizedDescription)
        }
    }
    
    private func makeFolderForLocalizeFile() -> URL {
        let fileUrl = currentPathDirr.appendingPathComponent("texts")
        var url = URL(fileURLWithPath: "")
        if !fileManager.fileExists(atPath: fileUrl.path) {
            do {
                try fileManager.secureCreateDirectory(at: fileUrl)
                urls.append(fileUrl)
                url = fileUrl
            } catch {
                AppDelegate.log(error.localizedDescription)
            }
        } else {
            do {
                try fileManager.removeItem(atPath: fileUrl.path)
                url = makeFolderForLocalizeFile()
            } catch {
                AppDelegate.log(error.localizedDescription)
            }
        }
        
        return url
    }
    
    private func appendSkinImage(_ imagePath: URL) {
        let fileUrl = currentPathDirr.appendingPathComponent(imagePath.absoluteURL.lastPathComponent)
        do {
            try fileManager.copyItem(at: imagePath, to: fileUrl)
            urls.append(fileUrl)
        } catch {
            AppDelegate.log(error.localizedDescription)
        }
    }
    
    private func makeArchive(_ name: String) {
        var archiveUrl: URL?
        var error: NSError?
        
        let fileCoordinator = NSFileCoordinator()
        
        fileCoordinator.coordinate(readingItemAt: currentPathDirr, options: [.forUploading], error: &error) { [weak fileManager, self] zipUrl in
            
            guard let destinationUrl = fileManager?.cachesDirectory.appendingPathComponent("skinTmp") else {
                self.errorInternal = NSError(domain: "MinecraftSkinManager", code: 1001, userInfo: [NSLocalizedDescriptionKey : "can't  create temp dir"])
                return
            }
            
            fileManager?.secureSafeCreateDirectory(at: destinationUrl)
            
            let tmpUrl = destinationUrl.appendingPathComponent("\(name).mcpack")
            
            do {
                try fileManager?.secureMoveItem(at: zipUrl, to: tmpUrl)
                archiveUrl = tmpUrl
            } catch {
                self.errorInternal = NSError(domain: "MinecraftSkinManager", code: 1002, userInfo: [NSLocalizedDescriptionKey : "can't move archived file"])
            }
        }
        
        guard let archiveUrl else {
            AppDelegate.log((error ?? errorInternal)?.localizedDescription as Any)
            return
        }
        
        completion?(archiveUrl)
    }
}
