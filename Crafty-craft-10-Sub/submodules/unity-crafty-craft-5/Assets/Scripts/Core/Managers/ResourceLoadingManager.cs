using System.IO;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using UnityEngine;
using Voxel.McData;

namespace Core.Managers
{
    public class ResourceLoadingManager : IManager
    {
        private const string DataPath = "Data/data.json";
        private const string TexturePath = "Data/texture.png";
        private const string SecondTexturePath = "Data/texture2.png";
        private const string ScreenShotPath = "Data/preview.png";

        public async Task Initialize() { }
        
        public bool GetDataFromJson(out GeometryData data)
        {
            var path = Path.Combine(Application.persistentDataPath, DataPath);
            var configFile = System.IO.File.ReadAllText(path);
            
            if(string.IsNullOrEmpty(configFile))
            {
                data = null;
                return false;
            }
            
            var fixedJson = Regex.Replace(configFile, "minecraft:geometry", "minecraft_geometry", RegexOptions.IgnoreCase);
            data =  JsonUtility.FromJson<GeometryData>(fixedJson);
            return true;
        }

        public bool GetTexture(out Texture2D texture)
        {
            var path = Path.Combine(Application.persistentDataPath, TexturePath);
            var bytes = System.IO.File.ReadAllBytes(path);
            texture = new Texture2D(512, 512);
            texture.LoadImage(bytes);
            return texture;
        }

        public void SaveTexture(Texture2D texture)
        {
            var path = Path.Combine(Application.persistentDataPath, TexturePath);
            var bytes = texture.EncodeToPNG();
            File.WriteAllBytes(path, bytes);
        }

        public void SaveSecondTexture(Texture2D texture)
        {
            var path = Path.Combine(Application.persistentDataPath, SecondTexturePath);
            var bytes = texture.EncodeToPNG();
            File.WriteAllBytes(path, bytes);
        }

        public void SaveScreenShot(Texture2D texture)
        {
            var path = Path.Combine(Application.persistentDataPath, ScreenShotPath);
            var bytes = texture.EncodeToPNG();
            File.WriteAllBytes(path, bytes);
        }
    }
}