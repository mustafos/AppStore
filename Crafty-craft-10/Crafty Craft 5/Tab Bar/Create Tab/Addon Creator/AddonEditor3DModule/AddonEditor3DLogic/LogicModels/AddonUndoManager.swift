//
//  AddonUndoManager.swift
//  Crafty Craft 5
//
//  Created by 1 on 05.09.2023.
//  Copyright © 2023 Noname Digital. All rights reserved.
//
import SceneKit
import Foundation

struct CubeChange {
    let touchedFace: CubeSideName
    let cubeIdentifier: String // some unique identifier for the cube
    let previousTexture: UIImage?
}


class AddonUndoManager: UndoManager {
    
    /// is used to store all faces that were touched during single drawing panGesture, stores  changes
    /// only with unic faces, cubesID could matches but not faces during one gesture
    private var tempCubeChanges = [CubeChange]()
    
    func resetTempCubeChanges() {
        tempCubeChanges.removeAll()
    }
    
    func completeUndoRegistration(for cubeChange: CubeChange, rootNode: SCNNode) {
        
        //Lets check if our array with touched faces contains cubeChange
        let isOld = tempCubeChanges.contains(where: { [weak self] localCubeChange in
            return cubeChange.cubeIdentifier == localCubeChange.cubeIdentifier && cubeChange.touchedFace == localCubeChange.touchedFace
        })

        //if cubeChange.face has been already edited during this gesture -> return
        guard isOld == false else {
            return
        }
        
        tempCubeChanges.append(cubeChange)
        
        let snapShotsArray = tempCubeChanges.map { cubeChange -> CubeChange in
            return CubeChange(touchedFace: cubeChange.touchedFace,
                              cubeIdentifier: cubeChange.cubeIdentifier,
                              previousTexture: cubeChange.previousTexture)
        }
        
        registerUndo(withTarget: self, handler: { [weak self] _ in
            guard let self = self else {
                print("guard self is wrong")
                return
            }
            self.undoTextureChange(for: snapShotsArray, rootNode: rootNode)
        })
        
    }
    
    func undoTextureChange(for cubeChanges: [CubeChange], rootNode: SCNNode) {
        // Find the cube by its identifier
        // Assume rootNode is your main SCNNode that contains all the cubes
        DispatchQueue.main.async {
            for cubeSnapshot in cubeChanges {
                guard let cubeNode = rootNode.childNode(withName: cubeSnapshot.cubeIdentifier, recursively: true) else {
                    print("error to create CubeNode in undo")
                    return
                }
                // Restore its texture
                let face = cubeSnapshot.touchedFace
                let previousTexture = cubeSnapshot.previousTexture
                
                cubeNode.geometry?.materials[face.rawValue].diffuse.contents = previousTexture
            }
            
        }
    }
    
}

