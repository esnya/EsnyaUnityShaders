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
        string keyword;
        public VisibleIfDrawer(string keyword)
        {
            this.keyword = keyword;
        }

        bool IsVisible(MaterialEditor editor)
        {
            return !editor.targets.Select(m => m as Material).Any(m => m.shaderKeywords == null || !m.shaderKeywords.Contains(keyword));
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
