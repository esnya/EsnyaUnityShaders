using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;

namespace EsnyaFactory {
    public class VisibleIfDrawer : MaterialPropertyDrawer
    {
        protected string[] keywords;
        public VisibleIfDrawer(string keyword1)
        {
            keywords = new [] { keyword1 };
        }
        public VisibleIfDrawer(string keyword1, string keyword2)
        {
            keywords = new [] { keyword1, keyword2 };
        }

        protected virtual bool IsVisible(MaterialEditor editor)
        {
            return !editor.targets.Select(m => m as Material).Any(m => m.shaderKeywords == null || !m.shaderKeywords.Any(keyword => keywords.Contains(keyword)));
        }

        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            if (IsVisible(editor)) {
                editor.DefaultShaderProperty(position, prop, label);
            }
        }

        public override float GetPropertyHeight(MaterialProperty prop, string label, MaterialEditor editor)
        {
            return IsVisible(editor) ? MaterialEditor.GetDefaultPropertyHeight(prop) : 0;
        }
    }

}