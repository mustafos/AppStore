using System.Collections.Generic;
using System.Linq;
using Core.Managers;
using Meta.Inputs;
using UnityEngine;
using Voxel.McData;

namespace Voxel.Character
{
    public class CharacterConstructor : MonoBehaviour
    {
        public Transform RootBone => _rootObjectForBones.transform;
        public PreviewController PreviewController => previewObject.GetComponent<PreviewController>();
        [SerializeField]private Transform renderRoot;
        [SerializeField]private GameObject previewObject;
        [SerializeField]private Material material;
        [SerializeField]private Material actionMaterial;
        
        private const string MainTexture = "_MainTex";
        private const string SecondTexture = "_Texture2";

        private ResourceLoadingManager _resourceLoadingManager;
        private CubeMeshData _cubeMeshData = new CubeMeshData();
        private GeometryData _geometryData;
        private GameObject _rootObjectForBones;
        private float _normalSize = 370;
        private float _normalPreviewSize = 370;
        private float _shiftPosition = 26;
        private Material _cubeMaterial;
        private List<CharacterBone> _allCubes = new List<CharacterBone>(); 
        
        public void Initialize()
        {
            if (!ManagersHolder.Instance.GetManager(out _resourceLoadingManager))
            {
                Debug.LogWarningFormat("[{0}][Initialize]Can't get ResourceLoadingManager", GetType().Name);
                return;
            }

            if (!InitializeMaterial())
            {
                return;
            }
            
            if (!_resourceLoadingManager.GetDataFromJson(out var geometryData))
            {
                Debug.LogWarningFormat("[{0}][Initialize]Can't load GeometryData!", GetType().Name);
                return;
            }
            
            _geometryData = geometryData;
            CreateCharacter();
            MoveTo3DHolder();
            MoveToRenderRoot();
            InitializeSecondTexture();
        }

        private bool InitializeMaterial()
        {
            if (!_resourceLoadingManager.GetTexture(out var mainTexture))
            {
                Debug.LogWarningFormat("[{0}][Initialize]Can't load Texture!", GetType().Name);
                return false;
            }

            mainTexture.filterMode = FilterMode.Point;
            material.SetTexture(MainTexture, mainTexture);
            var secondTextures = new Texture2D(mainTexture.width, mainTexture.height);
            
            for (int x = 0; x < mainTexture.width; x++)
            {
                for (int y = 0; y < mainTexture.height; y++)
                {
                    secondTextures.SetPixel(x, y, new Color(0,0,0,0));
                }
            }

            secondTextures.filterMode = FilterMode.Point;
            material.SetTexture(SecondTexture, secondTextures);
            return true;
        }

        private void CreateCharacter()
        {
            var tmp = new List<Transform>();
            _rootObjectForBones = new GameObject("RootObjectForBones");
            var rootElement = _rootObjectForBones.AddComponent<CharacterElement>();
            rootElement.SetType(CharacterElementType.Root);
            _rootObjectForBones.layer = 6;
            var globalMirror = -1;

            foreach (var geometry in _geometryData.minecraft_geometry)
            {
                var geometryObject = new GameObject(geometry.description.identifier);
                geometryObject.transform.SetParent(_rootObjectForBones.transform);
                geometryObject.transform.localPosition = Vector3.zero;
                geometryObject.transform.localScale = Vector3.one;
                geometryObject.transform.localRotation = Quaternion.Euler(Vector3.zero);
                geometryObject.layer = 6;
                var geometryElement = geometryObject.AddComponent<CharacterElement>();
                geometryElement.SetType(CharacterElementType.Geometry);
                rootElement.AddChild(geometryElement);
                var bones = geometry.bones;

                for (var bIndex = 0; bIndex < bones.Length; bIndex++)
                {
                    var isChildren = false;
                    var boneData = bones[bIndex];
                    var boneObject = new GameObject(boneData.name);
                    boneObject.transform.position = Vector3.zero;
                    boneObject.transform.rotation = Quaternion.Euler(Vector3.zero);
                    boneObject.transform.localScale = Vector3.one;
                    boneObject.layer = 6;
                    var boneElement = boneObject.AddComponent<CharacterElement>();
                    boneElement.SetType(CharacterElementType.Bone);
                    tmp.Add(boneObject.transform);
                    Transform parent = null;
                    
                    if (!string.IsNullOrEmpty(boneData.parent))
                    {
                        parent = tmp.FirstOrDefault(element=>element.name.Equals(boneData.parent));
                        boneObject.transform.SetParent(parent);
                        var parentBoneElement = parent.gameObject.GetComponent<CharacterElement>();
                        parentBoneElement.AddChild(boneElement);
                        isChildren = true;
                    }
                    else
                    {
                        boneObject.transform.SetParent(geometryObject.transform);
                        geometryElement.AddChild(boneElement);
                    }
                    
                    var boneRotation = Vector3.zero;
                    
                    if (boneData.rotation != null && boneData.rotation.Length == 3)
                    {
                        boneRotation = new Vector3(boneData.rotation[0] * globalMirror, boneData.rotation[1] * globalMirror, boneData.rotation[2]);
                    }
                    
                    var bonePosition = new Vector3(boneData.pivot[0] * globalMirror, boneData.pivot[1], boneData.pivot[2]);
                    
                    if (isChildren)
                    {
                        var parentBoneData = bones.FirstOrDefault(element=>element.name.Equals(boneData.parent));
                        var boneParentPosition = new Vector3(parentBoneData.pivot[0] * globalMirror, parentBoneData.pivot[1], parentBoneData.pivot[2]);
                        boneObject.transform.localPosition = bonePosition - boneParentPosition;
                    }
                    else
                    {
                        boneObject.transform.localPosition = bonePosition;
                    }
                    
                    boneObject.transform.localRotation = Quaternion.Euler(boneRotation);

                    if (boneData.mirror)
                    {
                        var mirror = -1;
                        var localPosition = boneObject.transform.localPosition;
                        boneObject.transform.localPosition = new Vector3(localPosition.x * mirror, localPosition.y, localPosition.z);
                        boneObject.transform.localRotation = Quaternion.Euler(boneRotation.x, boneRotation.y * globalMirror, boneRotation.z * globalMirror);
                    }
                    
                    var cubes = boneData.cubes;

                    if (cubes == null)
                    {
                        continue;
                    }

                    for (var cIndex = 0; cIndex < cubes.Length; cIndex++)
                    {
                        var cubeData = cubes[cIndex];
                        var cubeName = $"{boneData.name}_Cube{cIndex}";
                        GameObject cubeObject = new GameObject(cubeName);
                        cubeObject.transform.SetParent(boneObject.transform);
                        cubeObject.layer = 6;
                        var origin = cubeData.origin;
                        var size = cubeData.size;

                        if (0 - Mathf.Abs(size[0]) >= 0 && 0 - Mathf.Abs(size[1]) >= 0 && 0 - Mathf.Abs(size[2]) >= 0)
                        {
                            cubeObject.transform.localPosition = Vector3.zero;
                            continue;
                        }

                        var bonePivot = new Vector3(boneData.pivot[0] * globalMirror, boneData.pivot[1], boneData.pivot[2]);
                        GameObject pivotObject = null;
                        var pivotPosition = Vector3.zero;
                        Debug.LogFormat("Bone name: {0}",boneObject.name);

                        if (cubeData.pivot != null && cubeData.pivot.Length == 3)
                        {
                            pivotObject = new GameObject($"{boneData.name}_Cube{cIndex}_Pivot");
                            pivotObject.transform.SetParent(boneObject.transform);
                            pivotPosition = new Vector3(cubeData.pivot[0] * globalMirror, cubeData.pivot[1], cubeData.pivot[2]);
                            pivotObject.transform.localPosition = pivotPosition - bonePivot;
                            var  pivotElement = pivotObject.AddComponent<CharacterElement>();
                            pivotElement.SetType(CharacterElementType.Pivot);
                        }

                        var description = geometry.description;
                        var textureSize = new Vector2Int(description.texture_width, description.texture_height);
                        AddPrimitive(ref cubeObject, boneObject.transform, pivotObject, cubeData, textureSize, cubeName, boneElement);
                        var cubeZero = new Vector3((origin[0] + size[0] / 2) * globalMirror, origin[1] + size[1] / 2, origin[2] + size[2] / 2);

                        if (pivotObject == null)
                        {
                            cubeObject.transform.localPosition = cubeZero - bonePivot;
                        }
                        else
                        {
                            cubeObject.transform.localPosition = cubeZero - pivotPosition;
                        }

                        var cubeRotation = Vector3.zero;

                        if (cubeData.rotation != null && cubeData.rotation.Length == 3)
                        {
                            cubeRotation = new Vector3(cubeData.rotation[0] * globalMirror, cubeData.rotation[1] * globalMirror, cubeData.rotation[2]);
                        }

                        if (pivotObject == null)
                        {
                            cubeObject.transform.localRotation = Quaternion.Euler(cubeRotation);
                        }
                        else
                        {
                            pivotObject.transform.localRotation = Quaternion.Euler(cubeRotation);
                        }
                    }
                }
            }

            CloneGeometry();
        }

        private void AddPrimitive(ref GameObject cubeObject, Transform boneTransform, GameObject pivotObject, CubeData cubeData, Vector2Int textureSize, string cubeName, CharacterElement bpneElement)
        {
            Destroy(cubeObject);
            cubeObject = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cubeObject.name = cubeName;
            cubeObject.transform.SetParent(pivotObject == null ? boneTransform : pivotObject.transform);
            cubeObject.layer = 6;
            var scale = 1f;

            if (cubeData.inflate > 0)
            {
                scale -= cubeData.inflate;
            }

            var size = new Vector3(cubeData.size[0] * scale, cubeData.size[1] * scale, cubeData.size[2] * scale);
            cubeObject.transform.localScale = size;
            cubeObject.transform.localPosition = Vector3.zero;
            List<List<Vector2>> uvData = cubeData.uv != null 
                ? _cubeMeshData.GetUVForGeometry(cubeData, textureSize) 
                : _cubeMeshData.GetUV6(cubeData.uv6, textureSize, true);
            var cubeDataHolder = cubeObject.AddComponent<CubeDataHolder>();
            var renderer = cubeObject.GetComponent<MeshRenderer>();
            renderer.material = material;
            var mesh = cubeObject.GetComponent<MeshFilter>().mesh;
            var newUV = GetUV(uvData);
            var boxCollider = cubeObject.GetComponent<BoxCollider>();

            if (boxCollider)
            {
                Destroy(boxCollider);
            }

            var meshCollider = cubeObject.AddComponent<MeshCollider>();
            mesh.uv = newUV;
            mesh.RecalculateNormals();
            mesh.RecalculateBounds();
            meshCollider.sharedMesh = mesh;
            cubeDataHolder.SetUV(cubeData.uv != null
                ? _cubeMeshData.GetUVForGeometry(cubeData, textureSize) 
                : _cubeMeshData.GetUV6(cubeData.uv6, textureSize, false), textureSize);
            _allCubes.Add(new CharacterBone(cubeObject, size));

            if (_cubeMaterial == null)
            {
                _cubeMaterial = renderer.material;
            }

            var cubeElement = cubeObject.AddComponent<CharacterElement>();
            cubeElement.SetType(CharacterElementType.Cube).SetMaterial(actionMaterial);
            bpneElement.AddChild(cubeElement);
        }

        private Vector2[] GetUV(List<List<Vector2>> value)
        {
            var returnValue = new List<Vector2>();

            foreach (var element in value)
            {
                returnValue.AddRange(element);
            }

            return returnValue.ToArray();
        }
        
        private void CloneGeometry()
        {
            var rootCharacterElement = _rootObjectForBones.GetComponent<CharacterElement>();
            var rootGeometry = rootCharacterElement.Children[0].gameObject;
            var rootGeometryCopy = Instantiate(rootGeometry, previewObject.transform, false);
            var rootGeometryCopyCharacterElement = rootGeometryCopy.GetComponent<CharacterElement>();
            var previewCharacterElement = previewObject.GetComponent<CharacterElement>();
            previewCharacterElement.AddChild(rootGeometryCopyCharacterElement);
            previewCharacterElement.ClearGameObject();
            PinObjects();
        }

        private void PinObjects()
        {
            var previewCharacterElement = previewObject.GetComponent<CharacterElement>();

            if (!previewCharacterElement)
            {
                Debug.LogWarningFormat("[{0}][PinObjects]_3DPreview does not contain a component CharacterElement!", GetType().Name);
                return;
            }

            var previewObjectList = GetAllObjects(previewCharacterElement, new List<CharacterElement>());
            var rootCharacterElement = _rootObjectForBones.GetComponent<CharacterElement>();

            if (!previewCharacterElement)
            {
                Debug.LogWarningFormat("[{0}][PinObjects]_rootObjectForBones does not contain a component CharacterElement!", GetType().Name);
                return;
            }

            var rootObjectList = GetAllObjects(rootCharacterElement, new List<CharacterElement>());
            Debug.LogFormat("[{0}][PinObjects]previewObjectList.Count: {1}; rootObjectList.Count: {2}", GetType().Name, previewObjectList.Count, rootObjectList.Count);

            for (var i = 0; i < previewObjectList.Count; i++)
            {
                previewObjectList[i].AddPinnedObject(rootObjectList[i].gameObject);
            }
        }

        private List<CharacterElement> GetAllObjects(CharacterElement rootObject, List<CharacterElement> returnData)
        {
            returnData.Add(rootObject);
            
            foreach (var child in rootObject.Children)
            {
                returnData = GetAllObjects(child, returnData);
            }

            return returnData;
        }

        private void MoveTo3DHolder()
        {
            GetMinMaxCoordinates(out var minX, out var maxX, out var minY, out var maxY, out var minZ, out var maxZ);
            var boneShiftY = (minY + maxY) / 2;
            var boneShiftX = (minX + maxX) / 2;
            var boneShiftZ = (minZ + maxZ) / 2;
            var children = previewObject.transform.childCount;

            for (var i = 0; i < children; ++i)
            {
                var position = previewObject.transform.GetChild(i).localPosition;
                previewObject.transform.GetChild(i).localPosition = new Vector3(position.x - boneShiftX, position.y - boneShiftY, position.z - boneShiftZ);
            }

            var characterXSize = Mathf.Abs(minX) + Mathf.Abs(maxX);
            var characterYSize = Mathf.Abs(minY) + Mathf.Abs(maxY);
            var characterZSize = Mathf.Abs(minZ) + Mathf.Abs(maxZ);
            var characterSize = characterXSize;

            if (characterYSize > characterSize)
            {
                characterSize = characterYSize;
            }

            if(characterZSize > characterSize )
            {
                characterSize = characterZSize;
            }

            var sizeMultiplier = _normalPreviewSize/characterSize;
            previewObject.transform.localScale = new Vector3(sizeMultiplier, sizeMultiplier, sizeMultiplier);
            previewObject.transform.localPosition = Vector3.zero;
        }
       
        private void MoveToRenderRoot()
        {
            GetMinMaxCoordinates(out var minX, out var maxX, out var minY, out var maxY, out var minZ, out var maxZ);
            var boneShiftY = (minY + maxY) / 2;
            var children = transform.childCount;
            
            for (var i = 0; i < children; ++i)
            {
                var position = transform.GetChild(i).localPosition;
                transform.GetChild(i).localPosition = new Vector3(position.x, position.y - boneShiftY, position.z);
            }

            _rootObjectForBones.transform.SetParent(transform);
            var characterXSize = Mathf.Abs(minX) + Mathf.Abs(maxX);
            var characterYSize = Mathf.Abs(minY) + Mathf.Abs(maxY);
            var characterZSize = Mathf.Abs(minZ) + Mathf.Abs(maxZ);
            var characterSize = characterXSize;

            if (characterYSize > characterSize)
            {
                characterSize = characterYSize;
            }

            if(characterZSize > characterSize )
            {
                characterSize = characterZSize;
            }

            var sizeMultiplier = _normalSize/characterSize;
            _rootObjectForBones.transform.localScale = new Vector3(sizeMultiplier, sizeMultiplier, sizeMultiplier);
            _rootObjectForBones.transform.localPosition = new Vector3(0, -characterSize*sizeMultiplier/2, 0);
            transform.SetParent(renderRoot);
            var yPosition = _normalSize / 2 - _shiftPosition;
            transform.localPosition = new Vector3(0, yPosition, 0);
        }

        private void GetMinMaxCoordinates(out float minX, out float maxX, out float minY, out float maxY, out float minZ, out float maxZ)
        {
            minX = 0;
            maxX = 0;
            minY = 0;
            maxY = 0;
            minZ = 0;
            maxZ = 0;
            
            foreach (var bone in _allCubes)
            {
                var boneGameObject = bone.BoneGameObject;
                var boneSize = bone.Size;
                var currentMinX = boneGameObject.transform.position.x - boneSize[0] / 2;
                var currentMaxX = boneGameObject.transform.position.x + boneSize[0] / 2;
                var currentMinY = boneGameObject.transform.position.y - boneSize[1] / 2;
                var currentMaxY = boneGameObject.transform.position.y + boneSize[1] / 2;
                var currentMinZ = boneGameObject.transform.position.z - boneSize[2] / 2;
                var currentMaxZ = boneGameObject.transform.position.z + boneSize[2] / 2;

                if (minX > currentMinX)
                {
                    minX = currentMinX;
                }

                if (maxX < currentMaxX)
                {
                    maxX = currentMaxX;
                }

                if (minY > currentMinY)
                {
                    minY = currentMinY;
                }

                if (maxY < currentMaxY)
                {
                    maxY = currentMaxY;
                }

                if (minZ > currentMinZ)
                {
                    minZ = currentMinZ;
                }

                if (maxZ < currentMaxZ)
                {
                    maxZ = currentMaxZ;
                }
            }
        }

        private void InitializeSecondTexture()
        {
            var texture = _cubeMaterial.GetTexture(SecondTexture) as Texture2D;
            texture.SetPixel(0,0,new Color(0,0,0,0));
            texture.Apply();
            _resourceLoadingManager.SaveSecondTexture(texture);
        }
    }
}