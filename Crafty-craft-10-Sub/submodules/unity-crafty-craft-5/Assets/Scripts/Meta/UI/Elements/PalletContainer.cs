using System;
using System.Collections.Generic;
using System.Linq;
using Cysharp.Threading.Tasks;
using DG.Tweening;
using Meta.Inputs;
using Meta.UI.Elements.Tool;
using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI.Elements
{
    public class PalletContainer : ToolElement
    {
        public ButtonWithStateVisualization DropperStateVisualizationButton => _dropperStateVisualizationButton;
        
        [SerializeField] private List<Button> _colorButtons;
        [SerializeField] private Button _paletteButton;
        [SerializeField] private GameObject colorButtonPrefab;
        [SerializeField] private Transform colorButtonsRoot;
        [SerializeField] private Image pickedColorIndicator;
        [SerializeField] private ButtonWithStateVisualization _dropperStateVisualizationButton;
        [SerializeField] private SelectColorWindow _selectColorWindow;
        [SerializeField] private Vector3 _selectedButtonScale;
        [SerializeField] private UIController _uiController;

        private InputController InputController => _uiController.InputController;
        private Button _currentButton;
        private bool _isPicker = false;
        private bool _isPickEnd = false;
        private Color _color;

        private void Awake()
        {
            foreach (Button button in _colorButtons)
            {
                button.onClick.AddListener(() => UpdateSelectedButton(button));
            }

            _paletteButton.onClick.AddListener(OpenSelectColorContent);
            _dropperStateVisualizationButton.Button.onClick.AddListener(DropperButtonClicked);
            _dropperStateVisualizationButton.SetState(false);
            UpdateSelectedButton(_colorButtons.Last());
        }

        private void OnEnable()
        {
            InputController.PalletSelect();
        }

        public void SendCurrentColor()
        {
            InputController.SetColor(_currentButton.image.color);
        }

        public void SetDefaultButton(int buttonId)
        {
            UpdateSelectedButton(_colorButtons[buttonId]);
        }

        private void DropperButtonClicked()
        {
            _dropperStateVisualizationButton.SetState(true);
            Action<Color> colorCallback = UpdatePickerPosition;
            Action finishColorPicker = FinishColorPicker;
            InputController.StartPickColor(colorCallback, finishColorPicker);
        }

        private void FinishColorPicker()
        {
            _isPicker = true;
            _isPickEnd = true;
            AddNewButtonColor(_color);
            _dropperStateVisualizationButton.SetState(false);
        }

        private void UpdateSelectedButton(Button button)
        {
            SetCurrentButton(button);
            Color selectedColor = button.image.color;
            InputController.SetColor(selectedColor);
            _dropperStateVisualizationButton.SetState(false);
        }

        private void SetCurrentButton(Button button)
        {
            if (_currentButton != null)
            {
                _currentButton.transform.localScale = Vector3.one;
            }

            _currentButton = button;
            _currentButton.transform.localScale = _selectedButtonScale;
        }

        private void OpenSelectColorContent()
        {
            InputController.Block(true);
            _isPickEnd = true;
            _selectColorWindow.Show(_currentButton.image.color, AddNewButtonColor, CancelCallback);
        }

        private void CancelCallback()
        {
            InputController.Block(false);
        }

        private async void AddNewButtonColor(Color color)
        {
            if (!_isPickEnd)
            {
                return;
            }

            var button = Instantiate(colorButtonPrefab, colorButtonsRoot).GetComponent<Button>();

            if (!button)
            {
                return;
            }

            button.onClick.AddListener(() => UpdateSelectedButton(button));
            button.image.color = color;
            InputController.Block(false);
            InputController.SetColor(color);

            if (_colorButtons.Count >= 9)
            {
                _colorButtons[0].onClick.RemoveListener(() => UpdateSelectedButton(button));
                Destroy(_colorButtons[0].gameObject);
                _colorButtons.RemoveAt(0);
            }

            _colorButtons.Add(button);
            _dropperStateVisualizationButton.SetState(false);
            UpdateSelectedButton(button);

            if (_isPicker)
            {
                ShowPickedColorLogic(color);
                _isPicker = false;
            }
        }

        private async void ShowPickedColorLogic(Color color)
        {
            if (Input.touchCount == 0)
            {
                return;
            }

            await pickedColorIndicator.DOFade(0, 0.2f).SetEase(Ease.InCubic).ToUniTask();
            pickedColorIndicator.gameObject.SetActive(false);
        }

        private void UpdatePickerPosition(Color color)
        {
            _color = color;

            if (Input.touchCount == 0)
            {
                return;
            }
            
            var touch = Input.GetTouch(0);
            var touchPosition = touch.position;
            var screenCenter = new Vector2(Screen.width / 2, Screen.height / 2);
            var rect = pickedColorIndicator.rectTransform.rect;
            var pickerCenter = new Vector2(rect.width / 2, rect.height / 2);
            var newPosition = touchPosition - screenCenter - pickerCenter;
            pickedColorIndicator.rectTransform.localPosition = newPosition;
            pickedColorIndicator.color = color;
            pickedColorIndicator.gameObject.SetActive(true);

            if (pickedColorIndicator.color == _color)
            {
                return;
            }

            pickedColorIndicator.color = _color;
        }
    }
}