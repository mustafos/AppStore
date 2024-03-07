using System;
using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;

namespace Meta.Inputs
{
    public class TouchDetection : MonoBehaviour
    {
        public delegate void MoveTouch(Vector2 shift);
        public event MoveTouch OnMoveTouch;
        public delegate void ZoomTouch(float direction);
        public event ZoomTouch OnZoomTouch;
        public delegate void RotateTouch(Vector2 shift);
        public event RotateTouch OnRotateTouch;
        public delegate void DoubleTouch();
        public event DoubleTouch OnDoubleTouch;
        public delegate void IsMoving(bool value);

        private EventSystem _eventSystem;
        private Coroutine _zoomAndMoveCoroutine;
        private Coroutine _rotateCoroutine;
        private Coroutine _doubleTapCoroutine;
        private Coroutine _allMoveTouchCoroutine;
        private Coroutine _rotateTouchCoroutine;
        [SerializeField]private bool _isPainting;
        private bool _isMoveActive;
        private int _lastTouchCount;
        private bool _isCheckRotationInput;
        private bool _isCheckZoomAndMoveInput;
        private int _tapCounter;
        private readonly float _maxDoubleTapTime = 0.3f;
        private float _newDoubleTapTime;
        private bool _inputBlock;
      
        public void Initialize(EventSystem eventSystem)
        {
            _eventSystem = eventSystem;
            StartCoroutine(DoubleTupTouches());
        }

        public void SetInputBlock(bool value)
        {
            _inputBlock = value;
        }

        public void MoveTouchesSetActive()
        {
            if(_rotateTouchCoroutine != null)
            {
                StopCoroutine(_rotateTouchCoroutine);
                _rotateTouchCoroutine = null;
            }
            _allMoveTouchCoroutine = StartCoroutine(AllMoveTouchInitializeTouches());
        }

        public void MoveTouchesDisable()
        {
            if (_rotateTouchCoroutine != null)
            {
                StopCoroutine(_allMoveTouchCoroutine);
                _allMoveTouchCoroutine = null;
            }

            _rotateTouchCoroutine = StartCoroutine(RotateTouchInitializeTouches());
        }

        public void SetPaintingStatus(bool value)
        {
            _isPainting = value;
        }
        
        private IEnumerator DoubleTupTouches()
        {
            while (true)
            {
                yield return true;

                if (IsBlockedTouchRecognizing())
                {
                    yield return null;
                }
                else
                {
                    if (Time.time > _newDoubleTapTime && _tapCounter > 0) 
                    {
                        _tapCounter = 0;
                    }

                    try
                    {
                        if (Input.touchCount >= 2)
                        {
                            _tapCounter = 0;
                        }
                        else
                        {
                            var firstFingerTouch = Input.GetTouch(0);

                            if (firstFingerTouch.phase == TouchPhase.Ended)
                            {
                                _tapCounter += 1;
                            }
            
                            switch (_tapCounter)
                            {
                                case 1:
                                    _newDoubleTapTime = Time.time + _maxDoubleTapTime;
                                    break;
                                case 2 when Time.time <= _newDoubleTapTime:
                                    OnDoubleTouch?.Invoke();
                                    _tapCounter = 0;
                                    break;
                            }
                        }
                    }
                    catch (Exception e)
                    {
                    }
                }
            }
        }
        
        private IEnumerator RotateTouchInitializeTouches()
        {
            while (true)
            {
                yield return new WaitForSeconds(0.1f);

                if (IsBlockedTouchRecognizing())
                {
                    StopTouchDetection();
                    yield return null;
                }
                else
                {
                    switch (Input.touchCount)
                    {
                        case 0:
                            StopTouchDetection();
                            break;
                        case 1:
                            if (_lastTouchCount > 0)
                            {
                                break;
                            }

                            _lastTouchCount = 1;
                            RotateStart();
                            break;
                    }
                }
            }
        }

        private IEnumerator AllMoveTouchInitializeTouches()
        {
            while (true)
            {
                yield return new WaitForSeconds(0.1f);

                if (IsBlockedTouchRecognizing())
                {
                    StopTouchDetection();
                    yield return null;
                }
                else
                {
                    switch (Input.touchCount)
                    {
                        case 0:
                            StopTouchDetection();
                            yield return null;
                            break;
                        case 2:
                            if (_lastTouchCount > 0)
                            {
                                break;
                            }

                            _lastTouchCount = 2;
                            ZoomAndMoveStart();
                            yield return null;
                            break;
                        case 1:
                            if (_lastTouchCount > 0)
                            {
                                break;
                            }

                            _lastTouchCount = 1;
                            RotateStart();
                            break;
                    }
                }
            }
        }

        private void StopTouchDetection()
        {
            if (_lastTouchCount < 1)
            {
                return;
            }

            switch (_lastTouchCount)
            {
                case 1:
                    RotateEnd();
                    break;
                case 2:
                    ZoomAndMoveEnd();
                    break;
            }

            _lastTouchCount = 0;
        }

        private void ZoomAndMoveStart()
        {
            _isCheckZoomAndMoveInput = true;
            _zoomAndMoveCoroutine = StartCoroutine(ZoomAndMoveDetection());
        }

        private void ZoomAndMoveEnd()
        {
            _isCheckZoomAndMoveInput = false;
            StopCoroutine(_zoomAndMoveCoroutine);
        }
        
        private void RotateStart()
        {
            _isCheckRotationInput = true;
            _rotateCoroutine = StartCoroutine(RotateDetection());
        }

        private void RotateEnd()
        {
            _isCheckRotationInput = false;
            StopCoroutine(_rotateCoroutine);
        }

        private IEnumerator ZoomAndMoveDetection()
        {
            var previousDistance = 0f;
            var moveShift = 5f;
            var zoomShift = 7f;

            while (_isCheckZoomAndMoveInput)
            {
                try
                {
                    var firstFingerTouch = Input.GetTouch(0);
                    var secondFingerTouch = Input.GetTouch(1);
                    var distance = Vector2.Distance(firstFingerTouch.position, secondFingerTouch.position);

                    if (distance > previousDistance + zoomShift)
                    {
                        OnZoomTouch?.Invoke(distance);
                    }
                    else if (distance < previousDistance - zoomShift)
                    {
                        OnZoomTouch?.Invoke(-distance);
                    }
                    else if ((distance > previousDistance && distance < previousDistance + moveShift) ||
                             (distance < previousDistance && distance > previousDistance - moveShift))
                    {
                        OnMoveTouch?.Invoke(firstFingerTouch.deltaPosition);
                    }

                    previousDistance = distance;
                }
                catch (Exception e) { }

                yield return null;
            }
        }

        private IEnumerator RotateDetection()
        {
            while (_isCheckRotationInput)
            {
                try
                {
                    if (Input.touchCount == 1)
                    {
                        var firstFingerTouch = Input.GetTouch(0);

                        if (firstFingerTouch.phase == TouchPhase.Moved)
                        {
                            OnRotateTouch?.Invoke(firstFingerTouch.deltaPosition);
                        }
                    }

                }
                catch (Exception e) { }
                
                yield return null;
            }
        }

        private bool IsBlockedTouchRecognizing()
        {
            if (_inputBlock)
            {
                return true;
            }

            if (_eventSystem.currentSelectedGameObject != null)
            {
                return true;
            }

            if (_isPainting)
            {
                return true;
            }

            return false;
        }
    }
}