using Meta.Inputs;
using Meta.UI.Elements.Tool;
using UnityEngine;

namespace Meta.UI.Elements
{
    public class PencilSizeSelectionContainer : ToolElement
    {
        [SerializeField] private SizeSelectButton[] _sizeSelectButtons;
        [SerializeField] private SizeSelectionPointer _pointer;

        private InputController _inputController;
        private int _currentSize;

        public void Construct(InputController inputController)
        {
            _inputController = inputController;
        }

        private void Awake()
        {
            foreach (SizeSelectButton button in _sizeSelectButtons)
            {
                button.SizeSelectedEvent.AddListener(UpdatePencilSize);
            }
        }

        public void SendCurrentSize() => UpdatePencilSize(_currentSize);

        public void SetDefaultButton(int buttonId)
        {
            _pointer.SetXPos(_sizeSelectButtons[buttonId].transform.position.x);
            var size = _sizeSelectButtons[buttonId].Size;
            UpdatePencilSize(size);
        }

        private void UpdatePencilSize(int size)
        {
            _currentSize = size;
            _inputController.SetPenPointSize(size);
        }
    }
}