using UnityEngine;

namespace Meta.Preview
{
    public class PreviewCameraController : MonoBehaviour
    {
        [SerializeField] private Camera camera;
    
        public bool RayCast(Vector2 position, out RaycastHit hit)
        {
            var ray = camera.ScreenPointToRay(position);
            return Physics.Raycast(ray, out hit);
        }
    }
}
