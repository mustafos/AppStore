using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI.Elements
{
  public class SizeSelectionPointer : MonoBehaviour
  {
    [SerializeField]
    private Image _pointerImage;

    [SerializeField, HideInInspector]
    private Transform _pointerTransform;
    
    public void SetXPos(float x)
    {
      Vector3 pos = _pointerTransform.position;
      pos.x = x;
      
      _pointerTransform.position = pos;
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
      if (_pointerImage != null)
        _pointerTransform = _pointerImage.transform;
    }
#endif
  }
}