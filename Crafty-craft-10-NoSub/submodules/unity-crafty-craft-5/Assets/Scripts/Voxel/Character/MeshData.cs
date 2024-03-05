using System.Collections.Generic;
using UnityEngine;

namespace Voxel.Character
{
    public class MeshData
    {
        public List<Vector3> vertices = new List<Vector3>();
        public List<int> triangles = new List<int>();
        public List<List<Vector2>> uv = new List<List<Vector2>>();
    }
}