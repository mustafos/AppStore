using System;
using System.Collections.Generic;
using UnityEngine;

namespace Meta.Inputs
{
    [Serializable]
    public class UndoData
    {
        public List<UndoDataTextureData> texturesData = new List<UndoDataTextureData>();
        public Renderer renderer;
    }
}