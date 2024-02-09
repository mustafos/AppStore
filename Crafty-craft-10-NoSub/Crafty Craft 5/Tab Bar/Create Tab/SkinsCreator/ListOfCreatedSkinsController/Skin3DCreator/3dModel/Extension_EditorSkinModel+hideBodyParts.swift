

import Foundation

extension EditorSkinModel {
    
    func hideShowBodyPart(by type: StivesBodyPart) {
        let childNodes = controller.sceneView.scene?.rootNode.childNodes

        let bodySideNodes0 = childNodes?.filter({ bodyPartSide in
            bodyPartSide.name!.contains(type.rawValue) && !bodyPartSide.name!.contains("1")
        })
        
        let bodySideNodes1 = childNodes?.filter({ bodyPartSide in
            bodyPartSide.name!.contains(type.rawValue) && bodyPartSide.name!.contains("1")
        })

        //Both layeres are Hidden
        if bodySideNodes0![0].isHidden && bodySideNodes1![0].isHidden == true {
            bodySideNodes0?.forEach({ node in
                node.isHidden = false
            })
            bodySideNodes1?.forEach({ node in
                node.isHidden = false
            })
            //Only skinLayer is visible
        } else if bodySideNodes1![0].isHidden == true && bodySideNodes0![0].isHidden == false {
            bodySideNodes0?.forEach({ node in
                node.isHidden = true
            })
            //both layers are visible
        } else if bodySideNodes1![0].isHidden == false && bodySideNodes0![0].isHidden == false {
            bodySideNodes1?.forEach({ node in
                node.isHidden = true
            })
        }
    }
    
    
    
    func getBodyPartEditState(by type: StivesBodyPart) -> BodyPartEditState {
        let childNodes = controller.sceneView.scene?.rootNode.childNodes
        let bodySideNodes0 = childNodes?.filter({ bodyPartSide in
            bodyPartSide.name!.contains(type.rawValue) && !bodyPartSide.name!.contains("1")
        })
        
        let bodySideNodes1 = childNodes?.filter({ bodyPartSide in
            bodyPartSide.name!.contains(type.rawValue) && bodyPartSide.name!.contains("1")
        })
        
        var returnState: BodyPartEditState = .clothes
        
        //Both layeres are Hidden
        if bodySideNodes0![0].isHidden && bodySideNodes1![0].isHidden == true {
            returnState = BodyPartEditState.hidden

            //Only skinLayer is visible
        } else if bodySideNodes1![0].isHidden == true && bodySideNodes0![0].isHidden == false {
            returnState = BodyPartEditState.skin

            //both layers are visible
        } else if bodySideNodes1![0].isHidden == false && bodySideNodes0![0].isHidden == false {
            returnState = BodyPartEditState.clothes
        }
        
        return returnState
    }
    
    
}
