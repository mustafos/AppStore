using System.Runtime.InteropServices;

namespace Meta
{
    /// <summary>
    /// C-API exposed by the Host, i.e., Unity -> Host API.
    /// </summary>
    public static class HostNativeAPI {
        [DllImport("__Internal")]
        public static extern void unity_editorSave(string state);
        
        [DllImport("__Internal")]
        public static extern void unity_editorExit();

        [DllImport("__Internal")]
        public static extern void unity_editorDownload(string state);

        [DllImport("__Internal")]
        public static extern void unity_editorShare(string state);
    }
}