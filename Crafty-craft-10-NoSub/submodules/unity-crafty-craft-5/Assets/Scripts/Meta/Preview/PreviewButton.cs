using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace Meta.Preview
{
    public class PreviewButton : Button
    {
        public delegate void ButtonDown();
        public event ButtonDown OnButtonDown;

        public override void OnPointerDown(PointerEventData eventData)
        {
            base.OnPointerDown(eventData);

            if (eventData.button != PointerEventData.InputButton.Left)
            {
                return;
            }

            OnButtonDown?.Invoke();
        }
    }
}