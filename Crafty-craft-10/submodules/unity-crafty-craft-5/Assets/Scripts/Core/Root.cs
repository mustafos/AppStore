using System.Threading.Tasks;
using Core.Managers;
using Meta;
using Meta.Inputs;
using Meta.UI;
using UnityEngine;
using Voxel.Character;

namespace Core
{
    public class Root : MonoBehaviour
    {
        [SerializeField] private CharacterConstructor characterConstructor;
        [SerializeField] private InputController inputController;
        [SerializeField] private UIController uiController;
        
        private async void Start()
        {
            await InitializeManagers();
            await InitializeGameScene();
            uiController.Initialize();
        }

        private async Task InitializeManagers()
        {
            var resourceLoadingManager = new ResourceLoadingManager();
            await resourceLoadingManager.Initialize();
            ManagersHolder.Instance.AddManager(resourceLoadingManager);
        }

        private async Task InitializeGameScene()
        {
            characterConstructor.Initialize();
            inputController.Initialize();
        }
    }
}