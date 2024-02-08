using System;
using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI
{
    [RequireComponent(typeof(RawImage))]
    public class RawImageController : MonoBehaviour
    {
        [SerializeField] private Camera renderCamera;
        private RawImage _rawImage;
        private Vector2Int _lastImageSize;
        private Vector2Int _imageSize;
        
        private void Start()
        {
            _rawImage = GetComponent<RawImage>();
            GetImageSize();
            CreateRenderTexture();
        }

        private void Update()
        {
            GetImageSize();

            if (_lastImageSize.x == _imageSize.x && _lastImageSize.y == _imageSize.y)
            {
                return;
            }

            CreateRenderTexture();
        }

        private void GetImageSize()
        {
            _imageSize = new Vector2Int(Convert.ToInt32(Screen.width), Convert.ToInt32(Screen.height));
        }

        private void CreateRenderTexture()
        {
            _lastImageSize = new Vector2Int(_imageSize.x, _imageSize.y);
            var renderTexture = new RenderTexture(_lastImageSize.x, _lastImageSize.y, 9999);
            renderCamera.targetTexture = renderTexture;
            _rawImage.texture = renderTexture;
        }
    }
}