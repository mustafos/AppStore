using System;
using System.Collections.Generic;
using UnityEngine;

namespace Voxel.Character
{
    public class CubeDataHolder : MonoBehaviour
    {
       private List<List<Vector2>> _uvData = new List<List<Vector2>>();
        
        public void SetUV(List<List<Vector2>> uv, Vector2Int textureSize)
        {
            for (var i = 0; i < uv.Count; i++)
            {
                
                _uvData.Add(new List<Vector2>());

                for (var j = 0; j < uv[i].Count; j++)
                {
                    var x = Convert.ToInt32(uv[i][j].x * textureSize.x);
                    var y = Convert.ToInt32(uv[i][j].y * textureSize.y);
                    _uvData[i].Add(new Vector2(x, y));
                }
            }
        }

        public bool CheckPointsInUvBox(Vector2 point, Vector2 startPoint)
        {
            List<Vector2> minUVList = null;
            List<Vector2> maxUVList = null;
            GetMinMaxListsValue(out minUVList, out maxUVList);

            int index = -1;
            
            for (var i = 0; i < minUVList.Count; i++)
            {
                if (startPoint.x < minUVList[i].x || startPoint.y < minUVList[i].y || startPoint.x > maxUVList[i].x || startPoint.y > maxUVList[i].y)
                {
                    continue;
                }

                index = i ;
            }

            if (index == -1)
            {
                return false;
            }

            if (point.x < minUVList[index].x || point.y < minUVList[index].y || point.x > maxUVList[index].x || point.y > maxUVList[index].y)
            {
                return false;
            }

            return true;
        }

        public Vector2Int GetRectSize(Vector2 startPoint)
        {
            List<Vector2> minUVList = null;
            List<Vector2> maxUVList = null;
            GetMinMaxListsValue(out minUVList, out maxUVList);

            int index = -1;
            
            for (var i = 0; i < minUVList.Count; i++)
            {
                if (startPoint.x < minUVList[i].x || startPoint.y < minUVList[i].y || startPoint.x > maxUVList[i].x || startPoint.y > maxUVList[i].y)
                {
                    continue;
                }

                index = i ;
            }

            if (index == -1)
            {
                return Vector2Int.zero;
            }
            
            return new Vector2Int(Convert.ToInt32(maxUVList[index].x - minUVList[index].x), Convert.ToInt32(maxUVList[index].y - minUVList[index].y));
        }


        public void GetMinMax(Vector2 startPoint, ref Vector2 minUV, ref Vector2 maxUV)
        {
            List<Vector2> minUVList = null;
            List<Vector2> maxUVList = null;
            GetMinMaxListsValue(out minUVList, out maxUVList);

            for (var i = 0; i < minUVList.Count; i++)
            {
                if (startPoint.x < minUVList[i].x || startPoint.y < minUVList[i].y || startPoint.x > maxUVList[i].x || startPoint.y > maxUVList[i].y)
                {
                    continue;
                }

                minUV = minUVList[i];
                maxUV = maxUVList[i];
                return;
            }
        }

        private void GetMinMaxListsValue(out List<Vector2> minUVList, out List<Vector2> maxUVList)
        {
            minUVList = new List<Vector2>();
            maxUVList = new List<Vector2>();
            
            for (var i = 0; i < _uvData.Count; i++)
            {
                var minUV = _uvData[i][0];
                var maxUV = _uvData[i][0];
                
                foreach (var value in _uvData[i])
                {
                    if (value.x < minUV.x)
                    { 
                        minUV.x = value.x;
                    }
                    if (value.x > maxUV.x)
                    { 
                        maxUV.x = value.x;
                    }
                    if (value.y < minUV.y)
                    { 
                        minUV.y = value.y;
                    }
                    if (value.y > maxUV.y)
                    { 
                        maxUV.y = value.y;
                    }
                }
                
                minUVList.Add(minUV);
                maxUVList.Add(maxUV);
            }
        }
    }
}