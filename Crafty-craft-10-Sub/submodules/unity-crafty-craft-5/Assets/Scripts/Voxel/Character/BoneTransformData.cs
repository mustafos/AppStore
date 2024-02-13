using System;
using UnityEngine;
using UnityEngine.Serialization;

namespace Voxel.Character
{
    [Serializable]
    public class BoneTransformData
    {
        public Transform Transform { get; }
        public Vector3 Position { get; }
        public Vector3 Rotation { get; }

        public BoneTransformData(Transform transform, Vector3 position, Vector3 rotation)
        {
            Transform = transform;
            Position = position;
            Rotation = rotation;
        }
    }
}
