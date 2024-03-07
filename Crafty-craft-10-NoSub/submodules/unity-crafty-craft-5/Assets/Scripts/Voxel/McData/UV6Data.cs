using System;

namespace Voxel.McData
{
    [Serializable]
    public class UV6Data
    {
        public UV6DataElement north;
        public UV6DataElement east;
        public UV6DataElement south;
        public UV6DataElement west;
        public UV6DataElement up;
        public UV6DataElement down;
    }
}