using Meta.Inputs;
using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI.Elements
{
    public class BodyContainer : MonoBehaviour
    {
        [SerializeField] private UIController _uiController;
        [SerializeField] private ButtonWithStateVisualization _rotationButton;
        [SerializeField] private GameObject preview3DHolder;

        private InputController InputController => _uiController.InputController;
        private bool _isActive = false;

        private void Awake()
        {
            _rotationButton.Button.onClick.AddListener(RotationButtonClicked);
            _rotationButton.SetState(_isActive);
        }

        private void RotationButtonClicked()
        {
            _isActive = !_isActive;
            _rotationButton.SetState(_isActive);
            InputController.SetMove(_isActive);
            preview3DHolder.SetActive(!_isActive);
        }
    }
}