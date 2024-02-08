using JetBrains.Annotations;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI.Elements
{
    [RequireComponent(typeof(Button))]
    public class ButtonWithStateVisualization : MonoBehaviour
    {
        [SerializeField] private Image _iconImage;
        [SerializeField] [CanBeNull] private TextMeshProUGUI text;
        [SerializeField] private Sprite _selectedSprite;
        [SerializeField] private Sprite _unselectedSprite;
        [SerializeField] private Color textSelectedColor;
        [SerializeField] private Color textUnselectedColor;
        [SerializeField, HideInInspector] private Button _button;

        private bool _currentState = false;

        public bool CurrentState => _currentState;

        public Button Button => _button;

        public void SetState(bool state)
        {
            _iconImage.sprite = state ? _selectedSprite : _unselectedSprite;
            
            if (text != null)
            {
                text.color = state ? textSelectedColor : textUnselectedColor;

            }
            else
            {
                _button.interactable = !state;
            }
            
            _currentState = state;
        }

#if UNITY_EDITOR
        private void OnValidate()
        {
            if (_button == null)
            {
                TryGetComponent(out _button);
            }
        }
#endif
    }
}