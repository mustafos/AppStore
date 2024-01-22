using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI
{
    public class TopShiftController : MonoBehaviour
    {
        [SerializeField] private LayoutElement topShiftElement;
        [SerializeField] private float paddingY = 65f;

        private void Start()
        {
            RepositionFromTopSafeArea();
        }
    
        private void RepositionFromTopSafeArea()
        {
            Rect safeArea = Screen.safeArea;
            var maxY = safeArea.yMax;
            var heightDifference = Screen.height - maxY;
            var screenRatio = (float)Screen.width / Screen.height;
            var isSmallPhone = (screenRatio <= 0.60f);
            var yPosition =  0.0f;

            if (heightDifference == 0 && isSmallPhone)
            {
                yPosition = heightDifference + paddingY * 3;
            }
            else
            {
                yPosition = heightDifference + paddingY;
            }
            
            topShiftElement.minHeight = (int)yPosition;
        }
    }
}
