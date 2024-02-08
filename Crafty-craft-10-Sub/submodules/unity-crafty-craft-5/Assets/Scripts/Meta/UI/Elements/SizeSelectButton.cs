using System;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace Meta.UI.Elements
{
  [RequireComponent(typeof(Button))]
  public class SizeSelectButton : MonoBehaviour
  {
    [SerializeField, HideInInspector]
    private Button _button;

    [SerializeField, HideInInspector]
    private TMP_Text _text;
    
    [SerializeField]
    private SizeSelectionPointer _pointer;

    #region Actions

    public SizeSelectedEvent SizeSelectedEvent = new SizeSelectedEvent();

    #endregion

    #region Properties

    public int Size => Int32.Parse(_text.text);

    #endregion
    
    private void Awake() => 
      _button.onClick.AddListener(Clicked);

    private void Clicked()
    {
      SizeSelectedEvent?.Invoke(Int32.Parse(_text.text));
      _pointer.SetXPos(transform.position.x);
    }

#if UNITY_EDITOR
    private void OnValidate()
    {
      if (_button == null)
        TryGetComponent(out _button);

      if (_text == null)
        _text = GetComponentInChildren<TMP_Text>();
    }
#endif
  }

  public class SizeSelectedEvent : UnityEvent<int> { }
}