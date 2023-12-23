using System;
using Meta.Inputs;
using Meta.UI.Elements;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI
{
    public class SaveSkinWindow : MonoBehaviour
    {
        [SerializeField] private GameObject _inputFieldObject;
        [SerializeField] private TMP_InputField _inputField;
        [SerializeField] private Button _clearTextButton;
        [SerializeField] private Button _saveButton;
        [SerializeField] private Button _cancelButton;
        [SerializeField] private GameObject bottomBar;
        [SerializeField] private DistributeController distributeController;
        [SerializeField] private Button homeButton;
        [SerializeField] private Button mainSaveButton;
        [SerializeField] private Button rotateButton;
        [SerializeField] private GameObject preview3DHolder;
        [SerializeField] private TextMeshProUGUI modelNameText;
        
        private InputController _inputController;

        public void Construct(InputController inputController)
        {
            gameObject.SetActive(false);

            modelNameText.text = "My new skin";
            _inputController = inputController;
            _saveButton.onClick.AddListener(SaveButtonClicked);
            _cancelButton.onClick.AddListener(Hide);
            _clearTextButton.onClick.AddListener(ClearText);
            _inputField.onValueChanged.AddListener(InputFieldValueChanged);
            distributeController.Initialize();
        }

        private void Start()
        {
            ToggleClearTextButton(false);
        } 

        public void Show(bool withInputField = false)
        {
            ToggleInputField(withInputField);
            gameObject.SetActive(true);
        }

        public void Hide()
        {
            if (IsInputFieldEnabled())
            { 
                _inputController.Block(false);
                gameObject.SetActive(false);
                return;
            }

            Cancel();
        }

        private void ClearText() => _inputField.text = "";

        private void InputFieldValueChanged(string value)
        {
            bool state = value.Length > 0;
            ToggleClearTextButton(state);
        }

        private void ToggleInputField(bool state) => _inputFieldObject.SetActive(state);

        private void ToggleClearTextButton(bool state) => _clearTextButton.gameObject.SetActive(state);
        
        private void SaveButtonClicked()
        {
            if (!IsInputFieldEnabled())
            {
                ToggleInputField(true);
                return;
            }

            Save();

            Action callback = OnDistributeComplete;
            Action rotateCallback = RotateButtonCallback;
            _inputController.Block(false);
            distributeController.ShowContentWindow(_inputField.text, callback, rotateCallback);
        }

        private void OnDistributeComplete()
        {
            SetActiveContent(true);
            _inputController.PenSelect();
        }

        private void RotateButtonCallback()
        {
            rotateButton.onClick.Invoke();
        }

        private void SetActiveContent(bool value)
        {
            rotateButton.interactable = value;
            rotateButton.gameObject.SetActive(value);
            homeButton.gameObject.SetActive(value);
            mainSaveButton.gameObject.SetActive(value);
            bottomBar.gameObject.SetActive(value);
            preview3DHolder.gameObject.SetActive(value);
        }

        private bool IsInputFieldEnabled() =>  _inputFieldObject.activeInHierarchy;

        private void Save()
        {
            if (string.IsNullOrEmpty(_inputField.text))
            {
                Debug.LogWarningFormat("[{0}][Save]_inputField is empty!", GetType().Name);
                return;
            }

            modelNameText.text = _inputField.text;
            _inputController.Save();
            _inputController.SaveTexture();
            
            if (!rotateButton.GetComponent<ButtonWithStateVisualization>().CurrentState)
            {
                rotateButton.onClick.Invoke();
            }
            
            SetActiveContent(false);
            gameObject.SetActive(false);

            if (Application.platform != RuntimePlatform.IPhonePlayer)
            {
                return;
            }

            HostNativeAPI.unity_editorSave(_inputField.text);
        }

        private void Cancel()
        {
            gameObject.SetActive(false);
            _inputController.Block(false);
            
            if (Application.platform != RuntimePlatform.IPhonePlayer)
            {
                return;
            }

            HostNativeAPI.unity_editorExit();
        }

        private void OnDestroy()
        {
            _saveButton.onClick.RemoveListener(SaveButtonClicked);
            _cancelButton.onClick.RemoveListener(Hide);
            _clearTextButton.onClick.RemoveListener(ClearText);
            _inputField.onValueChanged.RemoveListener(InputFieldValueChanged);
        }
    }
}