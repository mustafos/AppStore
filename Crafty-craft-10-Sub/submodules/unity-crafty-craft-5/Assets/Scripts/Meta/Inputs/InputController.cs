using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Core.Managers;
using Cysharp.Threading.Tasks;
using DG.Tweening;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Serialization;
using UnityEngine.UI;
using Voxel.Character;

namespace Meta.Inputs
{
    public class InputController : MonoBehaviour
    {
        public int ChangeCount => _undoDatas?.Count ?? 0;

        [SerializeField] private TextMeshProUGUI testRotateValue;
        [SerializeField] private TextMeshProUGUI testMoveValue;
        [SerializeField] private TextMeshProUGUI testZoomValue;
        [SerializeField] private TouchDetection touchDetection;
        [SerializeField] private EventSystem eventSystem;
        [SerializeField] private Camera camera;
        [SerializeField] private Camera screenShotCamera;
        [SerializeField] private Camera uiCamera;
        [SerializeField] private Transform characterController;
        [SerializeField] private Transform camerasHolder;
        
        private const string MainTexture = "_MainTex";
        private const string SecondTexture = "_Texture2";
        
        private ResourceLoadingManager _resourceLoadingManager;
        private Action<Color> _pickColorCallback;
        private Action _pickFinishCallback;
        private int _pointSize;
        private Color _color;
        private List<Color> _colorsList;
        [SerializeField]private InputsType _state;
        private InputsType _lastState;
        private readonly float _rotationSpeed = 0.5f;
        private readonly float _zoomSpeed = 0.2f;
        private readonly float _moveSpeed = 0.2f;
        private readonly float _zoomShift = 0.9f;
        
        private RaycastHit _hit;
        private List<UndoData> _undoDatas = new List<UndoData>();
        private bool _isPainting;
        private Vector2 _touchPosition;
        private bool _saveStart;
        private bool _isAction;
        private bool _isGlobalMove;
        private bool _isMove;
        private Touch _oneFingerTouch;
        private Transform _rootBoneTransform;
        private Vector3 _rootBoneStartScale;
        private readonly float _animationTime = 0.5f;
        private bool _isAnimated;
        private Vector3 camerasHolderStartPosition;
        private bool _inputBlock;
        private bool _isColorPicked;
        private PreviewController _previewController;
        
        public void Initialize()
        {
            if (!ManagersHolder.Instance.GetManager(out _resourceLoadingManager))
            {
                Debug.LogWarningFormat("[{0}][Initialize]Can't get ResourceLoadingManager", GetType().Name);
                return;
            }

            _lastState = InputsType.Default;
            var controller = characterController.gameObject.GetComponent<CharacterConstructor>();
            _rootBoneTransform = controller.RootBone;
            var localScale = _rootBoneTransform.localScale;
            _rootBoneStartScale = new Vector3(localScale.x, localScale.y, localScale.z);
            touchDetection.Initialize(eventSystem);
            touchDetection.OnMoveTouch += OnTouchMoveLogic;
            touchDetection.OnZoomTouch += OnTouchZoomLogic;
            touchDetection.OnRotateTouch += OnTouchRotateLogic;
            touchDetection.OnDoubleTouch += OnDoubleTouchLogic;
            touchDetection.MoveTouchesDisable();
            _previewController = controller.PreviewController;
            _previewController.Initialize(touchDetection);
            var holderPosition = camerasHolder.position;
            camerasHolderStartPosition = new Vector3(holderPosition.x, holderPosition.y, holderPosition.z);
        }

        public void Save()
        {
            characterController.localRotation = Quaternion.Euler(Vector3.zero);
            _rootBoneTransform.localRotation = Quaternion.Euler(Vector3.zero);
            camerasHolder.position = camerasHolderStartPosition;
            _rootBoneTransform.localScale = _rootBoneStartScale;
            SaveScreenShot();
        }

        public void Block(bool value)
        {
            if (value)
            {
                _lastState = _state;
                _state = InputsType.Default;
                Debug.LogFormat("[{0}][Block]_state: {1}", GetType().Name, _state);
            }
            else
            {
                _state = _lastState;
                //_lastState = InputsType.Default;
            }

            _inputBlock = value;
            touchDetection.SetInputBlock(value);
        }

        public void PalletSelect()
        {
            _state = InputsType.Default;
        }

        public void PenSelect()
        {
            _state = InputsType.Pen;
        }

        public void Undo()
        {
            if (_undoDatas.Count == 0)
            {
                return;
            }

            var data = _undoDatas[^1];
            var texture  = data.renderer.material.GetTexture(SecondTexture) as Texture2D;

            foreach (var textureData in data.texturesData)
            {
                texture.SetPixel((int)textureData.textureCoordinates.x, (int)textureData.textureCoordinates.y, textureData.color);
            }
            
            texture.Apply();
            _undoDatas.RemoveAt(_undoDatas.Count - 1);
        }

        public void StartPickColor(Action<Color> colorCallback, Action finishCallback)
        {
            _pickColorCallback = colorCallback;
            _pickFinishCallback = finishCallback;
            _lastState = _state;
            _state = InputsType.PickColor;
        }

        public void SetPenPointSize(int size)
        {
            _pointSize = size;
            _state = InputsType.Pen;
        }

        public void SetEracerPointSize(int size)
        {
            _pointSize = size;
            _state = InputsType.Eracer;
        }

        public void SetColor(Color color)
        {
            if (_lastState != InputsType.Default && _lastState == InputsType.PickColor)
            {
                _state = _lastState;
                //_lastState = InputsType.Default;
                Debug.LogFormat("[{0}][SetColor]_state: {1}", GetType().Name, _state);
            }

            _color = color;
        }

        public void RandomColor(int size)
        {
            _pointSize = size;
            _state = InputsType.RandomColor;
            Debug.LogFormat("[{0}][RandomColor]_state: {1}", GetType().Name, _state);
        }

        public void FillColor()
        {
            _state = InputsType.FillColor;
            Debug.LogFormat("[{0}][FillColor]_state: {1}", GetType().Name, _state);
        }

        public void SetMove(bool value)
        {
            _isGlobalMove = value;
            
            if (value)
            {
                touchDetection.MoveTouchesSetActive();
                return;
            }
            
            touchDetection.MoveTouchesDisable();
        }

        public void SaveTexture()
        {
            if (_undoDatas == null || _undoDatas.Count == 0)
            {
                return;
            }

            var renderer = _undoDatas[0].renderer;

            var mainTexture = renderer.material.GetTexture(MainTexture) as Texture2D;
            var secondTexture = renderer.material.GetTexture(SecondTexture) as Texture2D;

            for (var x = 0; x < mainTexture.width; x++)
            {
                for (var y = 0; y < mainTexture.height; y++)
                {
                    var pixel = secondTexture.GetPixel(x, y);

                    if (pixel.a <= 0)
                    {
                        continue;
                    }
                    
                    mainTexture.SetPixel(x, y, pixel);
                }
            }
            
            mainTexture.Apply();
            _resourceLoadingManager.SaveTexture(mainTexture);
        }

        private void SaveScreenShot() 
        { 
            var activeRenderTexture = RenderTexture.active; 
            RenderTexture.active = screenShotCamera.targetTexture;   
            screenShotCamera.Render();
            var targetTexture = screenShotCamera.targetTexture;
            var screenShotImage = new Texture2D(targetTexture.width, targetTexture.height);
            screenShotImage.ReadPixels(new Rect(0, 0, targetTexture.width, targetTexture.height), 0, 0);
            screenShotImage.Apply();
            RenderTexture.active = activeRenderTexture;
            _resourceLoadingManager.SaveScreenShot(screenShotImage);
        }    

        private async void OnDoubleTouchLogic()
        {
            Debug.Log("OnDoubleTouchLogic");
            await ResetBone();;
        }

        private void OnTouchRotateLogic(Vector2 shift)
        {
            testRotateValue.text = $"x: {shift.x}; y: {shift.y}";
            var rotationX = Quaternion.Euler(0, shift.x * _rotationSpeed * -1, 0);
            var rotationY = Quaternion.Euler(shift.y * _rotationSpeed, 0, 0);
            characterController.rotation *= rotationY;
            _rootBoneTransform.rotation *= rotationX;
        }

        private void OnTouchZoomLogic(float direction)
        {
            testZoomValue.text = $"direction: {direction}";
            var cameraPosition = camerasHolder.position;
            cameraPosition.z += direction*_zoomShift;
            camerasHolder.position = Vector3.Lerp(camerasHolder.position, cameraPosition, _zoomSpeed);
        }

        private void OnTouchMoveLogic(Vector2 shift)
        {
            testMoveValue.text = $"x: {shift.x}; y: {shift.y}";
            var cameraPosition = camerasHolder.position;

            var multiplier = cameraPosition.z / 100;
            if (multiplier == 0)
            {
                multiplier = 1;
            }
            
            cameraPosition.x += shift.x * -1 * Mathf.Abs(multiplier);
            cameraPosition.y += shift.y * -1 * Mathf.Abs(multiplier);
            camerasHolder.position = Vector3.Lerp(camerasHolder.position, cameraPosition, _moveSpeed);
        }

        private async void Update()
        {
            if (_isGlobalMove)
            {
                return;
            }

            if (Input.touchCount == 0)
            {
                return;
            }

            _oneFingerTouch = Input.GetTouch(0);
            
            if (!_isAction)
            {
                _isAction = true;
                if (RayCast())
                {
                    touchDetection.SetPaintingStatus(true);
                }
                else
                {
                    _isMove = true;
                }
            }

            if (_oneFingerTouch.phase is TouchPhase.Ended or TouchPhase.Canceled)
            {
                if (_state == InputsType.PickColor)
                {
                    ClearColorPicker();
                }

                touchDetection.SetPaintingStatus(false);
                _isAction = false; 
                _isPainting = false;
                _saveStart = false;
                _isMove = false;
            }

            if (IsBlockPaining())
            {
                return;
            }

            if (!RayCast())
            {
                return;
            }

            if (_oneFingerTouch.phase == TouchPhase.Began || _oneFingerTouch.phase == TouchPhase.Moved)
            {
                switch (_state)
                {
                    case InputsType.Pen:
                        PaintingLogic();
                        break;
                    case InputsType.PickColor:
                        PickerLogic();
                        break;
                    case InputsType.RandomColor:
                        RandomColorLogic();
                        break;
                    case InputsType.Eracer:
                        EracerLogic();
                        break;
                }
            }

            if (IsBlockColorFilling())
            {
                return;
            }
                
            DrawLogic();
        }

        private void ClearColorPicker()
        {
            if (!_isColorPicked)
            {
                return;
            }

            _pickFinishCallback?.Invoke();
            _state = _lastState;
            Debug.LogFormat("[{0}][Update]_state: {1}", GetType().Name, _state);
            //_lastState = InputsType.Default;
            _pickColorCallback = null;
            _pickFinishCallback = null;
            _isColorPicked = false;
        }

        private bool IsBlockPaining()
        {
            if (eventSystem.currentSelectedGameObject != null)
            {
                return true;
            }

            if (_isAnimated)
            {
                return true;
            }

            if (_state == InputsType.Default)
            {
                return true;
            }

            if (_isMove)
            {
                return true;
            }
            
            return false;
        }

        private bool IsBlockColorFilling()
        {
            if (_oneFingerTouch.phase != TouchPhase.Began)
            {
                return true;
            }

            if (_state != InputsType.FillColor)
            {
                return true;
            }

            return false;
        }

        private async Task ResetBone()
        {
            _isAnimated = true;
            var animationType = Ease.OutCubic;
            characterController.DORotate(Vector3.zero, _animationTime).SetEase(animationType);
            _rootBoneTransform.DORotate(Vector3.zero, _animationTime).SetEase(animationType);
            camerasHolder.DOMove(camerasHolderStartPosition, _animationTime).SetEase(animationType);
            await _rootBoneTransform.DOScale(_rootBoneStartScale, _animationTime).SetEase(animationType).ToUniTask();
            _isAnimated = false;
        }
        
        private void PaintingLogic()
        {
            if (!_isPainting)
            {
                _touchPosition = _oneFingerTouch.position;
                DrawLogic();
            }

            if (_touchPosition.Equals(_oneFingerTouch.position))
            {
                return;
            }

            _touchPosition = _oneFingerTouch.position;
            DrawLogic();
        }
       
        private bool RayCast()
        {
            if (eventSystem.currentSelectedGameObject != null)
            {
                return false;
            }

            if (_oneFingerTouch.phase is TouchPhase.Ended or TouchPhase.Canceled)
            {
                return false;
            }
            
            var position = new Vector2(_oneFingerTouch.position.x, _oneFingerTouch.position.y);
            var ray = camera.ScreenPointToRay(position);
            return Physics.Raycast(ray, out _hit);
        }

        private void DrawLogic()
        {
            if (!_isPainting)
            {
                _isPainting = true;
            }

            var renderer = _hit.transform.GetComponent<Renderer>();

            if (renderer == null || renderer.sharedMaterial == null || renderer.sharedMaterial.mainTexture == null)
            {
                return;
            }

            var secondTexture = renderer.material.GetTexture(SecondTexture) as Texture2D;
            var pixelUV = _hit.textureCoord;
            List<Vector2> pixelesCoordinate = null;
            var cubeDataHolder = _hit.transform.GetComponent<CubeDataHolder>();

            pixelesCoordinate = _state switch
            {
                InputsType.Pen => GetPenPixels(pixelUV, secondTexture.width, secondTexture.height, cubeDataHolder),
                InputsType.RandomColor => GetPenPixels(pixelUV, secondTexture.width, secondTexture.height, cubeDataHolder),
                InputsType.Eracer => GetPenPixels(pixelUV, secondTexture.width, secondTexture.height, cubeDataHolder),
                InputsType.FillColor => GetFillPixels(pixelUV, secondTexture.width, secondTexture.height, cubeDataHolder),
                _ => pixelesCoordinate
            };

            if (pixelesCoordinate == null || pixelesCoordinate.Count == 0)
            {
                return;
            }

            var textureData = new List<UndoDataTextureData>();

            foreach (var coordinate in pixelesCoordinate)
            {
                var fixedCoordinate = new Vector2Int(Convert.ToInt32(coordinate.x), Convert.ToInt32(coordinate.y));
                textureData.Add(new UndoDataTextureData()            
                {
                    color = secondTexture.GetPixel(fixedCoordinate.x, fixedCoordinate.y),
                    textureCoordinates = new Vector2(fixedCoordinate.x, fixedCoordinate.y)
                });
            }

            SaveLogic(renderer, textureData);

            for (var index = 0; index < pixelesCoordinate.Count; index++)
            {
                var coordinate = pixelesCoordinate[index];
                var fixedCoordinate = new Vector2Int(Convert.ToInt32(coordinate.x), Convert.ToInt32(coordinate.y));

                if (_state == InputsType.RandomColor)
                {
                    secondTexture.SetPixel(fixedCoordinate.x, fixedCoordinate.y, _colorsList[index]);
                    continue;
                }

                secondTexture.SetPixel(fixedCoordinate.x, fixedCoordinate.y, _color);
            }

            secondTexture.Apply();
        }

        private void SaveLogic(Renderer renderer, List<UndoDataTextureData> texturesData)
        {
            if (!_saveStart)
            {
                _undoDatas.Add(new UndoData()
                {
                    renderer = renderer,
                    texturesData = texturesData
                });
                _saveStart = true;
                return;
            }

            foreach (var textureData in texturesData.Where(textureData => _undoDatas[^1].texturesData.FirstOrDefault(element =>
                element.textureCoordinates.Equals(textureData.textureCoordinates)) == null))
            {
                _undoDatas[^1].texturesData.Add(textureData);
            }
        }

        private List<Vector2> GetPenPixels(Vector2 targetPixel, int textureWidth, int textureHeight, CubeDataHolder cubeDataHolder)
        {
            Debug.LogFormat("[{0}][GetPenPixels]Screen.width: {1}; Screen.height: {2}", GetType().Name, Screen.width, Screen.height);
            var returnValue = new List<Vector2>();
            Debug.LogFormat("[{0}][GetPenPixels]targetPixel: {1}", GetType().Name, targetPixel);
            var rectSize = cubeDataHolder.GetRectSize(
                new Vector2Int(
                    (int)Math.Round(targetPixel.x*textureWidth), 
                    (int)Math.Round(targetPixel.y*textureHeight)));
            Debug.LogFormat("[{0}][GetPenPixels]rectSize: {1}", GetType().Name, rectSize);
            var multiplier = 0.09f;
            var currentPixel = new Vector2Int(
                (int)Math.Round(targetPixel.x*textureWidth - rectSize.x * multiplier), 
                (int)Math.Round(targetPixel.y*textureHeight - rectSize.y * multiplier));
            Debug.LogFormat("[{0}][GetPenPixels]currentPixel: {1}", GetType().Name, currentPixel);
            if (_pointSize == 1)
            {
                returnValue.Add(new Vector2(currentPixel.x, currentPixel.y));
                return returnValue;
            }

            for (var x = 0; x < _pointSize; x++)
            {
                for (var y = 0; y < _pointSize; y++)
                {
                    var correctTargetPixel = new Vector2(targetPixel.x * textureWidth, targetPixel.y * textureHeight);
                    var newPoint = new Vector2(currentPixel.x + x, currentPixel.y + y);
                    
                    if (!cubeDataHolder.CheckPointsInUvBox(newPoint, correctTargetPixel))
                    {
                        continue;
                    }

                    returnValue.Add(newPoint);
                }
            }

            return returnValue;
        }

        private List<Vector2> GetFillPixels(Vector2 targetPixel, int textureWidth, int textureHeight, CubeDataHolder cubeDataHolder)
        {
            var returnValue = new List<Vector2>();
            Vector2 minUV = new Vector2();
            Vector2 maxUV = new Vector2();
            var correctTargetPixel = new Vector2(targetPixel.x * textureWidth, targetPixel.y * textureHeight);
            cubeDataHolder.GetMinMax(correctTargetPixel, ref minUV, ref maxUV);

            for (var x = (int)minUV.x; x <= (int)maxUV.x-1; x++)
            {
                for (var y = (int)minUV.y; y <= (int)maxUV.y-1; y++)
                {
                    returnValue.Add(new Vector2(x, y));
                }
            }

            return returnValue;
        }

        private void RandomColorLogic()
        {
            var valueFloat = 0.5f;
            Color.RGBToHSV(_color, out float H, out float S, out float V);
            _colorsList= new List<Color>();
            
            for (var x = 0; x < _pointSize; x++)
            {
                for (var y = 0; y < _pointSize; y++)
                {
                    var valueMin = 0f;
                    var valueMax = 0f;

                    if (V >= 1)
                    {
                        valueMin = valueFloat;
                        valueMax = V;
                    }
                    else
                    {
                        valueMin = V;
                        valueMax = valueFloat;
                    }

                    _colorsList.Add(UnityEngine.Random.ColorHSV(H, H, S, S, valueMin, valueMax, 1f, 1f));
                }
            }

            DrawLogic();
        }

        private void EracerLogic()
        {
            var lastColot = new Color(_color.r, _color.g, _color.g, 1);
            _color = new Color(0, 0, 0, 0);
            PaintingLogic();
            _color = new Color(lastColot.r, lastColot.g, lastColot.b, 1);
        }

        private void PickerLogic()
        {
            touchDetection.SetPaintingStatus(true);
            var renderer = _hit.transform.GetComponent<Renderer>();

            if (renderer == null || renderer.sharedMaterial == null || renderer.sharedMaterial.mainTexture == null)
            {
                return;
            }

            var mainTexture = renderer.material.GetTexture(MainTexture) as Texture2D;
            var secondTexture = renderer.material.GetTexture(SecondTexture) as Texture2D;
            var pixelUV = _hit.textureCoord;
            pixelUV.x *= secondTexture.width;
            pixelUV.y *= secondTexture.height;
            var pixelColor = secondTexture.GetPixel((int)pixelUV.x, (int)pixelUV.y);

            if (pixelColor.a <= 0)
            {
                pixelColor = mainTexture.GetPixel((int)pixelUV.x, (int)pixelUV.y);
            }

            _pickColorCallback?.Invoke(pixelColor);
            _isColorPicked = true;
        }
    }
}