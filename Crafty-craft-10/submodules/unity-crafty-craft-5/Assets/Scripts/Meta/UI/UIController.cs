using System;
using Meta.Inputs;
using Meta.UI.Elements;
using Meta.UI.Elements.Tool;
using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI
{
    public class UIController : MonoBehaviour
    {
        [SerializeField] private InputController inputController;
        [SerializeField] private Button _homeButton;
        [SerializeField] private Button _saveButton;
        [SerializeField] private SaveSkinWindow _saveSkinWindow;
        [SerializeField] private PalletContainer _palletContainer;
        [SerializeField] private PencilSizeSelectionContainer _pencilSizeSelectionContainer;
        [SerializeField] private EracerSizeSelectionContainer _eracerSizeSelectionContainer;
        [SerializeField] private NoiseSizeSelectionContainer _noiseSizeSelectionContainer;
        [SerializeField] private ToolbarContainer _toolbarContainer;
        [SerializeField] private InstrumentalsContainer _instrumentalsContainer;

        public InputController InputController => inputController;

        public void Initialize()
        {
            _saveSkinWindow.Construct(inputController);
            _pencilSizeSelectionContainer.Construct(inputController);
            _eracerSizeSelectionContainer.Construct(inputController);
            _noiseSizeSelectionContainer.Construct(inputController);
            _homeButton.onClick.AddListener(OnHomeButtonClicked);
            _saveButton.onClick.AddListener(OnSaveButtonClicked);
            _palletContainer.SetDefaultButton(buttonId: 7);
            _eracerSizeSelectionContainer.SetDefaultButton(0);
            _noiseSizeSelectionContainer.SetDefaultButton(0);
            _pencilSizeSelectionContainer.SetDefaultButton(0);
            _toolbarContainer.OpenTool(ToolId.PencilSizeSelection);
            _instrumentalsContainer.EnableButtonById(0);
        }

        private void OnHomeButtonClicked()
        {
            if (inputController.ChangeCount == 0)
            {
                if (Application.platform != RuntimePlatform.IPhonePlayer)
                {
                    return;
                }
                
                HostNativeAPI.unity_editorExit();
            }
            else
            {
                _saveSkinWindow.Show();
                InputController.Block(true);
            }
        }

        private void OnSaveButtonClicked()
        {
            _saveSkinWindow.Show(true);
            InputController.Block(true);
        }

        private void OnDestroy()
        {
            _homeButton.onClick.RemoveListener(OnHomeButtonClicked);
            _saveButton.onClick.RemoveListener(OnSaveButtonClicked);
        }
    }
}