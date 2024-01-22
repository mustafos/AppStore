using System;
using HSVPicker;
using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI
{
    public class SelectColorWindow : MonoBehaviour
    {
        [SerializeField] private ColorPicker _colorPicker;
        [SerializeField] private Button _cancelButton;
        [SerializeField] private Button _okButton;

        private Action<Color> _onColorSelected;
        private Action _onCancelCallback;

        private void Awake()
        {
            _cancelButton.onClick.AddListener(Hide);
            _okButton.onClick.AddListener(SelectColorAndClose);
        }

        public void Show(Color assignColor, Action<Color> onColorSelected, Action onCancelCallback)
        {
            _onColorSelected = onColorSelected;
            _onCancelCallback = onCancelCallback;
            _colorPicker.AssignColor(assignColor);
            gameObject.SetActive(true);
        }

        public void Hide()
        {
            _onCancelCallback?.Invoke();
            gameObject.SetActive(false);
        }

        private void SelectColorAndClose()
        {
            Color selectedColor = _colorPicker.CurrentColor;
            _onColorSelected?.Invoke(selectedColor);
            Hide();
        }
    }
}