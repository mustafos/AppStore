using System;
using UnityEngine;
using UnityEngine.UI;

namespace Meta.UI
{
    public class DistributeController : MonoBehaviour
    {
        [SerializeField] private Button homeWithoutSaveButton;
        [SerializeField] private Button downloadButton;
        [SerializeField] private Button shareButton;

        private Action _callback;
        private Action _rotateCallback;
        private string _fileName = "";

        public void Initialize()
        {
            homeWithoutSaveButton.onClick.AddListener(OnHomeButtonClicked);
            downloadButton.onClick.AddListener(OnDownloadButtonClicked);
            shareButton.onClick.AddListener(OnShareButtonClicked);
        }

        public void ShowContentWindow(string fileName, Action callback, Action rotateCallback)
        {
            if (string.IsNullOrEmpty(fileName))
            {
                Debug.LogWarningFormat("[{0}][ShowContentWindow]fileName is empty!", GetType().Name);
                return;
            }

            _fileName = fileName;
            _callback = callback;
            _rotateCallback = rotateCallback;
            gameObject.SetActive(true);
            homeWithoutSaveButton.gameObject.SetActive(true);
        }

        private void OnDownloadButtonClicked()
        {
            
#if UNITY_EDITOR 
            gameObject.SetActive(false);
#endif
            
            if (Application.platform != RuntimePlatform.IPhonePlayer)
            {
                return;
            }
            
            HostNativeAPI.unity_editorDownload(_fileName);
        }

        private void OnShareButtonClicked()
        {
            
#if UNITY_EDITOR
            gameObject.SetActive(false);
#endif
            
            if (Application.platform != RuntimePlatform.IPhonePlayer)
            {
                return;
            }
            
            HostNativeAPI.unity_editorShare(_fileName);
        }

        private void OnHomeButtonClicked()
        {
            homeWithoutSaveButton.gameObject.SetActive(false);
            gameObject.SetActive(false);
            
            if (Application.platform != RuntimePlatform.IPhonePlayer)
            {
                return;
            }

            HostNativeAPI.unity_editorExit();
        }
        

        private void OnDisable()
        {
            _callback?.Invoke();
            _rotateCallback?.Invoke();
        }

        private void OnDestroy()
        {
            homeWithoutSaveButton.onClick.RemoveListener(OnHomeButtonClicked);
            downloadButton.onClick.RemoveListener(OnDownloadButtonClicked);
            shareButton.onClick.RemoveListener(OnShareButtonClicked);
        }
    }
}
