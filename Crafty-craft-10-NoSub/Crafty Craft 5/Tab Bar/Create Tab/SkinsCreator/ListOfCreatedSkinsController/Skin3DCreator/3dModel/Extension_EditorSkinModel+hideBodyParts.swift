

import Foundation

extension EditorSkinModel {
    
    func hideShowBodyPart(by type: StivesAnatomyPart) {
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
    
    
    
    func getBodyPartEditState(by type: StivesAnatomyPart) -> AnatomyPartEditState {
        let childNodes = controller.sceneView.scene?.rootNode.childNodes
        let bodySideNodes0 = childNodes?.filter({ bodyPartSide in
            bodyPartSide.name!.contains(type.rawValue) && !bodyPartSide.name!.contains("1")
        })
        
        let bodySideNodes1 = childNodes?.filter({ bodyPartSide in
            bodyPartSide.name!.contains(type.rawValue) && bodyPartSide.name!.contains("1")
        })
        
        var returnState: AnatomyPartEditState = .clothes
        
        //Both layeres are Hidden
        if bodySideNodes0![0].isHidden && bodySideNodes1![0].isHidden == true {
            returnState = AnatomyPartEditState.hidden

            //Only skinLayer is visible
        } else if bodySideNodes1![0].isHidden == true && bodySideNodes0![0].isHidden == false {
            returnState = AnatomyPartEditState.skin

            //both layers are visible
        } else if bodySideNodes1![0].isHidden == false && bodySideNodes0![0].isHidden == false {
            returnState = AnatomyPartEditState.clothes
        }
        
        return returnState
    }
    
    
}
