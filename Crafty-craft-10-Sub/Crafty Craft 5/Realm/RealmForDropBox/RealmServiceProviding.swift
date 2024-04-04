//
//  Skin.swift
//  json
//
//  Created by Igor Kononov on 06.07.2023.
//

import Foundation
import RealmSwift

class RealmServiceProviding {
    static let shared = RealmServiceProviding()
    private let realmService = RealmServiceDropBox.shared
    
    private func getAllObjectsSession<T: Object>() -> [T] {
        return Array(realmService.readAll(T.self))
    }
    
    private func getAllObservable<T: Object>() -> Results<T> {
        realmService.readAll(T.self)
    }
    
    //MARK: Servers
    
    func addNew(servers: [ServerRealmSession]) {
        self.realmService.create(servers)
    }
    
    func getAllServers() -> [ServerRealmSession] {
        return getAllObjectsSession()
    }
    
    func getServersRealmObservable() -> Results<ServerRealmSession>{
        getAllObservable()
    }
    
    func loadServerImage(id: String, serverImageData: Data) {
        
        guard let serverRealm = getServerWithID(id: id) else { return }
        realmService.update(serverRealm, with: ["imageData": serverImageData])
    }
    
    private func getServerWithID(id: String) -> ServerRealmSession? {
        getAllServers().first(where: {$0.id == id}) ?? nil
    }
    
    //MARK: Seeds
    
    private func getAllSeedsSeesion() -> [SeedRealmSession] {
        return getAllObjectsSession()
    }
    
    func getSeedRealmObservable() -> Results<SeedRealmSession>{
        getAllObservable()
    }
    
    func getAllSeed() -> [SeedSession] {
        getAllSeedsSeesion().map { realmModel in
            SeedSession(id: realmModel.id, name: realmModel.name, seedImagePath: realmModel.seedImagePath, seedDescrip: realmModel.seedDescrip, isNew: realmModel.isNew, seed: realmModel.seed, imageData: realmModel.seedImageData)
        }
    }
    
    func addNew(seed: [SeedRealmSession]) {
        self.realmService.create(seed)
    }
    
    func getSeedWithID(id: String) -> SeedRealmSession? {
        getAllSeedsSeesion().first(where: {$0.id == id}) ?? nil
    }
    
    func loadSeedImage(id: String, seedImageData: Data) {
        guard let seedRealm = getSeedWithID(id: id) else { return }
        realmService.update(seedRealm, with: ["seedImageData": seedImageData])
    }
    
    
    //MARK: Skins

    private func getAllSkinsSession() -> [SkinsRealmSession] {
        return getAllObjectsSession()
    }
    
    func getSkinRealmObservable() -> Results<SkinsRealmSession>{
        getAllObservable()
    }
    
    func getAllSkins() -> [SkinsSession] {
        getAllSkinsSession().map { realmModel in
            SkinsSession(id: realmModel.id, name: realmModel.name, skinSourceImagePath: realmModel.skinSourceImagePath, skinImagePath: realmModel.skinImagePath, isNew: realmModel.isNew, isFavorite: realmModel.isFavorite, skinImageData: realmModel.skinImageData, filterCategory: realmModel.filterCategory)
        }
    }
    
    func addNew(skins: [SkinsRealmSession]) {
        self.realmService.create(skins)
    }
    
    private func getSkinWithID(id: String) -> SkinsRealmSession? {
        getAllSkinsSession().first(where: {$0.id == id}) ?? nil
    }

    func updateSkin(id: String, isFavorit: Bool) {
        
        guard let skinRealm = getSkinWithID(id: id) else { return }
        realmService.update(skinRealm, with: ["isFavorite": isFavorit])
    }
    
    func loadSkinImage(id: String, skinImageData: Data) {
        
        guard let skinRealm = getSkinWithID(id: id) else { return }
        realmService.update(skinRealm, with: ["skinImageData": skinImageData])
    }
    
    //MARK: Addons
    private func getAllMapsSession() -> [MapsRealmSession] {
        return getAllObjectsSession()
    }
    
    func getAllAddons() -> [AddonsSession] {
        getAllAddonsSession().map { realmModel in
            let addonImages = Array(realmModel.addonImages)
            return AddonsSession(id: realmModel.id, addonImages: addonImages, addonDescription: realmModel.addonDescription, addonTitle: realmModel.addonTitle, isNew: realmModel.isNew, isFavorite: realmModel.isFavorite, addonImageData: realmModel.addonImageData, filterCategory: realmModel.filterCategory, file: realmModel.file)
        }
    }
    
    func getAddonRealmObservable() -> Results<AddonsRealmSession>{
        getAllObservable()
    }
    
    func addNew(addons: [AddonsRealmSession]) {
        self.realmService.create(addons)
    }
    
    private func getAddonWithID(id: String) -> AddonsRealmSession? {
        getAllAddonsSession().first(where: {$0.id == id}) ?? nil
    }

    func updateAddon(id: String, isFavorit: Bool) {
        
        guard let addonRealm = getAddonWithID(id: id) else { return }
        realmService.update(addonRealm, with: ["isFavorite": isFavorit])
    }
    
    func loadAddonImage(id: String, addonImageData: Data) {
        
        guard let skinRealm = getAddonWithID(id: id) else { return }
        realmService.update(skinRealm, with: ["addonImageData": addonImageData])
    }
    
    //MARK: Maps
    
    private func getAllAddonsSession() -> [AddonsRealmSession] {
        return getAllObjectsSession()
    }
    
    func getAllMap() -> [MapsSession] {
        getAllMapsSession().map { realmModel in
            let mapImages = Array(realmModel.mapImages)
            return MapsSession(id: realmModel.id, mapImages: mapImages, mapDescription: realmModel.mapDescription, mapTitle: realmModel.mapTitle, isNew: realmModel.isNew, isFavorite: realmModel.isFavorite, mapImageData: realmModel.mapImageData, filterCategory: realmModel.filterCategory, file: realmModel.file)
        }
    }
    
    func getMapsRealmObservable() -> Results<MapsRealmSession>{
        getAllObservable()
    }
    
    func addNew(maps: [MapsRealmSession]) {
        self.realmService.create(maps)
    }
    
    private func getMapWithID(id: String) -> MapsRealmSession? {
        getAllMapsSession().first(where: {$0.id == id}) ?? nil
    }

    func updateMap(id: String, isFavorit: Bool) {
        
        guard let mapRealm = getMapWithID(id: id) else { return }
        realmService.update(mapRealm, with: ["isFavorite": isFavorit])
    }
    
    func loadMapImage(id: String, mapImageData: Data) {
        
        guard let skinRealm = getMapWithID(id: id) else { return }
        realmService.update(skinRealm, with: ["mapImageData": mapImageData])
    }
}

extension RealmServiceProviding {
    
    func getAllRealmSessionObjects<T: Object>(of type: T.Type) -> [T]? {
        let resultArray = Array(realmService.readAll(T.self) )

        return resultArray
    }
    
    func updateRealmObj<T: Object, V> (realmObj: T, keyToUpdate: String, newVal: V?) {
        realmService.update(realmObj, with: [keyToUpdate: newVal])
        
    }

}
