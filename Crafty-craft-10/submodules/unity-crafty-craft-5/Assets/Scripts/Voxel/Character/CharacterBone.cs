using System;
using System.Collections.Generic;
using UnityEngine;

namespace Voxel.Character
{
    [Serializable]
    public class CharacterBone
    {
        public GameObject BoneGameObject { get; }
        public Vector3 Size { get; }

        public CharacterBone(GameObject boneGameObject, Vector3 size)
        {
            BoneGameObject = boneGameObject;
            Size = size;
        }
    }
}