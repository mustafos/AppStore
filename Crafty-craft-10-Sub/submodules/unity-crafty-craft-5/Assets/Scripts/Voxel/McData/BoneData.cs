using System;

namespace Voxel.McData
{
    [Serializable]
    public class BoneData
    {
        public string name;
        public string parent;
        public float[] pivot;
        public float[] rotation;
        public bool mirror;
        public float inflate; // Scale
        public int render_group_id; // ? 
        public CubeData[] cubes;
    }
}