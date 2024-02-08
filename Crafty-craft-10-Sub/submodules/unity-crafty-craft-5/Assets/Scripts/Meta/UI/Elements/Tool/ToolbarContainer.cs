using System.Linq;
using Meta.Inputs;
using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI.Elements.Tool
{
    public class ToolbarContainer : MonoBehaviour
    {
        [SerializeField] private UIController _uiController;
        [SerializeField] private ToolSelectionButton[] _toolSelectionButtons;
        [SerializeField] private ToolData[] _tools;
        [SerializeField] private PencilSizeSelectionContainer _pencilSizeSelectionContainer;
        [SerializeField] private EracerSizeSelectionContainer _eracerSizeSelectionContainer;
        [SerializeField] private NoiseSizeSelectionContainer _noiseSizeSelectionContainer;
        [SerializeField] private PalletContainer _palletContainer;
        [SerializeField] private Button _pencilButton;
        [SerializeField] private Button _eracerButton;
        [SerializeField] private Button _pickerButton;
        [SerializeField] private Button _fillButton;
        [SerializeField] private Button _noiseButton;
        [SerializeField] private Button undoButton;

        private InputController InputController => _uiController.InputController;
        private ToolElement _currentTool;

        private void Awake()
        {
            foreach (ToolSelectionButton toolSelectionButton in _toolSelectionButtons)
            {
                toolSelectionButton.Button.onClick.AddListener(() => OpenTool(toolSelectionButton.ToolId));
            }

            _pencilButton.onClick.AddListener(OnPencilButtonClicked);
            _eracerButton.onClick.AddListener(OnEracerButtonClicked);
            //_pickerButton.onClick.AddListener(OnPencilButtonClicked);
            _fillButton.onClick.AddListener(OnFillButtonClicked);
            _noiseButton.onClick.AddListener(OnNoiseButtonClicked);
            undoButton.onClick.AddListener(UndoButtonClick);
            
        }

        private void UndoButtonClick()
        {
            InputController.Undo();
            _palletContainer.DropperStateVisualizationButton.SetState(false);
        }

        private void OnPencilButtonClicked()
        {
            _pencilSizeSelectionContainer.SendCurrentSize();
            _palletContainer.DropperStateVisualizationButton.SetState(false);
        } 
        
        private void OnEracerButtonClicked()
        {
            _eracerSizeSelectionContainer.SendCurrentSize();
            _palletContainer.DropperStateVisualizationButton.SetState(false);
        } 
        
        private void OnNoiseButtonClicked()
        { 
            _noiseSizeSelectionContainer.SendCurrentSize();
            _palletContainer.DropperStateVisualizationButton.SetState(false);
        }
        
        private void OnPickerButtonClicked()
        {
            _palletContainer.SendCurrentColor();
            _palletContainer.DropperStateVisualizationButton.SetState(false);
        }
        
        private void OnFillButtonClicked()
        {
            InputController.FillColor();
            _palletContainer.DropperStateVisualizationButton.SetState(false);
        }

        public void OpenTool(ToolId toolId)
        {
            if (_currentTool == GetToolById(ToolId.Pallet) && toolId == ToolId.PencilSizeSelection && _currentTool != null)
            {
                _currentTool = GetToolById(toolId);

                if (_currentTool != null)
                {
                    _currentTool.Open();
                }

                return;
            }
            
            if (toolId == ToolId.Pallet)
            {
                toolId = ToolId.PencilSizeSelection;
            }

            

            if (_currentTool == GetToolById(toolId) && _currentTool != null)
            {
                if (_currentTool.gameObject.activeSelf)
                {
                    _currentTool.Close();
                }
                else
                {
                    _currentTool.Open();
                }

                return;
            }

            if (_currentTool != null)
            {
                _currentTool.Close();
            }

            _currentTool = GetToolById(toolId);

            if (_currentTool != null)
            {
                _currentTool.Open();
            }
        }

        private ToolElement GetToolById(ToolId toolId) => _tools.FirstOrDefault(x => x.ToolId == toolId)?.Element;
    }
}