using System;

namespace Voxel.McData
{
    [Serializable]
    public class CubeData
    {
        public float[] origin;
        public float[] size;
        public float[] rotation;
        public float inflate; // Scale
        public float[] uv;
        public UV6Data uv6;
        public bool mirror;
        public float[] pivot;
    }
}