using System.Collections.Generic;
using DG.Tweening;
using Meta.Preview;
using UnityEngine;
using Voxel.Character;

namespace Meta.Inputs
{
    [RequireComponent(typeof(CharacterElement))]
    public class PreviewController : MonoBehaviour
    {
        [SerializeField] private UI3DPreviewHolderController _ui3DPreviewHolderController;
        [SerializeField] private Transform camerasHolder;
        [SerializeField] private Camera camera;
        
        private readonly float _rotationSpeed = 0.5f;
        private readonly float _animationTime = 0.5f;
        private readonly float _cameraZoomSpeed = 0.2f;
        private readonly float _cameraMoveSpeed = 0.2f;
        private readonly float _zoomShift = 0.3f;
        
        private Transform _chaildTransform;
        private Vector2 _touchPosition;
        private RaycastHit _hit;
        private bool _notDetectedHit;
        private List<CharacterElement> _objectsOfHit = new List<CharacterElement>();
        private List<GameObject> _hiddenObjects = new List<GameObject>();
        private Vector3 _cameraHolderPosition;
        
        public void Initialize(TouchDetection touchDetection)
        {
            var position = camerasHolder.position;
            _cameraHolderPosition = new Vector3(position.x, position.y, position.z);
            _ui3DPreviewHolderController.OnGetTouchPosition += OnGetTouchPosition;
            _chaildTransform = GetComponent<CharacterElement>().Children[0].transform;
            touchDetection.OnMoveTouch += OnTouchMoveLogic;
            touchDetection.OnZoomTouch += OnTouchZoomLogic;
            touchDetection.OnRotateTouch += OnTouchRotateLogic;
            touchDetection.OnDoubleTouch += OnDoubleTouchLogic;
        }

        private void OnTouchZoomLogic(float direction)
        {
            var cameraPosition = camerasHolder.position;
            cameraPosition.z += direction*_zoomShift;
            camerasHolder.position = Vector3.Lerp(camerasHolder.position, cameraPosition, _cameraZoomSpeed);
        }

        private void OnTouchMoveLogic(Vector2 shift)
        {
            var cameraPosition = camerasHolder.position;

            var multiplier = cameraPosition.z / 100;
            if (multiplier == 0)
            {
                multiplier = 1;
            }
            
            cameraPosition.x += shift.x * -1 * Mathf.Abs(multiplier);
            cameraPosition.y += shift.y * -1 * Mathf.Abs(multiplier);
            camerasHolder.position = Vector3.Lerp(camerasHolder.position, cameraPosition, _cameraMoveSpeed);
        }

        private void OnGetTouchPosition(Vector2 touchPosition)
        {
            _touchPosition = touchPosition;
            CheckHit();
        }

        private void OnDoubleTouchLogic()
        {
            var animationType = Ease.OutCubic;
            transform.DORotate(Vector3.zero, _animationTime).SetEase(animationType);
            _chaildTransform.DORotate(Vector3.zero, _animationTime).SetEase(animationType);
            camerasHolder.DOMove(_cameraHolderPosition, _animationTime).SetEase(animationType);
        }

        private void OnTouchRotateLogic(Vector2 shift)
        {
            var rotationX = Quaternion.Euler(0, shift.x * _rotationSpeed * -1, 0);
            var rotationY = Quaternion.Euler(shift.y * _rotationSpeed, 0, 0);
            transform.rotation *= rotationY;
            _chaildTransform.rotation *= rotationX;
        }

        private bool Raycast()
        {
            var ray = camera.ScreenPointToRay(_touchPosition);
            return Physics.Raycast(ray, out _hit);
        }

        private void CheckHit()
        {
            if (Raycast())
            {
                var characterElement = _hit.transform.GetComponent<CharacterElement>();
                
                if (!characterElement)
                {
                    ShowHiddenObjects();
                    _objectsOfHit = new List<CharacterElement>();
                    return;
                }

                if (characterElement.State == CharacterCubeState.Visible)
                {
                    ShowHiddenObjects();
                    characterElement.ChangeState();
                    return;
                }

                _hiddenObjects.Add(characterElement.gameObject);
                characterElement.gameObject.SetActive(false);

                if (!_objectsOfHit.Contains(characterElement))
                {
                    _objectsOfHit.Add(characterElement);
                }

                CheckHit();
            }
            else
            {
                if (_objectsOfHit.Count == 0)
                {
                    return;
                }

                ChangeStateForAll();
                ShowHiddenObjects();
            }
        }

        private void ShowHiddenObjects()
        {
            foreach (var hiddenObject in _hiddenObjects)
            {
                hiddenObject.SetActive(true);
            }
            
            _hiddenObjects = new List<GameObject>();
        }

        private void ChangeStateForAll()
        {
            foreach (var objectOfHit in _objectsOfHit)
            {
                objectOfHit.ChangeState();
            }
            
            _objectsOfHit = new List<CharacterElement>();
        }
    }
}