using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;

namespace EsnyaFactory {
    public class EsnyaPBRGUI : ShaderGUI
    {
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            var material = materialEditor.target as Material;

            base.OnGUI(materialEditor, props);

            using (var cc = new EditorGUI.ChangeCheckScope()) {
                material.globalIlluminationFlags = (MaterialGlobalIlluminationFlags)EditorGUILayout.EnumPopup("Global Illumination Flags", material.globalIlluminationFlags);

                if (cc.changed) {
                    foreach (var t in materialEditor.targets) {
                        var m = t as Material;
                        if (m != material) m.globalIlluminationFlags = material.globalIlluminationFlags;
                    }
                }
            }
        }
    }

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
