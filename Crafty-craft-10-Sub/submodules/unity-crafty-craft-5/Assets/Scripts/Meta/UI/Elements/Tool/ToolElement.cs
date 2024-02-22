using UnityEngine;

namespace Meta.UI.Elements.Tool
{
    public abstract class ToolElement : MonoBehaviour
    {
        public void Open() => gameObject.SetActive(true);
        public void Close() => gameObject.SetActive(false);
    }
}