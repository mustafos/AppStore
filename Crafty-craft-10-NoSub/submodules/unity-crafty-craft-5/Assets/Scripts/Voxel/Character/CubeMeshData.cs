using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using Voxel.McData;

namespace Voxel.Character
{
    public class CubeMeshData
    {
        private const int FACE_COUNT = 6;

        public List<List<Vector2>> GetUV6(UV6Data data, Vector2Int textureSize, bool forGeometry)
        {
            var returnValue = new List<List<Vector2>>();
            returnValue.Add(GetUV6Logic(data.south, Direction.Front, textureSize));
            
            if (forGeometry)
            {
                returnValue.Add(GetUV6ForGeometryLogic(data.up, data.north, Direction.Up, textureSize));
                returnValue.Add(GetUV6ForGeometryLogic(data.up, data.north, Direction.Back, textureSize));
            }
            else
            {
                returnValue.Add(GetUV6Logic(data.up, Direction.Up, textureSize));
                returnValue.Add(GetUV6Logic(data.north, Direction.Back, textureSize));
            }

            returnValue.Add(GetUV6Logic(data.down, Direction.Down, textureSize));
            returnValue.Add(GetUV6Logic(data.east, Direction.Left, textureSize));
            returnValue.Add(GetUV6Logic(data.west, Direction.Right, textureSize));
            return returnValue;
        }

        private List<Vector2> GetUV6Logic(UV6DataElement element, Direction direction, Vector2Int textureSize)
        {
            var returnValue = new List<Vector2>();
            var startPosition = new Vector2(element.uv[0], element.uv[1]);
            var uvSize = new Vector2(element.uv_size[0], element.uv_size[1]);
            
            switch (direction)
            {
                case Direction.Front:
                case Direction.Up:
                case Direction.Back:
                    returnValue.Add(new Vector2(startPosition.x/textureSize.x, (startPosition.y - uvSize.y)/textureSize.y));//Point 0
                    returnValue.Add(new Vector2((startPosition.x + uvSize.x)/textureSize.x, (startPosition.y - uvSize.y)/textureSize.y));//Point 1
                    returnValue.Add(new Vector2(startPosition.x/textureSize.x, startPosition.y/textureSize.y));//Point 2
                    returnValue.Add(new Vector2((startPosition.x + uvSize.x)/textureSize.x, startPosition.y/textureSize.y));//Point 3
                    break;
                case Direction.Down:
                case Direction.Left:
                case Direction.Right:
                    returnValue.Add(new Vector2(startPosition.x/textureSize.x, (startPosition.y - uvSize.y)/textureSize.y));//Point 0
                    returnValue.Add(new Vector2(startPosition.x/textureSize.x, startPosition.y/textureSize.y));//Point 1
                    returnValue.Add(new Vector2((startPosition.x + uvSize.x)/textureSize.x, startPosition.y/textureSize.y));//Point 2
                    returnValue.Add(new Vector2((startPosition.x + uvSize.x)/textureSize.x, (startPosition.y - uvSize.y)/textureSize.y));//Point 3
                    break;
            }

            return returnValue;
        }

        private List<Vector2> GetUV6ForGeometryLogic(UV6DataElement upElement, UV6DataElement backElement, Direction direction, Vector2Int textureSize)
        {
            var returnValue = new List<Vector2>();
            var upStartPosition = new Vector2(upElement.uv[0], upElement.uv[1]);
            var upUVSize = new Vector2(upElement.uv_size[0], upElement.uv_size[1]);
            var backStartPosition = new Vector2(backElement.uv[0], backElement.uv[1]);
            var backUVSize = new Vector2(backElement.uv_size[0], backElement.uv_size[1]);
            
            switch (direction)
            {
                case Direction.Up:
                    returnValue.Add(new Vector2(upStartPosition.x/textureSize.x, (upStartPosition.y - upUVSize.y)/textureSize.y));//Point 0
                    returnValue.Add(new Vector2((upStartPosition.x + upUVSize.x)/textureSize.x, (upStartPosition.y - upUVSize.y)/textureSize.y));//Point 1
                    returnValue.Add(new Vector2(backStartPosition.x/textureSize.x, (backStartPosition.y - backUVSize.y)/textureSize.y));//Point 0
                    returnValue.Add(new Vector2((backStartPosition.x + backUVSize.x)/textureSize.x, (backStartPosition.y - backUVSize.y)/textureSize.y));//Point 1
                    break;
                case Direction.Back:
                    returnValue.Add(new Vector2(upStartPosition.x/textureSize.x, upStartPosition.y/textureSize.y));//Point 2
                    returnValue.Add(new Vector2((upStartPosition.x + upUVSize.x)/textureSize.x, upStartPosition.y/textureSize.y));//Point 3
                    returnValue.Add(new Vector2(backStartPosition.x/textureSize.x, backStartPosition.y/textureSize.y));//Point 2
                    returnValue.Add(new Vector2((backStartPosition.x + backUVSize.x)/textureSize.x, backStartPosition.y/textureSize.y));//Point 3
                    break;
            }

            return returnValue;
        }

        public List<List<Vector2>> GetUVForGeometry(CubeData cubeData, Vector2Int textureSize)
        {
            var returnValue = new List<List<Vector2>>();

            for (var i = 0; i < FACE_COUNT; i++)
            {
                var uvStartPosition = new Vector2(cubeData.uv[0], textureSize.y - cubeData.uv[1]);
                var uvSize = new Vector3(cubeData.size[0], cubeData.size[1], cubeData.size[2]);
                returnValue.Add(new List<Vector2>(GetUVForGeometryLogic((Direction)i, uvStartPosition, uvSize, textureSize)));
            }

            return returnValue;
        }

        private IEnumerable<Vector2> GetUVForGeometryLogic(Direction direction, Vector2 startPosition, Vector3 uvSize, Vector2 textureSize)
        {
            var returnValue = new List<Vector2>();
            
            switch (direction)
            {
                case Direction.Front:
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 0 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x * 2)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 1 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 2 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x * 2)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 3 for Right Face
                    break;
                case Direction.Up:
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 0 for Up Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 1 for Up Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 0 for Back Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 1 for Back Face
                    break;
                case Direction.Back:
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, startPosition.y/textureSize.y));//Point 2 for Up Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, startPosition.y/textureSize.y));//Point 3 for Up Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 2 for Back Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 3 for Back Face
                    break;
                case Direction.Down:
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 0 for Down Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, startPosition.y/textureSize.y));//Point 1 for Down Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x * 2)/textureSize.x, startPosition.y/textureSize.y));//Point 2 for Down Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x * 2)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 3 for Down Face
                    break;
                case Direction.Left:
                    returnValue.Add(new Vector2(startPosition.x/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 0 for Left Face
                    returnValue.Add(new Vector2(startPosition.x/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 1 for Left Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 2 for Left Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 3 for Left Face
                    break;
                case Direction.Right:
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 0 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 1 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 2 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 3 for Right Face
                    break;
            }

            return returnValue;
        }
        
        public List<List<Vector2>> GetUVForCalculate(CubeData cubeData, Vector2Int textureSize)
        {
            var returnValue = new List<List<Vector2>>();

            for (var i = 0; i < FACE_COUNT; i++)
            {
                var uvStartPosition = new Vector2(cubeData.uv[0], textureSize.y - cubeData.uv[1]);
                var uvSize = new Vector3(cubeData.size[0], cubeData.size[1], cubeData.size[2]);
                returnValue.Add(new List<Vector2>(GetUVForCalculateLogic((Direction)i, uvStartPosition, uvSize, textureSize)));
            }

            return returnValue;
        }

        private IEnumerable<Vector2> GetUVForCalculateLogic(Direction direction, Vector2 startPosition, Vector3 uvSize, Vector2 textureSize)
        {
            var returnValue = new List<Vector2>();
            
            switch (direction)
            {
                case Direction.Front:
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 0 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x * 2)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 1 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 2 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x * 2)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 3 for Right Face
                    break;
                case Direction.Up:
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 0 for Up Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 1 for Up Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, startPosition.y/textureSize.y));//Point 2 for Up Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, startPosition.y/textureSize.y));//Point 3 for Up Face
                    break;
                case Direction.Back:
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 0 for Back Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 1 for Back Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 2 for Back Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 3 for Back Face
                    break;
                case Direction.Down:
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 0 for Down Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, startPosition.y/textureSize.y));//Point 1 for Down Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x * 2)/textureSize.x, startPosition.y/textureSize.y));//Point 2 for Down Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x * 2)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 3 for Down Face
                    break;
                case Direction.Left:
                    returnValue.Add(new Vector2(startPosition.x/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 0 for Left Face
                    returnValue.Add(new Vector2(startPosition.x/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 1 for Left Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 2 for Left Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 3 for Left Face
                    break;
                case Direction.Right:
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 0 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 1 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z)/textureSize.y));//Point 2 for Right Face
                    returnValue.Add(new Vector2((startPosition.x + uvSize.z * 2 + uvSize.x)/textureSize.x, (startPosition.y - uvSize.z - uvSize.y)/textureSize.y));//Point 3 for Right Face
                    break;
            }

            return returnValue;
        }
    }
}