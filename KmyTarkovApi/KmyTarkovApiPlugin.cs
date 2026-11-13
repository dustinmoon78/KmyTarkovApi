using BepInEx;
using KmyTarkovApi.Patches;

namespace KmyTarkovApi
{
    [BepInPlugin("com.kmyuhkyuk.kmytarkovapi", "KmyTarkovApi", "2.0.0")]
    [BepInDependency("com.kmyuhkyuk.kmytarkovreflection", "2.0.0")]
    //Only 3.11.0 + support
    [BepInDependency("com.SPT.core", "3.11.0")]
    public class KmyTarkovApiPlugin : BaseUnityPlugin
    {
        private void Start()
        {
            EFTVersion.WriteVersionLog();

            //Init EFTHelpers Hooks
            EFTHelpers.InitHooks();

            //Player
            new GamePlayerOwnerPatchs().Enable();

            //GameWorld
            new TriggerWithIdPatchs().Enable();
        }
    }
}