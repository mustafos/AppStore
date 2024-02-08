using System;
using System.Collections.Generic;
using UnityEngine;

namespace Voxel.Character
{
    public class CharacterElement : MonoBehaviour
    {
        public CharacterElementType ElementType => elementType;
        public List<CharacterElement> Children => children;
        public CharacterCubeState State => state;
        
        [SerializeField] private CharacterElementType elementType;
        [SerializeField] private CharacterCubeState state;
        [SerializeField] private List<CharacterElement> children = new List<CharacterElement>();
        [SerializeField] private Material _actionMaterial;

        private readonly Color _visibleColor = new Color(1f, 1f, 1f, 1f);
        private readonly Color _invisibleColor= new Color(0.71f, 0.98f, 0.63f, 0.36f);
        
        private MeshRenderer _meshRenderer;
        private GameObject _pinnedObject;
        
        public CharacterElement SetType(CharacterElementType newType)
        {
            elementType = newType;
            return this;
        }

        public CharacterElement SetMaterial(Material actionMaterial)
        {
            _actionMaterial = actionMaterial;
            return this;
        }

        public void AddChild(CharacterElement newChild)
        {
            if (!newChild)
            {
                Debug.LogWarningFormat("[{0}][AddChaild]newChaild cannot be null!", GetType().Name);
                return;
            }

            children.Add(newChild);
        }

        public void AddPinnedObject(GameObject pinnedObject)
        {
            _pinnedObject = pinnedObject;
        }

        public void ClearGameObject()
        {
            gameObject.layer = 7;

            switch (elementType)
            {
                case CharacterElementType.Cube:
                    ClearCube();
                    break;
                case CharacterElementType.Bone:
                    ClearTrash();
                    break;
            }

            foreach (var chaild in children)
            {
                chaild.ClearGameObject();
            }
        }

        public void ChangeState()
        {
            try
            {
                state = state == CharacterCubeState.Visible ? CharacterCubeState.Invisible : CharacterCubeState.Visible;

                switch (state)
                {
                    case CharacterCubeState.Visible:
                        _meshRenderer.material.color = _visibleColor;
                        _pinnedObject.SetActive(true);
                        break;
                    case CharacterCubeState.Invisible:
                        _meshRenderer.material.color = _invisibleColor;
                        _pinnedObject.SetActive(false);
                        break;
                }
            }
            catch (Exception e)
            {
                Debug.LogWarningFormat("[{0}][ChangeState]{1}", GetType().Name, e);   
            }
        }

        private void ClearCube()
        {
            var cubeDataHolder = gameObject.GetComponent<CubeDataHolder>();

            if (cubeDataHolder)
            {
                Destroy(cubeDataHolder);
            }

            _meshRenderer = gameObject.GetComponent<MeshRenderer>();

            if (_meshRenderer)
            {
                _meshRenderer.material = _actionMaterial;
            }

            var meshCollider = GetComponent<MeshCollider>();

            if (meshCollider)
            {
                Destroy(meshCollider);
            }
        }

        private void ClearTrash()
        {
            var childCount = gameObject.transform.childCount;
            var trashList = new List<GameObject>();
            
            for (var i = 0; i < childCount; i++)
            {
                var child = gameObject.transform.GetChild(i);

                if (!child.GetComponent<CharacterElement>())
                {
                    trashList.Add(child.gameObject);
                }
            }

            foreach (var trash in trashList)
            {
                Destroy(trash);
            }
        }
    }
}