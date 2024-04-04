//
//  DropBoxParserFiles.swift
//  Crafty Craft 10
//
//  Created by Zolux Rex on 08.02.2024.
//  Copyright © 2024 Noname Digital. All rights reserved.
//

import Foundation
import SwiftyDropbox

final class DropBoxParserFiles: NSObject {
    
    static let shared = DropBoxParserFiles()
    public var client: DropboxClient?
    private let defaults = UserDefaults.standard
    private var isReadyContent : Bool = false
    private let realmService = RealmServiceProviding.shared
    
    private override init() {
        super.init()
    }
    
    public func zetupDropBox() {
        
        clearAllThings()
        
        guard let refresh = self.defaults.value(forKey: DropBoxCuteKeys_json.RefreshTokenSaveVarieble) as? String else {
            AppDelegate.log("DropBoxParserFiles: start resetting token operation")
            giveMePleaseReshreshToken(code: DropB0ksKeys.token) { [weak self] refresh_token in
                if let rToken = refresh_token {
                    AppDelegate.log(rToken)
                    self?.defaults.setValue(rToken, forKey: DropBoxCuteKeys_json.RefreshTokenSaveVarieble)
                    self?.makeValidateAccessTokenDropBoxMamaMia(token: rToken) { validator in
                        if validator {
                            self?.startFeatchAfterAmazingValidatorToken(validate: validator)
                        } else {
                            self?.makeValidateAccessTokenDropBoxMamaMia(token: DropB0ksKeys.refresh_token) { validator2 in
                                self?.startFeatchAfterAmazingValidatorToken(validate: validator2)
                            }
                        }
                    }
                }
            }
            
            makeValidateAccessTokenDropBoxMamaMia(token: DropB0ksKeys.refresh_token) { [weak self] validator2 in
                self?.startFeatchAfterAmazingValidatorToken(validate: validator2)
            }
            
            return
        }
        
        AppDelegate.log("DropBoxParserFiles: \(refresh) add to ---> refresh_token")
        
        makeValidateAccessTokenDropBoxMamaMia(token: refresh) { [weak self] validator in
            self?.startFeatchAfterAmazingValidatorToken(validate: validator)
        }
    }
    
    private func pushBeautifulContentToApp() {
        NotificationCenter.default.post(name: Notification.Name("showContent"), object: nil)
    }
    
    private func pushServersContentToApp() {
        NotificationCenter.default.post(name: Notification.Name("showServers"), object: nil)
    }
    
    private func startFeatchAfterAmazingValidatorToken(validate : Bool) {
        if validate {
            AppDelegate.log("DropBoxParserFiles: token valid")
            if defaults.value(forKey: "dataDidLoaded") == nil || (defaults.value(forKey: "dataDidLoaded") != nil) == true {
                featchAddonsEditor { [weak self] dropData, contentIsReady in
                    AppDelegate.log("DropBoxParserFiles: \(dropData)")
                    AppDelegate.log("DropBoxParserFiles: \(contentIsReady)")
                    self?.validateBeautifulContent(contentIsReady)
                    self?.convertToLocalAmazingDataBase(dictionary: dropData, type: .addonsEditor) { isCompleted in
                        self?.validateBeautifulContent(isCompleted)
                    }
                }
                
                featchAmazingSkins { [weak self] dropData, contentIsReady  in
                    self?.validateBeautifulContent(contentIsReady)
                    self?.convertToLocalAmazingDataBase(dictionary: dropData, type: .skins) { isCompleted in
                        self?.validateBeautifulContent(isCompleted)
                    }
                }
                
                featchAmazingAddons { [weak self] categoryData, contentIsReady in
                    self?.validateBeautifulContent(contentIsReady)
                    self?.convertToLocalAmazingDataBase(dictionary: categoryData, type: .addons) { isCompleted in
                        self?.validateBeautifulContent(isCompleted)
                    }
                }
                
                featchAmazingMaps { [weak self] dataEditor, contentIsReady in
                    self?.validateBeautifulContent(contentIsReady)
                    self?.convertToLocalAmazingDataBase(dictionary: dataEditor, type: .maps) { isCompleted in
                        self?.validateBeautifulContent(isCompleted)
                    }
                }
                
                
                featchServers { [weak self] servers, contentIsReady in
                    guard contentIsReady else {
                        print("Servers load content - error")
                        return
                    }
                    self?.conversServerToLocalDataBase(servers: servers, comletion: { [weak self] isCompleted in
                        guard isCompleted else { return }
                        self?.pushServersContentToApp()
                    })
                    
                }
                
                featchSeeds {  [weak self] dropData, contentIsReady in
                    guard contentIsReady else {
                        print("Seeds load content - error")
                        return
                    }
                    
                    self?.convertToLocalAmazingDataBase(dictionary: dropData, type: .seeds) { isCompleted in
                    }
            }
                
            } else {
                AppDelegate.log("DropBoxParserFiles: data in database")
                pushBeautifulContentToApp()
            }
        } else {
            AppDelegate.log("DropBoxParserFiles: token has expired")
        }
    }
    
    private var contentCount = 0
    private func validateBeautifulContent(_ bool: Bool) {
        if bool {
            contentCount += 1
        }
        if contentCount == 4 {
            defaults.set(true, forKey: "dataDidLoaded")
            AppDelegate.log("DropBoxParserFiles: operation completed \(contentCount)")
            pushBeautifulContentToApp()
            contentCount = 0
        } else {
            AppDelegate.log("DropBoxParserFiles: operation not completed \(contentCount)")
        }
    }
    
    private func clearAllThings() {
        defaults.set(false, forKey: "dataDidLoaded")
        defaults.set(0, forKey: "json_categories_data_count")
        defaults.set(0, forKey: "json_data_count")
        defaults.set(0, forKey: "json_editor_data_count")
        defaults.set(0, forKey: "addon_content_count")
    }
    
    private func conversServerToLocalDataBase(servers: [Server], comletion: @escaping (Bool) -> ()) {
        realmService.addNew(servers: servers.map({$0.realmModel}))
    }
    
    private func convertToLocalAmazingDataBase(dictionary: NSMutableDictionary, type: DropBoxCategoryType, completion: @escaping (Bool) -> ()) {
        
        switch type {
        case .skins:
            if let dictionary: NSMutableDictionary = dictionary.object(forKey: type.getKey) as? NSMutableDictionary {
                if let items = dictionary.object(forKey: DropBoxCuteKeys_json.skin) as? [DropBoxSkins] {
                    if realmService.getAllSkins().isEmpty {
                        
                        let models = items.map { SkinsRealmSession(name: $0.skinName, skinSourceImagePath: $0.skinSourceImage, skinImagePath: $0.skinImage, isNew: $0.isNew, isFavorite: false, skinImageData: nil, filterCategory: $0.filterCategory) }
                        
                        realmService.addNew(skins: models)
                        
                        AppDelegate.log("DropBoxParserFiles: \(type.getKey) save skins to database")
                        
                    }
                    completion(true)
                } else {
                    AppDelegate.log("DropBoxParserFiles: errror items")
                }
            }
        case .seeds:
            if let dictionary: NSMutableDictionary = dictionary.object(forKey: type.getKey) as? NSMutableDictionary {
                if let items = dictionary.object(forKey: DropBoxCuteKeys_json.seed) as? [DropBoxSeed] {
                    
                    
                    if realmService.getAllSeed().isEmpty {
                        let models = items.map { SeedRealmSession(name: $0.name, seedImagePath: $0.imagePath, seedDescrip: $0.descrip, isNew: $0.isNew, seed: $0.seed) }
                        
                        realmService.addNew(seed: models)
                        
                        AppDelegate.log("DropBoxParserFiles: \(type.getKey) save seeds to database")
                    }
                    completion(true)
                } else {
                    AppDelegate.log("DropBoxParserFiles: errror items")
                }
            }
        case .addons:
            if let dictionary: NSMutableDictionary = dictionary.object(forKey: type.getKey) as? NSMutableDictionary {
                if let categories = dictionary.object(forKey: DropBoxCuteKeys_json.addon) as? [DropBoxAddons] {
                    if realmService.getAllAddons().isEmpty {
                        
                        let models = categories.map { AddonsRealmSession(addonImages: $0.addonImages, addonDescription: $0.addonDescription, addonTitle: $0.addonTitle, isNew: $0.isNew, isFavorite: false, addonImageData: nil, filterCategory: $0.filterCategory, file: $0.file) }
                        
                        realmService.addNew(addons: models)
                        
                        AppDelegate.log("DropBoxParserFiles: \(type.getKey) save skins to database")
                    }
                    completion(true)
                } else {
                    AppDelegate.log("DropBoxParserFiles: errror categories")
                }
            }
        case .maps:
            if let dictionary: NSMutableDictionary = dictionary.object(forKey: type.getKey) as? NSMutableDictionary {
                if let editorItems = dictionary.object(forKey: DropBoxCuteKeys_json.map) as? [DropBoxMaps] {
                    if realmService.getAllMap().isEmpty {
                        let models = editorItems.map { MapsRealmSession(mapImages: $0.mapImages, mapDescription: $0.mapDescription, mapTitle: $0.mapTitle, isNew: $0.isNew, isFavorite: false, mapImageData: nil, filterCategory: $0.filterCategory, file: $0.file) }
                        
                        realmService.addNew(maps: models)
                        
                        AppDelegate.log("DropBoxParserFiles: \(type.getKey) save skins to database")
                    }
                    completion(true)
                } else {
                    AppDelegate.log("DropBoxParserFiles: errror editorItems")
                }
            }
        case .addonsEditor:
            AppDelegate.log("DropBoxParserFiles: addonsEditor")
            
            if let dictionary: NSMutableDictionary = dictionary.object(forKey: AddonsEditorContent.addonTag) as? NSMutableDictionary {
                if let items = dictionary.object(forKey: AddonsEditorContent.addonTag) as? [AddonItem] {
                    if RealmService.shared.getAddonEditorArray().isEmpty {
                        
                        let models = items.map { item in
                            let addon = AddonsEdotorRealmSession()
                            addon.idshka = item.idshka
                            addon.displayName = item.displayName
                            addon.displayImage = AddonsEditorContent.addonMakerFolder + item.displayImage
                            addon.categoryImage = item.categoryImage
                            addon.id = item.id
                            addon.type = item.type
                            addon.file = item.file
                            
                            addon.skin_variants.append(objectsIn: item.skin_variants.map({ AddonSkinVariantObj(name: $0.name, path: AddonsEditorContent.addonMakerFolder + $0.displayImage) }))
                            
                            addon.health = item.health
                            addon.move_speed = item.move_speed
                            
                            addon.ranged_attack_enabled = item.ranged_attack.first?.enabled ?? false
                            addon.ranged_attack_atk_speed = item.ranged_attack.first?.atk_speed ?? 0.0
                            addon.ranged_attack_atk_radius = item.ranged_attack.first?.atk_radius ?? 0.0
                            addon.ranged_attack_burst_shots = item.ranged_attack.first?.burst_shots ?? 0.0
                            addon.ranged_attack_burst_interval = item.ranged_attack.first?.burst_interval ?? 0.0
                            addon.ranged_attack_atk_types = item.ranged_attack.first?.atk_types ?? ""
                            
                            return addon
                        }
                        
                        RealmService.shared.addNewAddonEditors(addons: models)
                        AppDelegate.log("DropBoxParserFiles: \(type.getKey) save skins to database")
                    }
                    completion(true)
                    
                } else {
                    AppDelegate.log("DropBoxParserFiles: errror items")
                }
            }
        }
    }
    
    private func parseMaps(json: [String : Any], mainKey: String, mapImages: String, mapDescription: String, mapTitle: String, isNew: String, fileKey: String) -> NSMutableDictionary {
        
        let result: NSMutableDictionary = NSMutableDictionary()
        var editorItems: [DropBoxMaps] = []
        if let modsCategory = json[mainKey] as? [String : Any] {
            for categoryName in modsCategory {
                if let content = modsCategory[categoryName.key.description] as? [String: Any] {
                    for itemContent in content {
                        let filterCategory = categoryName.key
                        if let items = itemContent.value as? [String: Any],
                           let mapImagesConteiner = items[mapImages] as? [String],
                           let mapDescription = items[mapDescription] as? String,
                           let new = items[isNew] as? Bool,
                           let mapTitle = items[mapTitle] as? String,
                           let file = items[fileKey] as? String
                        {
                            var mapImages: [String] = []
                            for images in mapImagesConteiner {
                                mapImages.append(images)
                            }
                            let category = DropBoxMaps(mapImages: mapImages, mapDescription: mapDescription, mapTitle: mapTitle, isNew: new, filterCategory: filterCategory, file: file)
                            editorItems.append(category)
                        }
                    }
                    
                }
            }
            result.setValue(editorItems, forKey: DropBoxCuteKeys_json.map)
        }
        return result
    }
    
    private func parseAddons(json: [String : Any], mainKey: String, addonImages: String, addonDescription: String, addonTitle: String, isNew: String, fileKey: String) -> NSMutableDictionary {
        
        let result: NSMutableDictionary = NSMutableDictionary()
        var dropBoxAddons: [DropBoxAddons] = []
        if let modsCategory = json[mainKey] as? [String : Any] {
            for categoryName in modsCategory {
                if let content = modsCategory[categoryName.key.description] as? [String: Any] {
                    for itemContent in content {
                        let filterCategory = categoryName.key
                        if let items = itemContent.value as? [String: Any],
                           let addonImagesConteiner = items[addonImages] as? [String],
                           let addonDescription = items[addonDescription] as? String,
                           let new = items[isNew] as? Bool,
                           let addonTitle = items[addonTitle] as? String,
                           let file = items[fileKey] as? String
                        {
                           
                            let item = DropBoxAddons(addonImages: addonImagesConteiner, addonDescription: addonDescription, addonTitle: addonTitle, isNew: new, filterCategory: filterCategory, file: file)
                            dropBoxAddons.append(item)
                        }
                    }
                }
            }
            result.setValue(dropBoxAddons, forKey: DropBoxCuteKeys_json.addon)
        }
        
        return result
    }
    
    private func parseSkins(json: [String : Any], mainKey: String, nameKey: String, imageKey: String, sourceImageKey: String, isNew: String) -> NSMutableDictionary {
        
        let result: NSMutableDictionary = NSMutableDictionary()
        var dropBoxSkins: [DropBoxSkins] = []
        if let modsItems = json[mainKey] as? [String : Any] {
            for categoryName in modsItems {
                if let content = modsItems[categoryName.key.description] as? [String: Any] {
                    for itemContent in content {
                        let filterCategory = categoryName.key
                        
                        if let items = itemContent.value as? [String: Any],
                           let img = items[imageKey] as? String,
                           let new = items[isNew] as? Bool,
                           let source = items[sourceImageKey] as? String {
                            let name = (items[nameKey] as? String) ?? ""
                            let item = DropBoxSkins(skinName:name, skinSourceImage: source, skinImage: img, isNew: new, filterCategory: filterCategory)
                            dropBoxSkins.append(item)
                        }
                    }
                }
            }
            result.setValue(dropBoxSkins, forKey: DropBoxCuteKeys_json.skin)
        }
        
        return result
    }
    
    private func parseSeeds(json: [String : Any], mainKey: String, nameKey: String, imageKey: String, descriptionKey: String, seedKey: String, isNew: String) -> NSMutableDictionary {
        let result: NSMutableDictionary = NSMutableDictionary()
        var dropBoxSeeds: [DropBoxSeed] = []
        guard let seedDic = json[mainKey] as? [String : Any] else { return [:]}
        if let modsItems = seedDic["Seeds"] as? [String : Any] {
            for categoryName in modsItems {
                if let content = modsItems[categoryName.key.description] as? [String: Any] {
                    
                    if let img = content[imageKey] as? String,
                       let new = content[isNew] as? Bool,
                       let name = content[nameKey] as? String,
                       let seed = content[seedKey] as? String,
                       seed.count < 45,
                       let descrip = content[descriptionKey] as? String {
                        
                        let item = DropBoxSeed(imagePath: img, descrip: descrip, name: name, seed: seed, isNew: new)
                        dropBoxSeeds.append(item)
                    }
                }
            }
            result.setValue(dropBoxSeeds, forKey: DropBoxCuteKeys_json.seed)
        }
        
        return result
    }
    
    private func featchAmazingMaps(completion: @escaping (NSMutableDictionary, Bool) ->()) {
        
        client?.files.download(path: DropB0ksKeys.mapsFilePath).response(completionHandler: { [weak self] response, error in
            let dropData: NSMutableDictionary = NSMutableDictionary()
            if let response = response {
                let fileContents = response.1
                do {
                    if fileContents.count != self?.defaults.integer(forKey: "json_editor_data_count") {
                        self?.defaults.set(fileContents.count, forKey: "json_editor_data_count")
                        AppDelegate.log("DropBoxParserFiles: when json new json_editor_data_count")
                    } else {
                        AppDelegate.log("DropBoxParserFiles: when json old json_editor_data_count")
                        completion(NSMutableDictionary(), true)
                        return
                    }
                    
                    let jsonFile = try JSONSerialization.jsonObject(with: fileContents, options: [])
                    if let itemsDictionary = jsonFile as? [String : Any] {
                        let editorItems = self?.parseMaps(json: itemsDictionary, mainKey: DropBoxCuteKeys_json.mapMainKey, mapImages: MapsContent.mapImages, mapDescription: MapsContent.mapDescription, mapTitle: MapsContent.mapTitle, isNew: MapsContent.isNew, fileKey: MapsContent.file)
                        dropData.setValue(editorItems, forKey: DropBoxCuteKeys_json.map)
                        completion(dropData, false)
                    } else {
                        completion(NSMutableDictionary(), false)
                    }
                } catch {
                    completion(NSMutableDictionary(), false)
                    AppDelegate.log(error.localizedDescription)
                }
            } else if let error = error {
                AppDelegate.log(error)
                completion(NSMutableDictionary(), false)
            }
        })
        .progress({ progress in
            AppDelegate.log("DropBoxParserFiles: Downloading: ", progress)
        })
    }
    
    private func featchAmazingAddons(completion: @escaping (NSMutableDictionary, Bool) ->()) {
        
        client?.files.download(path: DropB0ksKeys.addonsFilePath).response(completionHandler: { [weak self] response, error in
            let dropData: NSMutableDictionary = NSMutableDictionary()
            if let response = response {
                let fileContents = response.1
                do {
                    if fileContents.count != self?.defaults.integer(forKey: "json_categories_data_count") {
                        self?.defaults.set(fileContents.count, forKey: "json_categories_data_count")
                        AppDelegate.log("DropBoxParserFiles: when json new json_categories_data_count")
                    } else {
                        AppDelegate.log("DropBoxParserFiles: when json old json_categories_data_count")
                        completion(NSMutableDictionary(), true)
                        return
                    }
                    
                    let jsonFile = try JSONSerialization.jsonObject(with: fileContents, options: [])
                    if let itemsDictionary = jsonFile as? [String : Any] {
                        let categories = self?.parseAddons(json: itemsDictionary, mainKey: DropBoxCuteKeys_json.addonMainKey, addonImages: AddonsContent.addonImages, addonDescription: AddonsContent.addonDescription, addonTitle: AddonsContent.addonTitle, isNew: AddonsContent.isNew, fileKey: AddonsContent.file)
                        dropData.setValue(categories, forKey: DropBoxCuteKeys_json.addon)
                        completion(dropData, false)
                    } else {
                        completion(NSMutableDictionary(), false)
                    }
                } catch {
                    completion(NSMutableDictionary(), false)
                    AppDelegate.log(error.localizedDescription)
                }
            } else if let error = error {
                AppDelegate.log(error)
                completion(NSMutableDictionary(), false)
            }
        })
        .progress({ progress in
            AppDelegate.log("DropBoxParserFiles: Downloading: ", progress)
        })
    }
    
    private func featchAmazingSkins(completion: @escaping (NSMutableDictionary, Bool) ->()) {
        
        client?.files.download(path: DropB0ksKeys.skinsFilePath).response(completionHandler: { [weak self] response, error in
            let dropData: NSMutableDictionary = NSMutableDictionary()
            if let response = response {
                let fileContents = response.1
                do {
                    if fileContents.count != self?.defaults.integer(forKey: "json_data_count") {
                        self?.defaults.set(fileContents.count, forKey: "json_data_count")
                        AppDelegate.log("DropBoxParserFiles: when json new")
                    } else {
                        AppDelegate.log("DropBoxParserFiles: when json old")
                        completion(NSMutableDictionary(), true)
                        return
                    }
                    
                    let jsonFile = try JSONSerialization.jsonObject(with: fileContents, options: [])
                    if let itemsDictionary = jsonFile as? [String : Any] {
                        
                        let mods = self?.parseSkins(json: itemsDictionary, mainKey: DropBoxCuteKeys_json.skinMainKey, nameKey: SkinContent.skinName, imageKey: SkinContent.skinImage, sourceImageKey: SkinContent.skinSourceImage, isNew: SkinContent.isNew)
                        
                        dropData.setValue(mods, forKey: DropBoxCuteKeys_json.skin)
                        completion(dropData, false)
                    } else {
                        completion(NSMutableDictionary(), false)
                    }
                } catch {
                    completion(NSMutableDictionary(), false)
                    AppDelegate.log(error.localizedDescription)
                }
            } else if let error = error {
                AppDelegate.log(error)
                completion(NSMutableDictionary(), false)
            }
        })
        .progress({ progress in
            AppDelegate.log("DropBoxParserFiles: Downloading: ", progress)
        })
    }
    
    private func featchServers(completion: @escaping ([Server], Bool) ->()) {
        client?.files.download(path: DropB0ksKeys.serversFilePath).response(completionHandler: { [weak self] response, error in
            let dropData: NSMutableDictionary = NSMutableDictionary()
            if let response = response {
                let fileContents = response.1
                do {
                    if fileContents.count != self?.defaults.integer(forKey: "json_data_servers_count") {
                        self?.defaults.set(fileContents.count, forKey: "json_data_servers_count")
                        AppDelegate.log("DropBoxParserFiles: when json new")
                    } else {
                        AppDelegate.log("DropBoxParserFiles: when json old")
                        completion([], true)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    let servers = try decoder.decode([Server].self, from: fileContents)
                    completion(servers, true)
                } catch {
                    completion([], false)
                    AppDelegate.log(error.localizedDescription)
                }
            } else if let error = error {
                AppDelegate.log(error)
                completion([], false)
            }
        })
        .progress({ progress in
            AppDelegate.log("DropBoxParserFiles: Downloading: ", progress)
        })
    }
    
    private func featchSeeds(completion: @escaping (NSMutableDictionary, Bool) ->()) {
        client?.files.download(path: DropB0ksKeys.seedFilePath).response(completionHandler: { [weak self] response, error in
            let dropData: NSMutableDictionary = NSMutableDictionary()
            if let response = response {
                let fileContents = response.1
                do {
                    if fileContents.count != self?.defaults.integer(forKey: "json_data_seed_count") {
                        self?.defaults.set(fileContents.count, forKey: "json_data_seed_count")
                        AppDelegate.log("DropBoxParserFiles: when json new")
                    } else {
                        AppDelegate.log("DropBoxParserFiles: when json old")
                        completion([:], true)
                        return
                    }
                    
                    let jsonFile = try JSONSerialization.jsonObject(with: fileContents, options: [])
                    if let itemsDictionary = jsonFile as? [String : Any] {
                        
                    
                        let seeds = self?.parseSeeds(json: itemsDictionary, mainKey: DropBoxCuteKeys_json.seedMainKey, nameKey: SeedContent.seedName, imageKey: SeedContent.seedImage, descriptionKey: SeedContent.seedDescrip, seedKey: SeedContent.seed, isNew: SeedContent.isNew)
                        
                        dropData.setValue(seeds, forKey: DropBoxCuteKeys_json.seed)
                        completion(dropData, true)
                    } else {
                        completion(NSMutableDictionary(), false)
                    }
                    
                } catch {
                    completion([:], false)
                    AppDelegate.log(error.localizedDescription)
                }
            } else if let error = error {
                AppDelegate.log(error)
                completion([:], false)
            }
        })
        .progress({ progress in
            AppDelegate.log("DropBoxParserFiles: Downloading: ", progress)
        })
    }
    
    private func makeValidateAccessTokenDropBoxMamaMia(token: String,completion: @escaping(Bool)->()) {
        
        giveMeBloodyTokenBy(refresh_token: token) { [weak self] access_token in
            if let aToken = access_token {
                let client = DropboxClient(accessToken: aToken)
                AppDelegate.log("DropBoxParserFiles: token updated !!! \(aToken),\(String(describing: client))")
                self?.client = client
                
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func giveMePleaseReshreshToken(code: String, completion: @escaping (String?) -> ()) {
        
        let username = DropB0ksKeys.appkey
        let password = DropB0ksKeys.appSecret
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let parameters: Data = "code=\(code)&grant_type=authorization_code".data(using: .utf8)!
        let url = URL(string: DropB0ksKeys.apiLink)!
        var apiRequest = URLRequest(url: url)
        apiRequest.httpMethod = "POST"
        apiRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        apiRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        apiRequest.httpBody = parameters
        let task = URLSession.shared.dataTask(with: apiRequest) { data, response, error in
            guard let data = data, error == nil else {
                AppDelegate.log(error?.localizedDescription ?? "No data Available")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                completion(responseJSON[DropBoxCuteKeys_json.RefreshTokenSaveVarieble] as? String)
            } else {
                AppDelegate.log("DropBoxParserFiles: giveMePleaseReshreshToken error")
            }
        }
        task.resume()
    }
    
    private func giveMeBloodyTokenBy(refresh_token: String, completion: @escaping (String?) -> ()) {
        
        let loginString = String(format: "%@:%@", DropB0ksKeys.appkey, DropB0ksKeys.appSecret)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        let parameters: Data = "refresh_token=\(refresh_token)&grant_type=refresh_token".data(using: .utf8)!
        let url = URL(string: DropB0ksKeys.apiLink)!
        var apiRequest = URLRequest(url: url)
        apiRequest.httpMethod = "POST"
        apiRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        apiRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        apiRequest.httpBody = parameters
        let task = URLSession.shared.dataTask(with: apiRequest) { data, response, error in
            guard let data = data, error == nil else {
                AppDelegate.log(error?.localizedDescription ?? "No data Available")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                AppDelegate.log("@@ responseJSON - \(responseJSON)")
                
                completion(responseJSON["access_token"] as? String)
            } else {
                AppDelegate.log("DropBoxParserFiles: giveMeBloodyTokenBy error")
            }
        }
        task.resume()
    }
    
    public func getBloodyImageURLFromDropBox(img: String, completion: @escaping (String?) -> ()) {
        
        self.client?.files.getTemporaryLink(path: "/\(img)").response(completionHandler: { responce, error in
            if let link = responce {
                completion(link.link)
            } else {
                completion(nil)
            }
        })
    }
    
    public func getBloodyFileUrlFromDropbox(path: String, completion: @escaping (String?) -> ()){
        
        self.client?.files.getTemporaryLink(path: "/\(path)").response(completionHandler: { responce, error in
            if let link = responce {
                completion(link.link)
            } else {
                completion(nil)
            }
        })
    }
    
    public func downloadBloodyFileBy(urlPath: URL, completion: @escaping (String?, Error?) -> Void) {
        
        let fileURL =  FileManager.default.documentDirectory
        let urlForDestination = fileURL.appendingPathComponent(urlPath.lastPathComponent)
        if FileManager().fileExists(atPath: urlForDestination.path) {
            AppDelegate.log("DropBoxParserFiles: File already exists [\(urlForDestination.path)]")
            completion(urlForDestination.path, nil)
        } else {
            let configuration = URLSessionConfiguration.default
            let urlSession = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: urlPath)
            let httpMethod = "GET"
            request.httpMethod = httpMethod
            let urlDataTask = urlSession.dataTask(with: request, completionHandler: { data, response, error in
                if error != nil {
                    completion(urlForDestination.path, error)
                } else {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            if let data = data {
                                if let _ = try? data.write(to: urlForDestination, options: Data.WritingOptions.atomic) {
                                    completion(urlForDestination.path, error)
                                } else {
                                    completion(urlForDestination.path, error)
                                }
                            } else {
                                completion(urlForDestination.path, error)
                            }
                        }
                    }
                }
            })
            urlDataTask.resume()
        }
    }
    
    func downloadBloodyFileBy(urlPath: String, completion: @escaping (Data?) -> Void) {
        
        self.client?.files.download(path: "/\(urlPath)").response(completionHandler: { responce, error in
            if let responce = responce {
                completion(responce.1)
            } else {
                completion(nil)
            }
        })
    }
}


extension DropBoxParserFiles {
    
    private func featchAddonsEditor(completion: @escaping (NSMutableDictionary, Bool) ->()) {
        client?.files.download(path: AddonsEditorContent.jsonPath).response(completionHandler: { response, error in
            let dropData: NSMutableDictionary = NSMutableDictionary()
            if let response = response {
                let fileContents = response.1
                do {
                    if fileContents.count != self.defaults.integer(forKey: "addon_content_count") {
                        self.defaults.set(fileContents.count, forKey: "addon_content_count")
                        AppDelegate.log("DropBoxParserFiles: when json new")
                    } else {
                        AppDelegate.log("DropBoxParserFiles: when json old")
                        completion(NSMutableDictionary(), true)
                        return
                    }
                    
                    let jsonFile = try JSONSerialization.jsonObject(with: fileContents, options: [])
                    if let itemsDictionary = jsonFile as? [String : Any] {
                        let addons = self.parseAddonsEditor(json: itemsDictionary, mainKey: AddonsEditorContent.mainKey)
                        dropData.setValue(addons, forKey: AddonsEditorContent.addonTag)
                        completion(dropData, false)
                    } else {
                        completion(NSMutableDictionary(), false)
                    }
                } catch {
                    completion(NSMutableDictionary(), false)
                    AppDelegate.log(error.localizedDescription)
                }
            } else if let error {
                AppDelegate.log("DropBoxParserFiles: featchAddonsEditor @ error - \(error)")
                completion(NSMutableDictionary(), false)
            }
        })
    }
    
    
    private func parseAddonsEditor(json: [String : Any], mainKey: String) -> NSMutableDictionary {
        let result: NSMutableDictionary = NSMutableDictionary()
        var items: [AddonItem] = []
        if let addonsItems = json[mainKey] as? [String : Any] {
            for categoryName in addonsItems {
                if let content = addonsItems[categoryName.key.description] as? [[String : Any]] {
                    AppDelegate.log("DropBoxParserFiles: parseAddonsEditor @@ Content -\(content)")
                    
                    if categoryName.key != "NPC" {

                        for itemContent in content {
                            AppDelegate.log("DropBoxParserFiles: parseAddonsEditor items_templates @@ Content Item -\(itemContent)")
                            
                            if let displayName = itemContent["u8u"] as? String,
                               let displayImage = itemContent["kliu"] as? String,
                               let categoryImage = itemContent["bgyh324"] as? String,
                               let id = itemContent["vnfkn"] as? String,
                               let skin_variants = itemContent["jhuhuikjk"] as? [[String : Any]] {
                                
                                var skinVariants = [SkinVariants]()
                                
                                let id_string = UUID().uuidString
                                
                                for skin in skin_variants {
                                    if let displayImage = skin["kliu"] as? String,
                                       let name = skin["thy"]  as? String {
                                        let sv = SkinVariants(idshka: id_string, name: name, displayImage: displayImage)
                                        skinVariants.append(sv)
                                    }
                                }
                                AppDelegate.log("DropBoxParserFiles: SkinVariants - \(skinVariants)")
                                
                                let addonItem = AddonItem(idshka: id_string,
                                                          displayName: displayName,
                                                          displayImage: displayImage,
                                                          categoryImage: categoryImage,
                                                          skin_variants: skinVariants,
                                                          id: id,
                                                          type: id)
                                items.append(addonItem)
                            }
                        }
                    } else {
                        // Mobs (3d)
                        for itemContent in content {
                            AppDelegate.log("DropBoxParserFiles: parseAddonsEditor @@ Content Item -\(itemContent)")
                            
                            if let displayName = itemContent["vnfkn"] as? String,
                               let displayImage = itemContent["kliu"] as? String,
                               let categoryImage = itemContent["bgyh324"] as? String,
                               let id = itemContent["u8u"] as? String,
                               let health = itemContent["health"] as? Float,
                               let move_speed = itemContent["move_speed"] as? Float,
                               let type_family = itemContent["type_family"] as? String,
                               let skin_variants = itemContent["jhuhuikjk"] as? [[String : Any]],
                               let ranged_attack = itemContent["ranged_attack"] as? [String : Any] {
                                
                                let file = itemContent["bhju767"] as? String ?? ""
                                
                                var skinVariants = [SkinVariants]()
                                
                                let id_string = UUID().uuidString
                                
                                for skin in skin_variants {
                                    if let displayImage = skin["kliu"] as? String,
                                       let name = skin["thy"]  as? String {
                                        let sv = SkinVariants(idshka: id_string, name: name, displayImage: displayImage)
                                        skinVariants.append(sv)
                                    }
                                }
                                
                                var rangedAttack = [RangedAttack]()
                                
                                if let burst_shots = ranged_attack["burst_shots"] as? Double,
                                   let burst_interval = ranged_attack["burst_interval"] as? Double,
                                   let atk_speed = ranged_attack["atk_speed"] as? Double,
                                   let atk_types = ranged_attack["atk_types"] as? String,
                                   let atk_radius = ranged_attack["atk_radius"] as? Double,
                                   let enabled = ranged_attack["enabled"] as? Bool {
                                    
                                    let ra = RangedAttack(idshka: id_string,
                                                          enabled: enabled,
                                                          atk_speed: atk_speed,
                                                          atk_radius: atk_radius,
                                                          burst_shots: burst_shots,
                                                          burst_interval: burst_interval,
                                                          atk_types: atk_types)
                                    AppDelegate.log("DropBoxParserFiles: RangedAttack: \(ra)")
                                    
                                    rangedAttack.append(ra)
                                    
                                }
                                
                                AppDelegate.log("DropBoxParserFiles: \(skinVariants)")
                                
                                let addonItem = AddonItem(idshka: id_string,
                                                          displayName: displayName,
                                                          displayImage: displayImage,
                                                          categoryImage: categoryImage,
                                                          skin_variants: skinVariants,
                                                          id: id,
                                                          type: categoryName.key,
                                                          ranged_attack: rangedAttack,
                                                          health: health,
                                                          move_speed: move_speed,
                                                          type_family: type_family,
                                                          file: file)
                                items.append(addonItem)
                            }
                        }
                    }
                }
            }
            
            result.setValue(items, forKey: AddonsEditorContent.addonTag)
        }
        
        return result
    }
}
