using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;

namespace EsnyaFactory
{
    public class HideIfDrawer : VisibleIfDrawer
    {
        public HideIfDrawer(string keyword) : base(keyword) {}
        public HideIfDrawer(string keyword1, string keyword2) : base(keyword1, keyword2) {}

        protected override bool IsVisible(MaterialEditor editor)
        {
            return !base.IsVisible(editor);
        }
    }
}