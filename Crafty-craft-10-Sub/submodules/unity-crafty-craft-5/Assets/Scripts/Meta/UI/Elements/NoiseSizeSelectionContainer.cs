using Meta.Inputs;
using Meta.UI.Elements.Tool;
using UnityEngine;

namespace Meta.UI.Elements
{
  public class NoiseSizeSelectionContainer : ToolElement
  {
    [SerializeField]
    private SizeSelectButton[] _sizeSelectButtons;

    [SerializeField]
    private SizeSelectionPointer _pointer;

    #region Fields

    private InputController _inputController;
    private int _currentSize;

    #endregion

    public void Construct(InputController inputController) => 
      _inputController = inputController;

    private void Awake()
    {
      foreach (SizeSelectButton button in _sizeSelectButtons) 
        button.SizeSelectedEvent.AddListener(UpdateSize);
    }

    public void SendCurrentSize() => 
      UpdateSize(_currentSize);

    public void SetDefaultButton(int buttonId)
    {
      _pointer.SetXPos(_sizeSelectButtons[buttonId].transform.position.x);
      int size = _sizeSelectButtons[buttonId].Size;
      UpdateSize(size);
    }
    
    private void UpdateSize(int size)
    {
      _currentSize = size;
      _inputController.RandomColor(size);
    }
  }
}