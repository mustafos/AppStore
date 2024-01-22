using System;

namespace Voxel.McData
{
    [Serializable]
    public class DescriptionData
    {
        public string identifier;
        public int texture_width;
        public int texture_height;
        //public float visible_bounds_width;
        //public float visible_bounds_height;
        public int[] visible_bounds_offset;
    }
}