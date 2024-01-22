using UnityEngine;

namespace Meta.Preview
{
    public class UI3DPreviewHolderController : MonoBehaviour
    {
        public delegate void  GetTouchPosition(Vector2 touchPosition);
        public event GetTouchPosition OnGetTouchPosition;

        [SerializeField] private RectTransform rectTransform;
        [SerializeField] private PreviewButton button;

        private void Start()
        {
            Initialize();
        }

        public void Initialize()
        {
            button.OnButtonDown += OnButtonDown;
        }

        private void OnButtonDown()
        {
            if (Input.touchCount == 0)
            {
                return;
            }

            var oneFingerTouch = Input.GetTouch(0);
            CalculatePosition(oneFingerTouch.position);
        }
        
        public void CalculatePosition(Vector2 touchPosition)
        {
            var screenSize = new Vector2(Screen.width, Screen.height);
            var rect = rectTransform.rect;
            var holderSize = new Vector2(rect.width, rect.height);
            var localPosition = rectTransform.localPosition;
            var holderLocalPosition = new Vector2(localPosition.x, localPosition.y);
            var parentPosition = screenSize / 2;
            var holderPosition = parentPosition + holderLocalPosition;
            var zeroPoint = new Vector2(holderPosition.x - holderSize.x, holderPosition.y);
            var returnPoint = touchPosition - zeroPoint;
            OnGetTouchPosition?.Invoke(returnPoint);
        }
    }
}