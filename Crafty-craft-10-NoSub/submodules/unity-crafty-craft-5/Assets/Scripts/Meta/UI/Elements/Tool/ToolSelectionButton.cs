using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI.Elements.Tool
{
  [RequireComponent(typeof(Button))]
  public class ToolSelectionButton : MonoBehaviour
  {
    [SerializeField]
    private ToolId _toolId;

    [SerializeField, HideInInspector]
    private Button _button;
    
    #region Properties

    public ToolId ToolId => _toolId;
    public Button Button => _button;
    
    #endregion

#if UNITY_EDITOR
    private void OnValidate()
    {
      if (_button == null)
        TryGetComponent(out _button);
    }
#endif
  }
}