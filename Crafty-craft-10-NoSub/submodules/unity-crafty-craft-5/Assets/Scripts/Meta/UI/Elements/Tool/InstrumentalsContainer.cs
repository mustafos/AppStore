using UnityEngine;

namespace Meta.UI.Elements.Tool
{
    public class InstrumentalsContainer : MonoBehaviour
    {
        [SerializeField] private ButtonWithStateVisualization[] _buttonWithStateVisualization;

        private ButtonWithStateVisualization _currentSelectedButton;

        private void Awake()
        {
            foreach (ButtonWithStateVisualization button in _buttonWithStateVisualization)
            {
                button.Button.onClick.AddListener(() => SwitchSelectedButton(button));
            }

            ToggleButtons(false);
        }

        public void EnableButtonById(int id) => SwitchSelectedButton(_buttonWithStateVisualization[id]);

        private void ToggleButtons(bool state)
        {
            foreach (ButtonWithStateVisualization button in _buttonWithStateVisualization)
            {
                button.SetState(state);
            }
        }

        private void SwitchSelectedButton(ButtonWithStateVisualization button)
        {
            if (_currentSelectedButton != null)
            {
                _currentSelectedButton.SetState(false);
            }

            _currentSelectedButton = button;
            _currentSelectedButton.SetState(true);
        }
    }
}